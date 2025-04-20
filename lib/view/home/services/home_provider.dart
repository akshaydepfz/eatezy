import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/category_model.dart';
import 'package:eatezy/model/product_model.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:eatezy/view/categories/screens/categories_screen.dart';
import 'package:eatezy/view/home/screens/home_screen.dart';
import 'package:eatezy/view/profile/screens/profile_screen.dart';
import 'package:eatezy/view/restaurants/screens/restaurants_list.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomeProvider extends ChangeNotifier {
  String _address = 'Loading...';
  int _selectedIndex = 0;
  List<VendorModel>? vendors;
  List<ProductModel>? topProducts;
  List<CategoryModel>? category;
  bool _isLoading = false;
  int get selectedIndex => _selectedIndex;

  String get address => _address;

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

  Future<void> gettVendors() async {
    try {
      // Get user's current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double userLat = position.latitude;
      double userLng = position.longitude;

      // Fetch all vendors
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('vendors').get();

      vendors = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        double vendorLat = double.tryParse(data['lat'].toString()) ?? 0.0;
        double vendorLng = double.tryParse(data['long'].toString()) ?? 0.0;

        double distanceInKm = Geolocator.distanceBetween(
              userLat,
              userLng,
              vendorLat,
              vendorLng,
            ) /
            1000;

        double estimatedMinutes = (distanceInKm / 40) * 60;

        return VendorModel.fromFirestore(
          data,
          doc.id,
          estimateDistance: '${distanceInKm.toStringAsFixed(2)} km',
          estimateTime: formatTime(estimatedMinutes),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching vendors: $e');
    }
  }

  Future<void> getLocationAndAddress() async {
    _isLoading = true;

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

        _address = '${place.street}, ${place.locality}, ${place.country}';
        notifyListeners();
      }
    } catch (e) {
      _address = '$e';
    } finally {
      _isLoading = false;
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
