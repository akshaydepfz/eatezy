import 'dart:async';
import 'dart:developer';
import 'package:eatezy/model/banner_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/category_model.dart';
import 'package:eatezy/model/product_model.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:eatezy/view/categories/screens/categories_screen.dart';
import 'package:eatezy/view/home/screens/home_screen.dart';
import 'package:eatezy/view/profile/screens/profile_screen.dart';
import 'package:eatezy/view/restaurants/screens/restaurants_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  String _address = 'Loading...';
  double? _latitude;
  double? _longitude;
  int _selectedIndex = 0;
  List<VendorModel>? vendors;
  List<ProductModel>? topProducts;
  List<CategoryModel>? category;
  StreamSubscription<QuerySnapshot>? _vendorsSubscription;
  int get selectedIndex => _selectedIndex;
  List<BannerModel> banners = [];
  String get address => _address;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  void onSelectedChange(int i) {
    _selectedIndex = i;
    notifyListeners();
  }

  Future<String?> getFcmToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // iOS permission
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      String? token = await messaging.getToken();

      print("FCM Token: $token");
      return token;
    } catch (e) {
      print("FCM Token Error: $e");
      return null;
    }
  }

  List<Widget> pages = const [
    HomeScreen(),
    CategoryScreen(),
    RestaurantsListScreen(),
    ProfileScreen(),
  ];

  /// Computes distance from user's current location to a vendor. Returns empty string if location unavailable.
  String computeDistanceToVendor(VendorModel vendor) {
    if (_latitude == null || _longitude == null) return vendor.estimateDistance;
    final vendorLat = double.tryParse(vendor.lat);
    final vendorLng = double.tryParse(vendor.long);
    if (vendorLat == null || vendorLng == null) return vendor.estimateDistance;
    final distanceInMeters = Geolocator.distanceBetween(
      _latitude!,
      _longitude!,
      vendorLat,
      vendorLng,
    );
    final distanceInKm = distanceInMeters / 1000;
    if (distanceInKm < 1) {
      return '${distanceInMeters.round()} m';
    }
    return '${distanceInKm.toStringAsFixed(2)} km';
  }

  String formatTime(double minutes) {
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(0)} min';
    } else {
      int hrs = minutes ~/ 60;
      int mins = (minutes % 60).round();
      return '$hrs hr ${mins} min';
    }
  }

  /// Starts listening to vendors in real time. Suspended vendors are excluded; inactive ones display as "Closed" with opening/closing times.
  void startVendorsStream() {
    if (_vendorsSubscription != null) return;
    _vendorsSubscription = FirebaseFirestore.instance
        .collection('vendors')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      try {
        vendors = snapshot.docs
            .map((doc) => VendorModel.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .where((v) => !v.isSuspend)
            .toList();
        notifyListeners();
      } catch (e) {
        log('Error processing vendors stream: $e');
      }
    });
  }

  void disposeVendorsStream() {
    _vendorsSubscription?.cancel();
    _vendorsSubscription = null;
  }

  // Future<void> gettVendors() async {
  //   try {
  //     // Use saved location if available, otherwise get current location
  //     double userLat;
  //     double userLng;

  //     if (_latitude != null && _longitude != null) {
  //       userLat = _latitude!;
  //       userLng = _longitude!;
  //     } else {
  //       Position position = await Geolocator.getCurrentPosition(
  //           desiredAccuracy: LocationAccuracy.high);
  //       userLat = position.latitude;
  //       userLng = position.longitude;
  //     }

  //     // Fetch all vendors
  //     QuerySnapshot snapshot =
  //         await FirebaseFirestore.instance.collection('vendors').get();

  //     vendors = snapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       double vendorLat = double.tryParse(data['lat'].toString()) ?? 0.0;
  //       double vendorLng = double.tryParse(data['long'].toString()) ?? 0.0;

  //       double distanceInKm = Geolocator.distanceBetween(
  //             userLat,
  //             userLng,
  //             vendorLat,
  //             vendorLng,
  //           ) /
  //           1000;

  //       double estimatedMinutes = (distanceInKm / 40) * 60;

  //       return VendorModel.fromFirestore(
  //         data,
  //         doc.id,
  //         estimateDistance: '${distanceInKm.toStringAsFixed(2)} km',
  //         estimateTime: formatTime(estimatedMinutes),
  //       );
  //     }).toList();

  //     notifyListeners();
  //   } catch (e) {
  //     print('Error fetching vendors: $e');
  //   }
  // }

  Future<void> fetchBanners() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('banners').get();

      for (var doc in querySnapshot.docs) {
        banners.add(BannerModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> updateAdminFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'fcm_token': token});

        print('FCM token updated successfully: $token');
      } else {
        print('Failed to get FCM token.');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> loadSavedLocation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedAddress = prefs.getString('saved_address');
      double? savedLat = prefs.getDouble('saved_latitude');
      double? savedLng = prefs.getDouble('saved_longitude');

      if (savedAddress != null && savedLat != null && savedLng != null) {
        _address = savedAddress;
        _latitude = savedLat;
        _longitude = savedLng;
        notifyListeners();
        return;
      }
    } catch (e) {
      log('Error loading saved location: $e');
    }
    // If no saved location, get current location
    await getLocationAndAddress();
  }

  Future<void> saveLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_address', address);
      await prefs.setDouble('saved_latitude', latitude);
      await prefs.setDouble('saved_longitude', longitude);

      _address = address;
      _latitude = latitude;
      _longitude = longitude;
      notifyListeners();
    } catch (e) {
      log('Error saving location: $e');
      rethrow;
    }
  }

  Future<void> getLocationAndAddress() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      log(permission.name);
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        _address =
            '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
                .replaceAll(RegExp(r'^,\s*|,\s*$'), '')
                .replaceAll(RegExp(r',\s*,+'), ', ');
        _latitude = position.latitude;
        _longitude = position.longitude;
        notifyListeners();
      }
    } catch (e) {
      _address = '$e';
    }
  }

  Future<void> fetchCategory() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .orderBy('order')
        .get();

    category = snapshot.docs.map((doc) {
      return CategoryModel.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> fetchTopProducts() async {
    topProducts = null;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('is_top', isEqualTo: true)
          .get();

      final allProducts = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (allProducts.isEmpty) {
        topProducts = [];
        notifyListeners();
        return;
      }

      final vendorIds = allProducts.map((p) => p.vendorID).toSet().toList();
      final allowedVendorIds = <String>{};

      for (final vendorId in vendorIds) {
        if (vendorId.isEmpty) continue;
        final vendorDoc = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(vendorId)
            .get();
        final data = vendorDoc.data();
        if (data != null &&
            (data['is_active'] ?? false) == true &&
            (data['is_suspend'] ?? false) != true) {
          allowedVendorIds.add(vendorId);
        }
      }

      topProducts = allProducts
          .where((p) => allowedVendorIds.contains(p.vendorID))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
      topProducts = null;
    }
  }
}
