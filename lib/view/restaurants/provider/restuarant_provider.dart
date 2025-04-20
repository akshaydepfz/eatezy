import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RestuarantProvider extends ChangeNotifier {
  List<ProductModel>? products;
  List<ProductModel>? featuredProducts;

  Future<void> fetchProducts(String vendorID) async {
    products = null;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('vendor_id', isEqualTo: vendorID)
          .get();

      products = snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
      products = null;
    }
  }

  Future<void> fetchfuturedProducts(String vendorID) async {
    featuredProducts = null;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('vendor_id', isEqualTo: vendorID)
          .get();

      featuredProducts = snapshot.docs
          .where((doc) =>
              (doc.data() as Map<String, dynamic>)['is_featured'] == true)
          .map((doc) => ProductModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
      featuredProducts = null;
    }
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

  Future<void> calculateDistanceAndTime(String vendorId) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double userLat = position.latitude;
      double userLng = position.longitude;

      final snapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();

      final vendorData = snapshot.data();
      if (vendorData == null) return;

      double restLat = double.parse(vendorData['lat']);
      double restLng = double.parse(vendorData['long']);

      double distanceInKm = Geolocator.distanceBetween(
            userLat,
            userLng,
            restLat,
            restLng,
          ) /
          1000;

      // 4. Estimate time to reach (assuming avg speed 40 km/h)
      double estimatedTimeInMinutes = (distanceInKm / 40) * 60;

      // 5. Format time
      String formattedTime = formatTime(estimatedTimeInMinutes);

      print('Distance: ${distanceInKm.toStringAsFixed(2)} km');
      print('Estimated Time: $formattedTime');
    } catch (e) {
      print('Error calculating distance/time: $e');
    }
  }
}
