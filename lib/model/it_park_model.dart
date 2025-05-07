class ItParkModel {
  final String id;
  final String name;
  final String image;
  final String createdAt;
  final double lat;
  final double long;
  final bool isActive;
  final String lastEdited;
  final String estimateDistance; // in km, e.g. "5.30 km"
  final String estimateTime; // e.g. "8 mins"

  ItParkModel({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.lat,
    required this.long,
    required this.isActive,
    required this.lastEdited,
    required this.estimateDistance,
    required this.estimateTime,
  });

  factory ItParkModel.fromFirestore(
    Map<String, dynamic> data,
    String docId,
    String estimateDistance,
    String estimateTime,
  ) {
    return ItParkModel(
      id: data['id'] ?? docId,
      name: data['name'] ?? "",
      image: data['image'] ?? "",
      createdAt: data['createdAt']?.toString() ?? "",
      lat: (data['lat'] ?? 0).toDouble(),
      long: (data['long'] ?? 0).toDouble(),
      isActive: data['is_active'] ?? false,
      lastEdited: data['lastEdited']?.toString() ?? "",
      estimateDistance: estimateDistance,
      estimateTime: estimateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'createdAt': createdAt,
      'lat': lat,
      'long': long,
      'is_active': isActive,
      'lastEdited': lastEdited,
      'estimateDistance': estimateDistance,
      'estimateTime': estimateTime,
    };
  }
}
