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
  /// `true` = veg, `false` = non-veg, `null` = unknown/not provided.
  final bool? isVeg;

  bool get _isProbablyNonVeg {
    final text = '${name.trim()} ${category.trim()} ${description.trim()}'
        .toLowerCase();
    if (text.isEmpty) return false;

    // Strong non-veg keywords (keep conservative).
    const nonVegWords = <String>[
      'chicken',
      'mutton',
      'fish',
      'prawn',
      'prawns',
      'shrimp',
      'crab',
      'egg',
      'eggs',
      'keema',
      'lamb',
      'beef',
      'pork',
      'bacon',
      'pepperoni',
      'sausage',
      'salami',
      'tuna',
    ];

    for (final w in nonVegWords) {
      if (text.contains(w)) return true;
    }
    if (text.contains('non veg') ||
        text.contains('non-veg') ||
        text.contains('nonveg') ||
        text.contains('non_veg')) {
      return true;
    }
    return false;
  }

  bool get matchesVegFilter {
    if (isVeg == true) return true;
    if (isVeg == false) return false;
    // Unknown: treat as veg unless it strongly looks non-veg.
    return !_isProbablyNonVeg;
  }

  bool get matchesNonVegFilter {
    if (isVeg == false) return true;
    if (isVeg == true) return false;
    // Unknown: include if it strongly looks non-veg.
    return _isProbablyNonVeg;
  }

  /// Multiple time slots when product is available.
  /// Example: [{"from":"09:00","to":"11:00"},{"from":"18:00","to":"21:00"}]
  final List<Map<String, String>> availabilitySlots;

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
      this.isVeg,
      required this.availabilitySlots});

  /// True if product has time-based availability (either from or to is set).
  bool get hasTimeRestriction => availabilitySlots.isNotEmpty;

  /// True if product is currently available based on time window.
  /// When no time restriction, returns true.
  bool get isCurrentlyAvailable {
    if (!hasTimeRestriction) return true;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    for (final slot in availabilitySlots) {
      final from = _parseTimeToMinutes(slot['from'] ?? slot['start']);
      final to = _parseTimeToMinutes(slot['to'] ?? slot['end']);
      if (from == null || to == null) continue;

      // Normal same-day slot: from <= to (e.g. 09:00-11:00)
      if (from <= to && nowMinutes >= from && nowMinutes <= to) return true;

      // Overnight slot: from > to (e.g. 22:00-02:00)
      if (from > to && (nowMinutes >= from || nowMinutes <= to)) return true;
    }
    return false;
  }

  /// When product is not available due to time, returns the time it becomes available (e.g. "09:00").
  /// Returns null when product is available or has no time restriction.
  String? get availableAtTime {
    if (!hasTimeRestriction) return null;
    if (isCurrentlyAvailable) return null;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    int? bestDelta;
    String? bestStart;
    for (final slot in availabilitySlots) {
      final startRaw = (slot['from'] ?? slot['start'] ?? '').trim();
      if (startRaw.isEmpty) continue;
      final from = _parseTimeToMinutes(startRaw);
      if (from == null) continue;

      final delta = from >= nowMinutes ? from - nowMinutes : (24 * 60 - nowMinutes) + from;
      if (bestDelta == null || delta < bestDelta) {
        bestDelta = delta;
        bestStart = startRaw;
      }
    }
    return bestStart;
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
      isVeg: isVeg,
      availabilitySlots:
          availabilitySlots.map((slot) => Map<String, String>.from(slot)).toList(),
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
      isVeg: _parseIsVeg(data),
      availabilitySlots: _parseAvailabilitySlots(data),
    );
  }

  static bool? _parseIsVeg(Map<String, dynamic> data) {
    final keys = <String>[
      'is_veg',
      'isVeg',
      'veg',
      'is_non_veg',
      'isNonVeg',
      'non_veg',
      'nonVeg',
      'food_type',
      'foodType',
      'type',
    ];

    dynamic value;
    String foundKey = '';
    for (final k in keys) {
      if (data.containsKey(k) && data[k] != null) {
        value = data[k];
        foundKey = k;
        break;
      }
    }
    if (value == null) return null;

    if (value is bool) return value;

    final raw = value.toString().trim().toLowerCase();
    if (raw.isEmpty) return null;

    // Positive veg signals
    if (raw == 'true' ||
        raw == '1' ||
        raw == 'yes' ||
        raw == 'y' ||
        raw == 'veg' ||
        raw == 'vegetarian') {
      return true;
    }

    // Negative non-veg signals, including inverted boolean keys.
    if (raw == 'false' || raw == '0' || raw == 'no' || raw == 'n') {
      return false;
    }
    if (raw == 'nonveg' ||
        raw == 'non-veg' ||
        raw == 'non veg' ||
        raw == 'non_veg' ||
        raw == 'nv') {
      return false;
    }

    // If the matched key indicates non-veg, invert when it looks boolean-ish.
    if (foundKey == 'is_non_veg' ||
        foundKey == 'isNonVeg' ||
        foundKey == 'non_veg' ||
        foundKey == 'nonVeg') {
      if (raw == 'true' || raw == '1') return false;
      if (raw == 'false' || raw == '0') return true;
    }

    return null;
  }

  static List<Map<String, String>> _parseAvailabilitySlots(
      Map<String, dynamic> data) {
    final rawSlots = data['availability_slots'];
    if (rawSlots is List) {
      final slots = <Map<String, String>>[];
      for (final item in rawSlots) {
        if (item is! Map) continue;
        final rawFrom = (item['from'] ??
                item['start'] ??
                item['available_from_time'] ??
                item['from_time'] ??
                '')
            .toString()
            .trim();
        final rawTo =
            (item['to'] ?? item['end'] ?? item['available_to_time'] ?? item['to_time'] ?? '')
                .toString()
                .trim();
        if (rawFrom.isEmpty || rawTo.isEmpty) continue;
        slots.add({'from': rawFrom, 'to': rawTo});
      }
      if (slots.isNotEmpty) return slots;
    }

    // Backward compatibility: old single window fields.
    final from = data['available_from_time']?.toString().trim() ?? '';
    final to = data['available_to_time']?.toString().trim() ?? '';
    if (from.isNotEmpty && to.isNotEmpty) {
      return [
        {'from': from, 'to': to}
      ];
    }
    return [];
  }

  static int? _parseTimeToMinutes(String? rawTime) {
    if (rawTime == null) return null;
    final value = rawTime.trim().toLowerCase();
    if (value.isEmpty) return null;

    // Supports "09:00", "9:00", "9am", "9 am", "9:30pm", etc.
    final timeWithMeridiem = RegExp(r'^(\d{1,2})(?::(\d{1,2}))?\s*([ap]m)$');
    final match = timeWithMeridiem.firstMatch(value);
    if (match != null) {
      var hour = int.tryParse(match.group(1) ?? '');
      final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
      final meridiem = match.group(3);
      if (hour == null || minute < 0 || minute > 59 || hour < 1 || hour > 12) {
        return null;
      }
      if (meridiem == 'am') {
        if (hour == 12) hour = 0;
      } else if (hour != 12) {
        hour += 12;
      }
      return hour * 60 + minute;
    }

    final parts = value.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null ||
          minute == null ||
          hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        return null;
      }
      return hour * 60 + minute;
    }
    return null;
  }
}
