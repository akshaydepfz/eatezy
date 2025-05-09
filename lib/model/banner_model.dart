class BannerModel {
  final String image;
  final String id;
  final String createddate;

  BannerModel(
      {required this.image, required this.id, required this.createddate});

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
      image: json['image'], id: json['id'], createddate: json['created_date']);
}
