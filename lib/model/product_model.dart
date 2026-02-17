class ProductModel {
  String id;
  String name;
  String image;
  String description;
  String category;
  String unit;
  int stock;
  int maxOrder;
  double price;
  String slashedPrice;
  String unitPerItem;
  int itemCount;
  String vendorID;
  String shopName;
  bool isActive;

  /// Time when product becomes available (e.g. "09:00"). Null = no restriction.
  String? availableFromTime;

  /// Time when product becomes unavailable (e.g. "18:00"). Null = no restriction.
  String? availableToTime;

  ProductModel(
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
      required this.unitPerItem,
      required this.itemCount,
      required this.shopName,
      required this.isActive,
      required this.vendorID,
      this.availableFromTime,
      this.availableToTime});

  /// True if product has time-based availability (either from or to is set).
  bool get hasTimeRestriction =>
      (availableFromTime != null && availableFromTime!.isNotEmpty) ||
      (availableToTime != null && availableToTime!.isNotEmpty);

  /// True if product is currently available based on time window.
  /// When no time restriction, returns true.
  bool get isCurrentlyAvailable {
    if (!hasTimeRestriction) return true;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    if (availableFromTime != null && availableFromTime!.isNotEmpty) {
      final parts = availableFromTime!.split(':');
      if (parts.length >= 2) {
        final fromMinutes =
            (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
        if (nowMinutes < fromMinutes) return false;
      }
    }
    if (availableToTime != null && availableToTime!.isNotEmpty) {
      final parts = availableToTime!.split(':');
      if (parts.length >= 2) {
        final toMinutes =
            (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
        if (nowMinutes > toMinutes) return false;
      }
    }
    return true;
  }

  /// When product is not available due to time, returns the time it becomes available (e.g. "09:00").
  /// Returns null when product is available or has no time restriction.
  String? get availableAtTime {
    if (!hasTimeRestriction) return null;
    if (isCurrentlyAvailable) return null;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    if (availableFromTime != null && availableFromTime!.isNotEmpty) {
      final parts = availableFromTime!.split(':');
      if (parts.length >= 2) {
        final fromMinutes =
            (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
        if (nowMinutes < fromMinutes) return availableFromTime;
      }
    }
    if (availableToTime != null && availableToTime!.isNotEmpty) {
      final parts = availableToTime!.split(':');
      if (parts.length >= 2) {
        final toMinutes =
            (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
        if (nowMinutes > toMinutes) return availableFromTime ?? availableToTime;
      }
    }
    return null;
  }

  /// True when product can be added to cart (active + within time window).
  bool get isClickable => isActive && isCurrentlyAvailable;

  /// Returns a copy with updated price and slashedPrice (e.g. for applying an offer).
  ProductModel copyWithPrice(
      {required double price, required String slashedPrice}) {
    return ProductModel(
      id: id,
      name: name,
      image: image,
      description: description,
      category: category,
      unit: unit,
      stock: stock,
      maxOrder: maxOrder,
      price: price,
      slashedPrice: slashedPrice,
      unitPerItem: unitPerItem,
      itemCount: itemCount,
      shopName: shopName,
      vendorID: vendorID,
      isActive: isActive,
      availableFromTime: availableFromTime,
      availableToTime: availableToTime,
    );
  }

  // Create a factory method to map Firestore data to ProductModel
  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      unit: data['unit'] ?? '',
      stock: data['stock'] != "" ? int.parse(data['stock'].toString()) : 0,
      maxOrder:
          data['maxOrder'] != "" ? int.parse(data['maxOrder'].toString()) : 0,
      price:
          data['price'] != null ? double.parse(data['price'].toString()) : 0.0,
      slashedPrice: data['slashedPrice'],
      unitPerItem: data['unitPerItem'] ?? "",
      itemCount: data['item_count'] ?? 0,
      vendorID: data['vendor_id'] ?? '',
      shopName: data['shop_name'] ?? '',
      isActive: data['is_active'] == null
          ? true
          : (data['is_active'] is bool
              ? data['is_active'] as bool
              : data['is_active'].toString().toLowerCase() == 'true'),
      availableFromTime:
          data['available_from_time']?.toString().trim().isNotEmpty == true
              ? data['available_from_time'].toString()
              : null,
      availableToTime:
          data['available_to_time']?.toString().trim().isNotEmpty == true
              ? data['available_to_time'].toString()
              : null,
    );
  }
}
