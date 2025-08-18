class ApiPostModel {
  final int id;
  final String question;
  final String location;
  final String status;
  final List<String> images;
  final int userId;
  final List<int> postIds;
  final String createdAt;

  ApiPostModel({
    required this.id,
    required this.question,
    required this.location,
    required this.status,
    required this.images,
    required this.userId,
    required this.postIds,
    required this.createdAt,
  });

  factory ApiPostModel.fromJson(Map<String, dynamic> json) {
    return ApiPostModel(
      id: _parseInt(json['id']),
      question: json['question'] as String? ?? '',
      location: json['location'] as String? ?? '',
      status: json['status'] as String? ?? '',
      images: (json['image'] as List<dynamic>?)?.cast<String>() ?? [],
      userId: _parseInt(json['user_id']),
      postIds: (json['post_id'] as List<dynamic>?)
          ?.map((e) => _parseInt(e))
          .toList() ??
          [],
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'location': location,
      'status': status,
      'image': images,
      'user_id': userId,
      'post_id': postIds,
      'created_at': createdAt,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
