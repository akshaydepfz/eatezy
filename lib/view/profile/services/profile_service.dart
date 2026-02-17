import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eatezy/model/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProfileService extends ChangeNotifier {
  CustomerModel? customer;
  bool isPushNotifed = true;
  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

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

  Future<String> _uploadImageToStorage(XFile imageFile) async {
    final ref = FirebaseStorage.instance.ref().child(
        'profile_images/${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final bytes = await imageFile.readAsBytes();
    final task = ref.putData(bytes);
    final snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> updateProfile(
    BuildContext context, {
    required String name,
    required String email,
    XFile? newProfileImage,
  }) async {
    if (customer == null) return;
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isUpdating = true;
    notifyListeners();

    try {
      String profileImageUrl = customer!.image;
      if (newProfileImage != null) {
        profileImageUrl = await _uploadImageToStorage(newProfileImage);
      }

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'name': name.trim(),
        'email': email.trim(),
        'profile_image': profileImageUrl,
      });

      await getCustomer();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
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
