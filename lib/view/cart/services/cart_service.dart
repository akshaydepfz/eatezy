import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/order_model.dart';
import 'package:eatezy/model/product_model.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:eatezy/view/cart/screens/success_screen.dart';
import 'package:flutter/material.dart';

class CartService extends ChangeNotifier {
  List<ProductModel> selectedProduct = [];
  List<VendorModel> vendors = [];

  Future<void> gettVendors() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('vendors').get();
      vendors = snapshot.docs.map((doc) {
        return VendorModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching vendor: $e');
    }
  }

  VendorModel? findVendorById(String id) {
    return vendors.firstWhere(
      (vendor) => vendor.id == id,
    );
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

  void onItemAdd(int index) {
    selectedProduct[index].itemCount++;
    notifyListeners();
  }

  void onItemDelete(int i) {
    selectedProduct.removeAt(i);
    notifyListeners();
  }

  double getTotalAmount(int deliveryCharge, int? discountPercentage) {
    double totalAmount = selectedProduct.fold(
      0.0,
      (sum, product) => sum + (product.price * product.itemCount),
    );

    if (discountPercentage != null) {
      double discountAmount = totalAmount * (discountPercentage / 100);
      totalAmount -= discountAmount;
    }

    if (deliveryCharge != 0) {
      totalAmount += deliveryCharge;
    }

    return double.parse(totalAmount.toStringAsFixed(2));
  }

  Future<void> buyNow(
      BuildContext context, List<ProductModel> selectedProduct) async {
    isLoading = true;
    notifyListeners();

    for (var v in selectedProduct) {
      OrderModel order = OrderModel(
          isRated: false,
          rating: 0,
          deliveryType: '',
          id: v.id,
          name: v.name,
          image: v.image,
          description: v.description,
          category: v.category,
          unit: v.unit,
          stock: v.stock,
          maxOrder: v.maxOrder,
          price: v.price,
          slashedPrice: double.parse(v.slashedPrice),
          itemCount: v.itemCount,
          uuid: 'FirebaseAuth.instance.currentUser!.uid',
          createdDate: DateTime.now().toString(),
          address: "",
          customerName: '',
          phone: '',
          isPaid: false,
          orderStatus: 'Waiting',
          deliveryBoyId: '',
          isDelivered: false,
          isCancelled: false,
          confimedTime: '',
          driverGoShopTime: '',
          onTheWayTime: '',
          orderDeliveredTime: '',
          orderPickedTime: '',
          lat: findVendorById(v.vendorID)!.lat,
          long: findVendorById(v.vendorID)!.long,
          deliveryCharge: 0,
          vendorId: v.vendorID,
          customerImage:
              'https://firebasestorage.googleapis.com/v0/b/eatezy-63f35.firebasestorage.app/o/shop_images%2F1745138722748.jpg?alt=media&token=4a8312a1-9e25-44ad-9deb-faaf9d01b72c',
          shopImage: findVendorById(v.vendorID)!.shopImage,
          vendorName: findVendorById(v.vendorID)!.shopName,
          vendorPhone: findVendorById(v.vendorID)!.phone,
          chatId: '');
      // String fcm = await getAdminFcmToken() ?? "";
      // sendFCMMessage(fcm);
      await FirebaseFirestore.instance.collection('cart').add(order.toMap());
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SuccessScreen()));
  }
}
