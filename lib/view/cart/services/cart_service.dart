import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/coupon_model.dart';
import 'package:eatezy/model/customer_model.dart';
import 'package:eatezy/model/order_model.dart';
import 'package:eatezy/model/product_model.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:eatezy/view/cart/screens/success_screen.dart';
import 'package:eatezy/view/cart/services/payment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// Admin collection doc ID for platform settings.
const String _adminDocId = 'vcEyyBUUm5NAwliB3dTX';

class CartService extends ChangeNotifier {
  List<ProductModel> selectedProduct = [];
  List<VendorModel> vendors = [];
  CustomerModel? customer;
  List<CouponModel>? coupon;
  int? selectedCoupon;

  /// Platform charge from admin collection (platform_charge field).
  double? platformCharge;

  TextEditingController couponController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  Future<void> gettVendors() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('vendors').get();
      vendors = snapshot.docs.map((doc) {
        return VendorModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      await _fetchPlatformCharge();
      notifyListeners();
    } catch (e) {
      print('Error fetching vendor: $e');
    }
  }

  Future<void> _fetchPlatformCharge() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(_adminDocId)
          .get();
      if (doc.exists && doc.data() != null) {
        final value = doc.data()!['platform_charge'];
        if (value != null) {
          platformCharge = (value is num)
              ? value.toDouble()
              : double.tryParse(value.toString());
        }
      }
    } catch (e) {
      print('Error fetching platform charge: $e');
    }
  }

  Future<void> fetchCoupons() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('coupons').get();

      coupon = snapshot.docs.map((doc) {
        return CouponModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      notifyListeners();

      print(coupon!.first.code);
    } catch (_) {}
  }

  VendorModel? findVendorById(String id) {
    try {
      return vendors.firstWhere((vendor) => vendor.id == id);
    } catch (_) {
      return null;
    }
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

  bool isLoading = false;
  void addProduct(ProductModel product) {
    final index = selectedProduct.indexWhere((p) => p.id == product.id);

    if (index != -1) {
      selectedProduct[index].itemCount++;
    } else {
      product.itemCount = 1;
      selectedProduct.add(product);
    }

    notifyListeners();
  }

  void onItemRemove(int index) {
    if (selectedProduct[index].itemCount > 1) {
      selectedProduct[index].itemCount--;
    } else {
      selectedProduct.removeAt(index);
    }

    notifyListeners();
  }

  void applyCoupon(BuildContext context) async {
    final couponCode = couponController.text.trim();

    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid coupon code')),
      );
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: couponCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        couponController.clear();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid coupon code')),
        );
      } else {
        final couponData = querySnapshot.docs.first.data();
        final percentage = couponData['discount'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coupon applied! Discount: $percentage%'),
            backgroundColor: Colors.green,
          ),
        );
        onCouponSelected(int.parse(percentage.toString()));

        couponController.clear();
        Navigator.pop(context);
        // Do something with the discount percentage (e.g., apply to price)
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error applying coupon: ${e.toString()}')),
      );
    }
  }

  String getDiscountAmount(double totalAmount, double discountPercent) {
    double discount = totalAmount * discountPercent / 100;
    return '-₹${discount.toStringAsFixed(2)}';
  }

  void onCouponSelected(int coupon) {
    selectedCoupon = coupon;
    notifyListeners();
  }

  void onItemAdd(int index) {
    selectedProduct[index].itemCount++;
    notifyListeners();
  }

  void onItemDelete(int i) {
    selectedProduct.removeAt(i);
    notifyListeners();
  }

  /// Clears all items, coupon and notes from the cart.
  void clearCart() {
    selectedProduct.clear();
    selectedCoupon = null;
    notesController.clear();
    notifyListeners();
  }

  /// Returns the vendor ID of the first item in cart, or null if cart is empty.
  String? get cartVendorId =>
      selectedProduct.isNotEmpty ? selectedProduct.first.vendorID : null;

  /// Packing fee for the current cart's vendor (null or 0 when not applicable).
  double? get cartPackingFee {
    final id = cartVendorId;
    if (id == null) return null;
    final fee = findVendorById(id)?.packingFee;
    return fee != null ? double.tryParse(fee) : null;
  }

  /// Platform fee from admin settings (0 if not set).
  double get cartPlatformFee => platformCharge ?? 0.0;

  /// Adds product only if cart is empty or from same vendor. If cart has items
  /// from another restaurant, shows a dialog to either cancel or clear cart and add.
  Future<void> addProductWithVendorCheck(
      BuildContext context, ProductModel product) async {
    if (selectedProduct.isEmpty) {
      addProduct(product);
      return;
    }
    if (selectedProduct.first.vendorID == product.vendorID) {
      addProduct(product);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Different restaurant'),
        content: Text(
          'Your cart has items from ${selectedProduct.first.shopName}. '
          'You can only order from one restaurant at a time. '
          'Clear cart and add items from ${product.shopName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear & Add'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      clearCart();
      addProduct(product);
    }
  }

  /// Sum of (price × quantity) for all cart items (no discount, packing or delivery).
  double getSubtotal() {
    return selectedProduct.fold(
      0.0,
      (sum, product) => sum + (product.price * product.itemCount),
    );
  }

  double getTotalAmount(int deliveryCharge, int? discountPercentage) {
    double totalAmount = getSubtotal();

    if (discountPercentage != null) {
      double discountAmount = totalAmount * (discountPercentage / 100);
      totalAmount -= discountAmount;
    }

    if (deliveryCharge != 0) {
      totalAmount += deliveryCharge;
    }

    final packing = cartPackingFee;
    if (packing != null && packing > 0) {
      totalAmount += packing;
    }

    totalAmount += cartPlatformFee;

    return double.parse(totalAmount.toStringAsFixed(2));
  }

  BuildContext? _paymentContext;

  Future<void> buyNow(
      BuildContext context, List<ProductModel> selectedProduct) async {
    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your profile first')),
      );
      return;
    }

    final totalAmount = getTotalAmount(0, selectedCoupon);
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid order amount')),
      );
      return;
    }

    isLoading = true;
    notifyListeners();
    _paymentContext = context;

    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    paymentProvider.openCheckout(
      totalAmount,
      'EatEzy',
      'Food order payment',
      customerName: customer!.name,
      onSuccess: (_) => _placeOrderAndNavigate(),
      onError: (PaymentFailureResponse response) {
        isLoading = false;
        notifyListeners();
        if (_paymentContext != null && _paymentContext!.mounted) {
          ScaffoldMessenger.of(_paymentContext!).showSnackBar(
            SnackBar(
              content: Text(
                  'Payment failed: ${response.message ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _paymentContext = null;
      },
      onExternalWallet: (_) {
        isLoading = false;
        notifyListeners();
        if (_paymentContext != null && _paymentContext!.mounted) {
          ScaffoldMessenger.of(_paymentContext!).showSnackBar(
            const SnackBar(
                content: Text(
                    'Payment via external wallet is not supported for orders. Please use Razorpay.')),
          );
        }
        _paymentContext = null;
      },
    );
  }

  Future<void> _placeOrderAndNavigate() async {
    final context = _paymentContext;
    if (context == null || !context.mounted) return;

    Map<String, List<ProductModel>> productsByVendor = {};
    for (var product in selectedProduct) {
      productsByVendor.putIfAbsent(product.vendorID, () => []).add(product);
    }

    for (var entry in productsByVendor.entries) {
      String vendorId = entry.key;
      List<ProductModel> products = entry.value;

      List<OrderedProduct> orderedProducts = products.map((p) {
        return OrderedProduct(
          name: p.name,
          image: p.image,
          description: p.description,
          quantity: p.itemCount,
          price: p.price,
          unit: p.unit,
        );
      }).toList();

      OrderModel order = OrderModel(
          id: UniqueKey().toString(),
          uuid: FirebaseAuth.instance.currentUser!.uid,
          vendorId: vendorId,
          createdDate: DateTime.now().toString(),
          address: '',
          customerName: customer!.name,
          phone: FirebaseAuth.instance.currentUser!.phoneNumber!,
          isPaid: true,
          orderStatus: 'Waiting',
          deliveryBoyId: '',
          isDelivered: false,
          isCancelled: false,
          deliveryType: '',
          isRated: false,
          rating: 0,
          confimedTime: '',
          driverGoShopTime: '',
          orderPickedTime: '',
          onTheWayTime: '',
          orderDeliveredTime: '',
          deliveryCharge: 0,
          totalPrice: getTotalAmount(0, selectedCoupon).toString(),
          lat: findVendorById(vendorId)!.lat,
          long: findVendorById(vendorId)!.long,
          customerImage: customer!.image,
          vendorName: findVendorById(vendorId)!.shopName,
          shopImage: findVendorById(vendorId)!.shopImage,
          vendorPhone: findVendorById(vendorId)!.phone,
          chatId: '',
          products: orderedProducts,
          discount: selectedCoupon.toString(),
          notes: notesController.text.trim(),
          packingFee:
              double.tryParse(findVendorById(vendorId)?.packingFee ?? '0') ??
                  0.0,
          platformCharge: cartPlatformFee);

      final vendorFcm = findVendorById(vendorId)?.fcmToken;
      if (vendorFcm != null && vendorFcm.isNotEmpty) {
        sendFCMMessage(vendorFcm);
      }
      await FirebaseFirestore.instance.collection('cart').add(order.toMap());
    }

    isLoading = false;
    selectedCoupon = null;
    couponController.clear();
    notesController.clear();
    selectedProduct.clear();
    notifyListeners();
    _paymentContext = null;

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );
    }
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "eatezy-63f35",
      "private_key_id": "af3cd0df401e419c44d03a104fb0c8589e3dd76d",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCuo2sgQ68HULgN\nZfpIDdGZarPOB2NQsNNK/IiKzft60p8Qog37VhpOmtAYhstAYRO8RKBs77XprA2c\nabI8u5OVuHuVpfJ0muhWbDNjpTKTAK/JR+7kjLbAvBiv9o5fDn8cb7t7jhqEe3Xt\nnI621Lm8jpbnZr2YF/L+3W6gLzelAtsMJ945B45J65IrkTS8gC52R/YWMtIp4Lef\naz1WEpvSyBTpXARq2EhdoAjdGVARdGHQyN3AfOZEdfKnBalXOrVvtFpRX10045XM\nDZB/5d5B1+uNCmyF8zuwcCMt9nZdoN/wYwV8egnn4cNKwHEdJKIyn7rNwknWdHHz\nuiHh16Y3AgMBAAECggEATdHFVUHD11MpSNMl5YC+4wnQqKDTKSw6Y0JHx+6EvtTn\nC57i8xoJq/hBfYRnQr9fb3f3MsPYgJFqGUZiJb0CRWfJLkSd10cF/CjH94GwGSBn\ntJ4ovlBTyWun5pVMGOCZVL8XQLXwbBOl16V5VNBTGcpCRUgbeRBG+DoM5zVTKuRv\npxtiZ6sawrshbLjewX11J1tWglRcK3F3B3P+2KoYXDBujOjcvyy2jucJt9dzvkGr\nHUbJWdQ0zg9wfyxrlFncMR4JMCeCRx/8KkdxTFM5E6rJylRuWN9PQO7SWAtibtcv\nQWodNLs+0KYoffLkSpgusfegHsBLFcRNQBuf9mqfoQKBgQDfNI8ZQDncKIWPRb3a\nZb9rMzlBo0BlrGCjxsqttjiBDNosu4hErpurjG5FnMhgA5a9B/3dOarl+xVAwgVq\n39Y2tyan9m8U8xXTRpbX33LSdJFezGGLD+uLCEZIWpgsUaxixfEEvvicIvOd6nHg\nIlnUOFhcs1fALoqPc/nAzUzWIQKBgQDITBs2ffgE3/cP6YtRYHWj/9baX7ueSaJ4\nsRrqTbx+GVp9fRB/GSzOJ+8Pg0Lb0NvtOkeIIeRCehaw84FRXRhJaiSz6NeRINPu\n2VvHKtW2p1C25hj/ShI5zMq383V65wXFONhA8b9WuWPUTEBLBaqwA48qU9SPd6Bv\nBjue7czBVwKBgQC3NEzATRcwvZHipzvNpvYW51R3q6ePzI0F4IU7T/XQ9tudG9Ad\nj7P2eq2INcfCBzASuByHGG5Nlmk7XgVUU6VgA7SW6I8EgwHHCImHZsC4PTWUuezW\nV5rd40zM1o9Q0TjNWesaGiW1Anszgts1PPy+VAEzFYFRHOJeHLNCrUAEAQKBgQDB\nOBHEVm6MnVUjZ4L7BJdXlnS4AkPmZVgzH348arMb3e9aQOxJ/4omcYV/LHuxu2B9\nD4xzuWYN7uK23qBwUeMc5yTy3PoeyVFJBysvDZZOdkc5uOyCUP0V/wXLwDMjVXtO\njxCmTc7rpTm1Ub1v4c6Pr09LYMUbhSYiFBwtq26rTwKBgEektJZyozz9iRbfNTKp\nLCxKR0q/Sx/Cjp+uryqGRAMuXnWiDiPL0Ge37kg75CFi143DRfwF/2gqoFec7/e3\nW1FD4vn2GFPrd3ORpVR4ZAnYqlv3gEvGPyH84ZtWzwabIUPHHoVsoy/Ktu994Qvf\n0CG9SsrPYpHzMNSrJdUJoLvf\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@eatezy-63f35.iam.gserviceaccount.com",
      "client_id": "105045129822052618782",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40eatezy-63f35.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

  Future<void> sendFCMMessage(String token) async {
    final String serverKey = await getAccessToken(); // Your FCM server key

    final String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/eatezy-63f35/messages:send';
    // final currentFCMToken = await FirebaseMessaging.instance.getToken();

    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'body': 'Check your new Order!',
          'title': 'New Order Recived 🥳'
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
    }
  }
}
