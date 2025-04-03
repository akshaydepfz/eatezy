import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomeProvider extends ChangeNotifier {
  String _address = 'Loading...';
  bool _isLoading = false;
  String get address => _address;

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
