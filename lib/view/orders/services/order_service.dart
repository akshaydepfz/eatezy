import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/order_model.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderService extends ChangeNotifier {
  List<OrderModel>? orders;
  List<OrderModel> deliveredOrders = [];
  List<OrderModel> upmcomingedOrders = [];
  List<OrderModel> cancellOrders = [];
  List<VendorModel> vendors = [];

  Future<void> getOrders() async {
    try {
      orders = null;
      deliveredOrders.clear();
      upmcomingedOrders.clear();
      cancellOrders.clear();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('uuid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('created_date', descending: true)
          .get();
      orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      if (orders != null) {
        for (var item in orders!) {
          if (item.isCancelled == false && item.orderStatus == 'Completed') {
            deliveredOrders.add(item);
            notifyListeners();
          }
          if (item.orderStatus != 'Completed' && !item.isCancelled) {
            upmcomingedOrders.add(item);
            notifyListeners();
          }
          if (item.isCancelled) {
            cancellOrders.add(item);
            notifyListeners();
          }
        }
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<void> gettVendors() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('vendors').get();
      vendors = snapshot.docs.map((doc) {
        return VendorModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching vendor: $e');
    }
  }

  VendorModel? findVendorById(String id) {
    for (final vendor in vendors) {
      if (vendor.id == id) return vendor;
    }
    return null;
  }

  Future<void> cancellOrder(
      BuildContext context, String id, String cancellationReason) async {
    await FirebaseFirestore.instance.collection('cart').doc(id).update({
      "isCancelled": true,
      "cancellation_reason": cancellationReason,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order Cancelled by you!")),
    );
    getOrders();
  }

  void showReviewDialog(BuildContext context, String id) {
    double rating = 0;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Leave a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 30,
                    ),
                    onPressed: () {
                      rating = index + 1.0;
                      (context as Element).markNeedsBuild();
                    },
                  );
                }),
              ),
              const SizedBox(height: 10),
              // Review TextField
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Write your review',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String review = reviewController.text.trim();
                await FirebaseFirestore.instance.collection('cart').doc(id).set(
                  {
                    'is_rated': true,
                    'star': rating,
                    'rating_text': review,
                  },
                  SetOptions(merge: true),
                );
                getOrders();

                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
