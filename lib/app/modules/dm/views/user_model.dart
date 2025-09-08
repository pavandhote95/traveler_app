class UserModel {
  final int id;
  final String name;
  final String? image;

  UserModel({required this.id, required this.name, this.image});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image_url'], // API returns image_url
    );
  }
}
