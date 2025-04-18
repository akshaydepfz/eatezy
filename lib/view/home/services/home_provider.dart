import 'dart:developer';

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
  // ignore: unused_field
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
}
