import 'package:eatezy/config/razorpay_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentProvider extends ChangeNotifier {
  bool isCashOnDelivery = true;
  String paymentStatus = "Pending";

  late final Razorpay _razorpay;

  Function(PaymentSuccessResponse)? onPaymentSuccessCallback;
  Function(PaymentFailureResponse)? onPaymentErrorCallback;
  Function(ExternalWalletResponse)? onExternalWalletCallback;

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

  void openCheckout(
    double amount,
    String name,
    String description, {
    String? customerName,
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    onPaymentSuccessCallback = onSuccess;
    onPaymentErrorCallback = onError;
    onExternalWalletCallback = onExternalWallet;

    final options = {
      'key': razorpayKeyId,
      'amount': (amount * 100).round(),
      'currency': 'INR',
      'name': name,
      'description': description,
      'prefill': {
        'contact': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
        'name': customerName ?? '',
      },
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    paymentStatus = "Payment Successful";
    onPaymentSuccessCallback?.call(response);
    _clear();
    notifyListeners();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    paymentStatus = "Payment Failed: ${response.message}";
    onPaymentErrorCallback?.call(response);
    _clear();
    notifyListeners();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    paymentStatus = "External Wallet Selected";
    onExternalWalletCallback?.call(response);
    _clear();
    notifyListeners();
  }

  void _clear() {
    onPaymentSuccessCallback = null;
    onPaymentErrorCallback = null;
    onExternalWalletCallback = null;
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
