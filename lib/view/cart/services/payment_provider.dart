import 'dart:js' as js;
import 'package:eatezy/config/razorpay_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentProvider extends ChangeNotifier {
  bool isCashOnDelivery = true;
  String paymentStatus = "Pending";

  Razorpay? _razorpay;

  Function(PaymentSuccessResponse)? onPaymentSuccessCallback;
  Function(PaymentFailureResponse)? onPaymentErrorCallback;
  Function(ExternalWalletResponse)? onExternalWalletCallback;

  PaymentProvider() {
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  void onPaymentMethodChange(bool v) {
    isCashOnDelivery = v;
    notifyListeners();
  }

  /// MAIN ENTRY POINT
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
      'name': name,
      'description': description,
      'currency': 'INR',
      'prefill': {
        'contact': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
        'name': customerName ?? '',
      },
    };

    try {
      if (kIsWeb) {
        _openCheckoutWeb(options);
      } else {
        _razorpay!.open(options);
      }
    } catch (e) {
      debugPrint("Razorpay error: $e");
    }
  }

  // =======================
  // 🔹 WEB IMPLEMENTATION
  // =======================
  void _openCheckoutWeb(Map<String, dynamic> options) {
    final jsOptions = js.JsObject.jsify({
      'key': options['key'],
      'amount': options['amount'],
      'currency': 'INR',
      'name': options['name'],
      'description': options['description'],
      'prefill': options['prefill'],
      'handler': js.allowInterop((response) {
        paymentStatus = "Payment Successful";

        if (onPaymentSuccessCallback != null) {
          onPaymentSuccessCallback!(
            PaymentSuccessResponse(
              response['razorpay_payment_id'],
              response['razorpay_order_id'],
              response['razorpay_signature'],
              response['razorpay_payment_link_id'],
            ),
          );
        }

        notifyListeners();
      }),
      'modal': {
        'ondismiss': js.allowInterop(() {
          paymentStatus = "Payment Cancelled";
          notifyListeners();
        })
      }
    });

    js.context.callMethod('Razorpay', [jsOptions]).callMethod('open');
  }

  // =======================
  // 🔹 MOBILE CALLBACKS
  // =======================
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    paymentStatus = "Payment Successful";
    onPaymentSuccessCallback?.call(response);
    _clearCallbacks();
    notifyListeners();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    paymentStatus = "Payment Failed: ${response.message}";
    onPaymentErrorCallback?.call(response);
    _clearCallbacks();
    notifyListeners();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    paymentStatus = "External Wallet Selected";
    onExternalWalletCallback?.call(response);
    _clearCallbacks();
    notifyListeners();
  }

  void _clearCallbacks() {
    onPaymentSuccessCallback = null;
    onPaymentErrorCallback = null;
    onExternalWalletCallback = null;
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _razorpay?.clear();
    }
    super.dispose();
  }
}
