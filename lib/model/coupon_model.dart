import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String code;
  final int discount;
  final String createdAt;
  final bool isActive;
  final double? minOrderAmount;
  final int? maxUses;
  final int usedCount;

  CouponModel({
    required this.id,
    required this.code,
    required this.discount,
    required this.createdAt,
    this.isActive = true,
    this.minOrderAmount,
    this.maxUses,
    this.usedCount = 0,
  });

  /// Creates a Firestore map for adding a new coupon from the add form.
  static Map<String, dynamic> toAddMap({
    required String code,
    required int discount,
    bool isActive = true,
    double? minOrderAmount,
    int? maxUses,
  }) {
    return {
      'code': code.trim(),
      'discount': discount,
      'createdAt': FieldValue.serverTimestamp(),
      'is_active': isActive,
      if (minOrderAmount != null && minOrderAmount > 0) 'min_order_amount': minOrderAmount,
      if (maxUses != null && maxUses > 0) 'max_uses': maxUses,
      'used_count': 0,
    };
  }

  factory CouponModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CouponModel(
      id: id,
      code: data['code'] ?? '',
      discount: data['discount'] ?? 0,
      createdAt: _formatTimestamp(data['createdAt']),
      isActive: data['is_active'] ?? true,
      minOrderAmount: _toDouble(data['min_order_amount']),
      maxUses: data['max_uses'] != null ? int.tryParse(data['max_uses'].toString()) : null,
      usedCount: data['used_count'] ?? 0,
    );
  }

  static String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is Timestamp) return timestamp.toDate().toIso8601String();
    return timestamp.toString();
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discount': discount,
      'createdAt': createdAt.isNotEmpty
          ? Timestamp.fromDate(DateTime.parse(createdAt))
          : FieldValue.serverTimestamp(),
      'is_active': isActive,
      if (minOrderAmount != null) 'min_order_amount': minOrderAmount,
      if (maxUses != null) 'max_uses': maxUses,
      'used_count': usedCount,
    };
  }

  bool get isExpired => maxUses != null && usedCount >= maxUses!;
}
