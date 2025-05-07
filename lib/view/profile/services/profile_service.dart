import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileService extends ChangeNotifier {
  CustomerModel? customer;
  bool isPushNotifed = true;

  void changeNotified(bool v) {
    isPushNotifed = v;
    notifyListeners();
  }

  Future<void> getCustomer() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (docSnapshot.exists) {
        customer =
            CustomerModel.fromFirestore(docSnapshot.data()!, docSnapshot.id);
        notifyListeners();
      }
    } catch (_) {}
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Dismiss dialog
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
