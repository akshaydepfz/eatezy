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
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// Admin collection doc ID for platform settings.
const String _adminDocId = 'vcEyyBUUm5NAwliB3dTX';

/// Online payment transaction fee (2.5%). Applied to amount when paying online.
const double kOnlineTransactionFeePercent = 2.5;

class CartService extends ChangeNotifier {
  List<ProductModel> selectedProduct = [];
  List<VendorModel> vendors = [];
  CustomerModel? customer;
  List<CouponModel>? coupon;
  CouponModel? selectedCoupon;

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
        const SnackBar(content: Text('Please enter a valid coupon code')),
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
        if (context.mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid coupon code')),
        );
        return;
      }

      final doc = querySnapshot.docs.first;
      final couponModel = CouponModel.fromFirestore(
        doc.data(),
        doc.id,
      );

      if (!couponModel.isActive) {
        if (context.mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This coupon is no longer active')),
        );
        return;
      }

      if (couponModel.isExpired) {
        if (context.mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('This coupon has reached its usage limit')),
        );
        return;
      }

      final subtotal = getSubtotal();
      if (couponModel.minOrderAmount != null &&
          subtotal < couponModel.minOrderAmount!) {
        if (context.mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Minimum order amount is ₹${couponModel.minOrderAmount!.toStringAsFixed(0)}',
            ),
          ),
        );
        return;
      }

      onCouponSelected(couponModel);
      couponController.clear();
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon applied! Discount: ${couponModel.discount}%'),
          backgroundColor: Colors.green,
        ),
      );
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

  void onCouponSelected(CouponModel? coupon) {
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

  double getTotalAmount(int deliveryCharge, CouponModel? appliedCoupon) {
    double totalAmount = getSubtotal();

    if (appliedCoupon != null) {
      final discountAmount = totalAmount * (appliedCoupon.discount / 100);
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

  /// Set before placing order: 'cod' or 'online'. Used for deliveryType in OrderModel.
  String _deliveryTypeForOrder = '';

  /// ISO8601 string for scheduled delivery. Empty = immediate order.
  String _scheduledFor = '';

  void setScheduledFor(String dateTime) {
    _scheduledFor = dateTime;
    notifyListeners();
  }

  void clearScheduledFor() {
    _scheduledFor = '';
    notifyListeners();
  }

  String get scheduledFor => _scheduledFor;

  Future<void> buyNow(
      BuildContext context, List<ProductModel> selectedProduct) async {
    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your profile first')),
      );
      return;
    }

    final baseAmount = getTotalAmount(0, selectedCoupon);
    if (baseAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid order amount')),
      );
      return;
    }

    final totalAmount = baseAmount * (1 + kOnlineTransactionFeePercent / 100);

    isLoading = true;
    notifyListeners();
    _paymentContext = context;
    _deliveryTypeForOrder = 'online';

    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    paymentProvider.openCheckout(
      totalAmount,
      'EatEzy',
      'Food order payment',
      customerName: customer!.name,
      onSuccess: (_) => _placeOrderAndNavigate(),
      onError: (dynamic response) {
        isLoading = false;
        notifyListeners();
        if (_paymentContext != null && _paymentContext!.mounted) {
          final message = response is Map
              ? (response['message']?.toString() ?? "Unknown error")
              : (response?.message?.toString() ?? "Unknown error");
          ScaffoldMessenger.of(_paymentContext!).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $message'),
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

  /// Places order with Cash on Delivery (no online payment). Navigates to success.
  Future<void> placeOrderWithCod(BuildContext context) async {
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
    _deliveryTypeForOrder = 'cod';
    await _placeOrderAndNavigate(isPaid: false);
  }

  Future<void> _placeOrderAndNavigate({bool isPaid = true}) async {
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

      final baseAmount = getTotalAmount(0, selectedCoupon);
      final transactionFee = _deliveryTypeForOrder == 'online'
          ? baseAmount * (kOnlineTransactionFeePercent / 100)
          : 0.0;

      OrderModel order = OrderModel(
          id: UniqueKey().toString(),
          uuid: FirebaseAuth.instance.currentUser!.uid,
          vendorId: vendorId,
          createdDate: DateTime.now().toString(),
          scheduledFor: _scheduledFor,
          isScheduled: _scheduledFor.isNotEmpty,
          address: '',
          customerName: customer!.name,
          phone: customer!.phoneNumber,
          isPaid: isPaid,
          orderStatus: 'Waiting',
          deliveryBoyId: '',
          isDelivered: false,
          isCancelled: false,
          deliveryType:
              _deliveryTypeForOrder.isNotEmpty ? _deliveryTypeForOrder : '',
          isRated: false,
          rating: 0,
          confimedTime: '',
          driverGoShopTime: '',
          orderPickedTime: '',
          onTheWayTime: '',
          orderDeliveredTime: '',
          deliveryCharge: 0,
          totalPrice: baseAmount.toStringAsFixed(2),
          transactionFee: transactionFee,
          lat: findVendorById(vendorId)!.lat,
          long: findVendorById(vendorId)!.long,
          customerImage: customer!.image,
          vendorName: findVendorById(vendorId)!.shopName,
          shopImage: findVendorById(vendorId)!.shopImage,
          vendorPhone: findVendorById(vendorId)!.phone,
          chatId: '',
          products: orderedProducts,
          discount: selectedCoupon?.discount.toString() ?? '0',
          notes: notesController.text.trim(),
          packingFee:
              double.tryParse(findVendorById(vendorId)?.packingFee ?? '0') ??
                  0.0,
          platformCharge: cartPlatformFee);

      final vendorFcm = findVendorById(vendorId)?.fcmToken;
      if (vendorFcm != null && vendorFcm.isNotEmpty) {
        // sendFCMMessage(vendorFcm);
      }
      await FirebaseFirestore.instance.collection('cart').add(order.toMap());
    }

    isLoading = false;
    selectedCoupon = null;
    couponController.clear();
    notesController.clear();
    selectedProduct.clear();
    _deliveryTypeForOrder = '';
    _scheduledFor = '';
    notifyListeners();
    _paymentContext = null;

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );
    }
  }
}
