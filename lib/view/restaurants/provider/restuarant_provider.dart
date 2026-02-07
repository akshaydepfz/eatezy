import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/offer_model.dart';
import 'package:eatezy/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RestuarantProvider extends ChangeNotifier {
  List<ProductModel>? products;
  List<ProductModel>? featuredProducts;
  List<ProductModel>? catProducts;
  List<OfferModel>? offers;

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

  Future<void> fetchOffers(String vendorID) async {
    offers = null;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('offers')
          .where('vendorId', isEqualTo: vendorID)
          .where('isActive', isEqualTo: true)
          .get();

      offers = snapshot.docs
          .map((doc) => OfferModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching offers: $e');
      offers = null;
      notifyListeners();
    }
  }

  OfferModel? getOfferForProduct(String productId) {
    if (offers == null) return null;
    try {
      return offers!.firstWhere((o) => o.productId == productId);
    } catch (_) {
      return null;
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

  Future<void> fetchCategoryProducts(String category) async {
    catProducts = null;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      final allProducts = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (allProducts.isEmpty) {
        catProducts = [];
        notifyListeners();
        return;
      }

      final vendorIds = allProducts.map((p) => p.vendorID).toSet().toList();
      final activeVendorIds = <String>{};

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
          activeVendorIds.add(vendorId);
        }
      }

      catProducts = allProducts
          .where((p) => activeVendorIds.contains(p.vendorID))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
      catProducts = null;
    }
  }

  /// Fetches products by their document IDs (e.g. for favorites list). Excludes products from suspended or inactive vendors.
  Future<List<ProductModel>> fetchProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final futures = ids.map((id) => FirebaseFirestore.instance
          .collection('products')
          .doc(id)
          .get());
      final snaps = await Future.wait(futures);
      final products = <ProductModel>[];
      for (var i = 0; i < snaps.length; i++) {
        final doc = snaps[i];
        if (doc.exists && doc.data() != null) {
          products.add(ProductModel.fromFirestore(
              doc.data()!, doc.id));
        }
      }
      if (products.isEmpty) return [];

      final vendorIds = products.map((p) => p.vendorID).toSet().toList();
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

      return products.where((p) => allowedVendorIds.contains(p.vendorID)).toList();
    } catch (e) {
      print('Error fetching products by ids: $e');
      return [];
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
