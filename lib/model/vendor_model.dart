class VendorModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  final String shopName;
  final String shopAddress;
  final String vendorImage;
  final String shopImage;
  bool isActive;
  bool isSuspend;
  final String estimateTime;
  final String estimateDistance;
  final String lat;
  final String long;
  final String locationAddress;
  final String banner;
  final String packingFee;
  final String openingTime;
  final String closingTime;

  /// Multiple time slots (e.g. 9:00–12:00, 17:00–22:00). Same format as product availability_slots.
  final List<Map<String, String>> openingHoursSlots;

  /// FCM token for push notifications (used in OSMTrackingScreen).
  final String fcmToken;

  VendorModel(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.phone,
      required this.email,
      required this.password,
      required this.shopName,
      required this.shopAddress,
      required this.vendorImage,
      required this.shopImage,
      required this.isActive,
      required this.isSuspend,
      required this.estimateTime,
      required this.estimateDistance,
      required this.lat,
      required this.long,
      required this.locationAddress,
      required this.banner,
      required this.packingFee,
      required this.openingTime,
      required this.closingTime,
      List<Map<String, String>>? openingHoursSlots,
      this.fcmToken = ''})
      : openingHoursSlots = openingHoursSlots ?? [];

  /// Earliest opening time across all slots (e.g. 9:00 for 9–12, 17–22).
  String get effectiveOpeningTime {
    if (openingHoursSlots.isEmpty) return openingTime;
    String? earliest;
    for (final slot in openingHoursSlots) {
      final from = slot['from'];
      if (from != null && from.isNotEmpty) {
        if (earliest == null || from.compareTo(earliest) < 0) earliest = from;
      }
    }
    return earliest ?? openingTime;
  }

  /// Latest closing time across all slots (e.g. 22:00 for 9–12, 17–22).
  String get effectiveClosingTime {
    if (openingHoursSlots.isEmpty) return closingTime;
    String? latest;
    for (final slot in openingHoursSlots) {
      final to = slot['to'];
      if (to != null && to.isNotEmpty) {
        if (latest == null || to.compareTo(latest) > 0) latest = to;
      }
    }
    return latest ?? closingTime;
  }

  /// Formatted string for multiple slots (e.g. "9:00–12:00, 17:00–22:00").
  String get openingHoursDisplay {
    if (openingHoursSlots.isEmpty) return '$openingTime – $closingTime';
    return openingHoursSlots
        .where((s) =>
            (s['from'] ?? '').isNotEmpty || (s['to'] ?? '').isNotEmpty)
        .map((s) => '${s['from'] ?? '?'} – ${s['to'] ?? '?'}')
        .join(', ');
  }

  /// True if current time is within any opening slot (e.g. 11:10pm when closes 11pm = false).
  bool get isCurrentlyOpen {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    if (openingHoursSlots.isEmpty) {
      final open = _parseMinutes(openingTime);
      final close = _parseMinutes(closingTime);
      return open != null &&
          close != null &&
          nowMinutes >= open &&
          nowMinutes < close;
    }

    for (final slot in openingHoursSlots) {
      final from = _parseMinutes(slot['from'] ?? '');
      final to = _parseMinutes(slot['to'] ?? '');
      if (from != null &&
          to != null &&
          nowMinutes >= from &&
          nowMinutes < to) {
        return true;
      }
    }
    return false;
  }

  /// Open for display = vendor active AND within opening hours.
  bool get isOpenForDisplay => isActive && isCurrentlyOpen;

  static int? _parseMinutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim());
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  factory VendorModel.fromFirestore(
    Map<String, dynamic> data,
    String id, {
    String? estimateDistance,
    String? estimateTime,
  }) {
    final legacyOpen = data['opening_time']?.toString() ?? '09:00';
    final legacyClose = data['closing_time']?.toString() ?? '22:00';
    List<Map<String, String>> slots = [];
    final rawSlots = data['opening_hours_slots'];
    if (rawSlots is List) {
      slots = rawSlots
          .whereType<Map>()
          .map((slot) => {
                'from': (slot['from'] ?? '').toString(),
                'to': (slot['to'] ?? '').toString(),
              })
          .where((slot) => slot['from']!.isNotEmpty || slot['to']!.isNotEmpty)
          .toList();
    }
    if (slots.isEmpty && (legacyOpen.isNotEmpty || legacyClose.isNotEmpty)) {
      slots = [
        {'from': legacyOpen, 'to': legacyClose}
      ];
    }
    return VendorModel(
        id: id,
        firstName: data['first_name'] ?? '',
        lastName: data['last_name'] ?? '',
        phone: data['phone'] ?? '',
        email: data['email'] ?? '',
        password: data['password'] ?? '',
        shopName: data['shop_name'] ?? '',
        shopAddress: data['shop_address'] ?? '',
        vendorImage: data['vendor_image'] ?? '',
        shopImage: data['shop_image'] ?? '',
        isActive: data['is_active'] ?? false,
        isSuspend: data['is_suspend'] ?? false,
        estimateDistance: estimateDistance ?? data['estimateDistance'] ?? '',
        estimateTime: estimateTime ?? data['estimateTime'] ?? '',
        lat: data['lat'] ?? '',
        long: data['long'] ?? '',
        locationAddress: data['location_address'] ?? '',
        banner: data['banner'] ?? '',
        packingFee: data['packing_fee']?.toString() ?? '0',
        openingTime: legacyOpen,
        closingTime: legacyClose,
        openingHoursSlots: slots.isNotEmpty ? slots : null,
        fcmToken: data['fcm_token']?.toString() ?? '');
  }
}
