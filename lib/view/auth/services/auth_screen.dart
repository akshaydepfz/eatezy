import 'dart:developer';
import 'dart:typed_data';
import 'package:eatezy/view/auth/screens/customer_profile_add_screen.dart';
import 'package:eatezy/view/home/screens/landing_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/view/auth/screens/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginSrvice extends ChangeNotifier {
  bool _isVisible = false;
  Uint8List? imageBytes;

  TextEditingController nameController = TextEditingController();
  TextEditingController adresss = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  TextEditingController mobileController = TextEditingController();
  TextEditingController opController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isVisible => _isVisible;

  String _verificationId = '';
  bool isLoading = false;

  RecaptchaVerifier? _recaptchaVerifier;
  ConfirmationResult? _confirmationResult; // For web OTP

  void onVisibleChange() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  // ------------------------------------------------------------
  // 🔥 SIGN IN WITH GOOGLE (WEB ONLY)
  // ------------------------------------------------------------
  Future<void> signInWithGoogle(BuildContext context) async {
    if (!kIsWeb) return;
    isLoading = true;
    notifyListeners();
    try {
      final googleProvider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(googleProvider);
      if (userCredential.user != null) {
        final user = userCredential.user!;
        nameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerDetailsAddScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Error: $e")),
      );
      log("Google Sign-In Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // 🔥 VERIFY PHONE NUMBER (MOBILE ONLY - WEB USES GOOGLE)
  // ------------------------------------------------------------
  Future<void> verifyPhoneNumber(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // ✅ NEW RecaptchaVerifier (firebase_auth 5.x)
        _recaptchaVerifier = RecaptchaVerifier(
          onSuccess: () {
            log("reCAPTCHA success");
          },
          onExpired: () {
            log("reCAPTCHA expired");
          },
          onError: (error) {
            log("reCAPTCHA error: $error");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("reCAPTCHA Error: $error")),
            );
          },
          auth: FirebaseAuthPlatform.instance,
          container:
              'recaptcha-container', // Ensure this ID exists in index.html
          size: RecaptchaVerifierSize
              .normal, // Change to .invisible if you don't want a box
          // ... rest of your code
        );

        await _recaptchaVerifier!.render();

        // 🔥 NEW Web OTP Method
        _confirmationResult = await _auth.signInWithPhoneNumber(
          "+91${mobileController.text}",
          _recaptchaVerifier!,
        );

        log("OTP sent to Web");

        isLoading = false;
        notifyListeners();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OtpAuthScreen()),
        );
      } else {
        // 🔥 MOBILE OTP
        await _auth.verifyPhoneNumber(
          phoneNumber: "+91${mobileController.text}",
          verificationCompleted: (PhoneAuthCredential credential) async {},
          verificationFailed: (FirebaseAuthException e) {
            isLoading = false;
            notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Server Error: ${e.message}")),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            log("OTP sent Mobile");

            isLoading = false;
            notifyListeners();

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OtpAuthScreen()),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();

      if (_recaptchaVerifier != null) {
        _recaptchaVerifier!.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      log("Error: $e");
    }
  }

  // ------------------------------------------------------------
  // 🔥 SIGN IN WITH OTP
  // ------------------------------------------------------------
  Future<void> signInWithOTP(String smsCode, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      UserCredential userCredential;

      if (kIsWeb) {
        if (_confirmationResult == null) {
          throw Exception("OTP session expired, try again.");
        }

        userCredential = await _confirmationResult!.confirm(smsCode);

        if (_recaptchaVerifier != null) {
          _recaptchaVerifier!.clear();
        }
      } else {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: smsCode,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      if (userCredential.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerDetailsAddScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Error: $e")),
      );
      log("OTP Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // IMAGE UPLOAD + USER STORE (UNCHANGED)
  // ------------------------------------------------------------
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageBytes = await pickedFile.readAsBytes();
      notifyListeners();
    }
  }

  Future<String> uploadImageToStorage(Uint8List bytes) async {
    try {
      isLoading = true;
      notifyListeners();

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = storageRef.putData(bytes);
      TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  Future<void> registerUser(BuildContext context) async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please enter name"), backgroundColor: Colors.red),
      );
      return;
    }
    if (kIsWeb) {
      if (mobileController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Please enter phone number"),
              backgroundColor: Colors.red),
        );
        return;
      }
    } else {
      if (emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Please enter email address"),
              backgroundColor: Colors.red),
        );
        return;
      }
    }

    final pref = await SharedPreferences.getInstance();
    isLoading = true;
    notifyListeners();

    String imageUrl = "";
    if (imageBytes != null) {
      imageUrl = await uploadImageToStorage(imageBytes!);
    }

    final email = kIsWeb
        ? (_auth.currentUser?.email ?? emailController.text)
        : emailController.text;
    final phone = kIsWeb
        ? mobileController.text
        : mobileController.text;

    await _firestore.collection('customers').doc(_auth.currentUser!.uid).set({
      'profile_image': imageUrl,
      'name': nameController.text,
      'email': email,
      'phone': phone,
      'uid': _auth.currentUser!.uid,
      'address': adresss.text,
      'created_date': DateTime.now().toString(),
      'fcm_token': "",
    });

    pref.setBool('isUserExist', true);

    isLoading = false;
    notifyListeners();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LandingScreen()),
      (route) => false,
    );
  }
}
