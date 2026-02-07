import 'package:flutter/material.dart';

abstract class PaymentProviderBase extends ChangeNotifier {
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
  });
}
