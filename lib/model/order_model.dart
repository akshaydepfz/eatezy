class OrderModel {
  String id;
  String name;
  String image;
  String description;
  String category;
  String unit;
  int stock;
  int maxOrder;
  double price;
  double slashedPrice;
  int itemCount;
  String uuid;
  String vendorId;
  String createdDate;
  String customerName;
  String phone;
  String address;
  bool isPaid;
  String orderStatus;
  String deliveryBoyId;
  bool isDelivered;
  bool isCancelled;
  String deliveryType;
  bool isRated;
  double rating;
  String confimedTime;
  String driverGoShopTime;
  String orderPickedTime;
  String onTheWayTime;
  String orderDeliveredTime;
  int deliveryCharge;

  OrderModel(
      {required this.id,
      required this.name,
      required this.image,
      required this.description,
      required this.category,
      required this.unit,
      required this.stock,
      required this.maxOrder,
      required this.price,
      required this.slashedPrice,
      required this.itemCount,
      required this.uuid,
      required this.vendorId,
      required this.createdDate,
      required this.address,
      required this.customerName,
      required this.phone,
      required this.isPaid,
      required this.orderStatus,
      required this.deliveryBoyId,
      required this.isDelivered,
      required this.isCancelled,
      required this.deliveryType,
      required this.isRated,
      required this.rating,
      required this.confimedTime,
      required this.driverGoShopTime,
      required this.orderPickedTime,
      required this.onTheWayTime,
      required this.orderDeliveredTime,
      required this.deliveryCharge});

  // Create a factory method to map Firestore data to ProductModel
  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
        id: id,
        name: data['name'] ?? '',
        image: data['image'] ?? '',
        description: data['description'] ?? '',
        category: data['category'] ?? '',
        unit: data['unit'] ?? '',
        stock: data['stock'] != null ? int.parse(data['stock'].toString()) : 0,
        maxOrder: data['maxOrder'] != null
            ? int.parse(data['maxOrder'].toString())
            : 0,
        price: data['price'] != null
            ? (double.parse(data['price'].toString()))
            : 0.0,
        slashedPrice: data['slashedPrice'] != null
            ? double.parse(data['slashedPrice'].toString())
            : 0.0,
        itemCount: data['itemCount'],
        uuid: data['uuid'],
        vendorId: data['vendor_id'],
        createdDate: data['created_date'],
        customerName: data['customer_name'],
        phone: data['phone'],
        address: data['address'],
        isPaid: data['isPaid'],
        orderStatus: data['order_status'],
        deliveryBoyId: data['deliveryBoyId'] ?? '',
        isDelivered: data['isDelivered'] ?? false,
        isCancelled: data['isCancelled'] ?? false,
        deliveryType: data['delivery_type'] ?? "",
        isRated: data['is_rated'] ?? false,
        rating: data['star'] ?? 0,
        confimedTime: data['confrimTime'] ?? '',
        driverGoShopTime: data['driverShop'] ?? '',
        orderPickedTime: data['pickedTime'] ?? '',
        onTheWayTime: data['onTheWayTime'] ?? '',
        orderDeliveredTime: data['deliveredTime'] ?? '',
        deliveryCharge: data['delivery_charge'] ?? 0);
  } // Method to convert ProductModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'description': description,
      'category': category,
      'unit': unit,
      'stock': stock,
      'maxOrder': maxOrder,
      'price': price,
      'slashedPrice': slashedPrice,
      'itemCount': itemCount,
      'uuid': uuid,
      'vendor_id': vendorId,
      'created_date': createdDate,
      'customer_name': customerName,
      'phone': phone,
      'address': address,
      'isPaid': isPaid,
      'order_status': orderStatus,
      'deliveryBoyId': deliveryBoyId,
      'isDelivered': isDelivered,
      'isCancelled': isCancelled,
      'delivery_type': deliveryType,
      'delivery_charge': deliveryCharge
    };
  }
}
