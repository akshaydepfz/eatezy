import 'dart:developer';
import 'dart:io';
import 'package:eatezy/view/auth/screens/customer_profile_add_screen.dart';
import 'package:eatezy/view/home/screens/landing_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/view/auth/screens/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginSrvice extends ChangeNotifier {
  bool _isVisible = false;
  File? image;

  TextEditingController nameController = TextEditingController();
  TextEditingController adresss = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  TextEditingController mobileController = TextEditingController();
  TextEditingController opController = TextEditingController();
  void onVisibleChange() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool get isVisible => _isVisible;
  String _verificationId = '';
  bool isLoading = false;

  Future<void> verifyPhoneNumber(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91${mobileController.text}",
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Serevr Error')));
        log("Failed to verify phone number: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        log("OTP code sent to phone.");
        isLoading = false;
        notifyListeners();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const OtpAuthScreen()));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        isLoading = false;
        notifyListeners();
        log("Auto retrieval timeout.");
      },
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      isLoading = true;
      notifyListeners();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> signInWithOTP(String smsCode, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const CustomerDetailsAddScreen()),
          (Route<dynamic> route) => false,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Account Created"),
        backgroundColor: Colors.green,
      ));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Firebase Auth Error: ${e.message}"),
        backgroundColor: Colors.red,
      ));

      // You can also show a snackbar or alert dialog to the user
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Unexpected error: $e"),
        backgroundColor: Colors.red,
      ));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerUser(BuildContext context) async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please enter name",
          ),
          backgroundColor: Colors.red));
    } else if (image == null) {
      final pref = await SharedPreferences.getInstance();

      isLoading = true;
      notifyListeners();
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'profile_image': '',
        'name': nameController.text,
        'email': emailController.text,
        'phone': mobileController.text,
        'uid': FirebaseAuth.instance.currentUser!.uid,
        "address": adresss.text,
        'created_date': DateTime.now().toString(),
        "fcm_token": "",
      });
      pref.setBool('isUserExist', true);
      isLoading = false;
      notifyListeners();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
        (Route<dynamic> route) =>
            false, // This condition removes all previous routes.
      );
    } else {
      String imageUrl = await uploadImageToStorage(image!);
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'profile_image': imageUrl,
        'name': nameController.text,
        'email': emailController.text,
        'phone': mobileController.text,
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'created_date': DateTime.now().toString(),
        "fcm_token": "",
      });

      isLoading = false;
      notifyListeners();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
        (Route<dynamic> route) =>
            false, // This condition removes all previous routes.
      );
    }
  }
}
