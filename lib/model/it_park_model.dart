class ItParkModel {
  final String id;
  final String name;
  final String image;
  final String createdAt;
  final double lat;
  final double long;
  final bool isActive;
  final String lastEdited;

  ItParkModel({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.lat,
    required this.long,
    required this.isActive,
    required this.lastEdited,
  });

  factory ItParkModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ItParkModel(
      id: data['id'] ?? "",
      name: data['name'] ?? "",
      image: data['image'] ?? "",
      createdAt: data['createdAt']?.toString() ?? "",
      lat: (data['lat'] ?? 0).toDouble(),
      long: (data['long'] ?? 0).toDouble(),
      isActive: data['is_active'] ?? false,
      lastEdited: data['lastEdited']?.toString() ?? "",
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
    };
  }
}
