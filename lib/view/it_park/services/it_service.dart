import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/it_park_model.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ItService extends ChangeNotifier {
  List<ItParkModel> itParks = [];
  List<VendorModel>? vendors;

  String formatTime(double minutes) {
    if (minutes < 1) {
      return "< 1 min";
    } else {
      return "${minutes.round()} mins";
    }
  }

  Future<void> getItParks() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double userLat = position.latitude;
      double userLng = position.longitude;

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('it_parks').get();

      itParks = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        double lat = (data['lat'] ?? 0).toDouble();
        double lng = (data['long'] ?? 0).toDouble();

        double distanceInKm = Geolocator.distanceBetween(
              userLat,
              userLng,
              lat,
              lng,
            ) /
            1000;

        double estimatedMinutes = (distanceInKm / 40) * 60;

        return ItParkModel.fromFirestore(
          data,
          doc.id,
          '${distanceInKm.toStringAsFixed(2)} km',
          formatTime(estimatedMinutes),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching IT parks: $e');
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
      }).where((v) => !v.isSuspend).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching vendors: $e');
    }
  }
}
