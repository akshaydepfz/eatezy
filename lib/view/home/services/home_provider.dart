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

  List<Widget> pages = const [
    HomeScreen(),
    CategoryScreen(),
    RestaurantsListScreen(),
    ProfileScreen(),
  ];

  String formatTime(double minutes) {
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(0)} min';
    } else {
      int hrs = minutes ~/ 60;
      int mins = (minutes % 60).round();
      return '$hrs hr ${mins} min';
    }
  }

  /// Starts listening to vendors in real time. Only vendors with is_active == true are shown.
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
            .where((v) => v.isActive)
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

      topProducts = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
      topProducts = null;
    }
  }
}
