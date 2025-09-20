class UserModel2 {
  final int userId;
  final String name;
  final String? profile;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  UserModel2({
    required this.userId,
    required this.name,
    this.profile,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory UserModel2.fromJson(Map<String, dynamic> json) {
    return UserModel2(
      userId: json['id'],
      name: json['name'] ?? "No Name",
      profile: json['image_url'], // API field
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
