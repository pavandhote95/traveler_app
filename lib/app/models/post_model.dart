class ApiPostModel {
  final int id;
  final String question;
  final String location;
  final String status;
  final List<String> images;
  final int userId;
  final List<int> postIds;
  final String createdAt;

  final int likesCount;
  final int dislikesCount;
  final bool isLiked;
  final bool isDisliked;

  ApiPostModel({
    required this.id,
    required this.question,
    required this.location,
    required this.status,
    required this.images,
    required this.userId,
    required this.postIds,
    required this.createdAt,
    required this.likesCount,
    required this.dislikesCount,
    required this.isLiked,
    required this.isDisliked,
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
      likesCount: _parseInt(json['likes_count']),
      dislikesCount: _parseInt(json['dislikes_count']),
      isLiked: _parseInt(json['is_liked']) == 1,
      isDisliked: _parseInt(json['is_disliked']) == 1,
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
      'likes_count': likesCount,
      'dislikes_count': dislikesCount,
      'is_liked': isLiked ? 1 : 0,
      'is_disliked': isDisliked ? 1 : 0,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  ApiPostModel copyWith({
    int? id,
    String? question,
    String? location,
    String? status,
    List<String>? images,
    int? userId,
    List<int>? postIds,
    String? createdAt,
    int? likesCount,
    int? dislikesCount,
    bool? isLiked,
    bool? isDisliked,
  }) {
    return ApiPostModel(
      id: id ?? this.id,
      question: question ?? this.question,
      location: location ?? this.location,
      status: status ?? this.status,
      images: images ?? this.images,
      userId: userId ?? this.userId,
      postIds: postIds ?? this.postIds,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
    );
  }
}
