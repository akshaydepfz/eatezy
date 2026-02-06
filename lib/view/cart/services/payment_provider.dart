import 'package:eatezy/config/razorpay_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentProvider extends ChangeNotifier {
  bool isCashOnDelivery = true;
  String paymentStatus = "Pending";
  late final Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onPaymentSuccessCallback;

  PaymentProvider() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void onPaymentMethodChange(bool v) {
    isCashOnDelivery = v;
    notifyListeners();
  }

  Function(PaymentFailureResponse)? onPaymentErrorCallback;
  Function(ExternalWalletResponse)? onExternalWalletCallback;

  void openCheckout(
    double amount,
    String name,
    String description, {
    String? customerName,
    Function(PaymentSuccessResponse)? onSuccess,
    void Function(PaymentFailureResponse)? onError,
    void Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    onPaymentSuccessCallback = onSuccess;
    onPaymentErrorCallback = onError;
    onExternalWalletCallback = onExternalWallet;

    final options = {
      'key': razorpayKeyId,
      'amount': (amount * 100).round(),
      'name': name,
      'description': description,
      'currency': 'INR',
      'prefill': {
        'contact': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
        'name': customerName ?? '',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay openCheckout error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    paymentStatus = "Payment Successful";
    if (onPaymentSuccessCallback != null) {
      onPaymentSuccessCallback!(response);
    }
    onPaymentErrorCallback = null;
    onPaymentSuccessCallback = null;
    onExternalWalletCallback = null;
    notifyListeners();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    paymentStatus = "Payment Failed: ${response.message}";
    if (onPaymentErrorCallback != null) {
      onPaymentErrorCallback!(response);
    }
    onPaymentErrorCallback = null;
    onPaymentSuccessCallback = null;
    onExternalWalletCallback = null;
    notifyListeners();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    paymentStatus = "External Wallet Selected";
    if (onExternalWalletCallback != null) {
      onExternalWalletCallback!(response);
    }
    onPaymentErrorCallback = null;
    onPaymentSuccessCallback = null;
    onExternalWalletCallback = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
