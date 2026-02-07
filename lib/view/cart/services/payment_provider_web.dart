import 'dart:js' as js;
import 'package:eatezy/config/razorpay_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  bool isCashOnDelivery = true;
  String paymentStatus = "Pending";

  void onPaymentMethodChange(bool v) {
    isCashOnDelivery = v;
    notifyListeners();
  }

  void openCheckout(
    double amount,
    String name,
    String description, {
    String? customerName,
    Function(dynamic)? onSuccess,
    Function(dynamic)? onError,
    Function(dynamic)? onExternalWallet,
  }) {
    final options = js.JsObject.jsify({
      'key': razorpayKeyId,
      'amount': (amount * 100).round(),
      'currency': 'INR',
      'name': name,
      'description': description,
      'prefill': {
        'contact': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
        'name': customerName ?? '',
      },
      'handler': js.allowInterop((response) {
        paymentStatus = "Payment Successful";
        notifyListeners();
        onSuccess?.call(response);
      }),
      'modal': {
        'ondismiss': js.allowInterop(() {
          paymentStatus = "Payment Cancelled";
          notifyListeners();
        })
      }
    });

    js.context.callMethod('Razorpay', [options]).callMethod('open');
  }
}
