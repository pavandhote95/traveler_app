import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/modules/chat/views/chat_view.dart';

class ChatController extends GetxController {
  final box = GetStorage();

  /// Messages list
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  /// Add message instantly (optimistic UI)
  void addLocalMessage(Map<String, dynamic> msg) {
    messages.insert(0, msg); // reverse list
  }

  /// Fetch messages from API
  Future<void> fetchMessages(String receiverId) async {
    final userId = box.read('user_id').toString();
    final token = box.read('token');
    if (token == null) return;

    try {
      final request = http.MultipartRequest(
          'POST',
          Uri.parse(
              "https://kotiboxglobaltech.com/travel_app/api/messages"))
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..fields['sender_id'] = userId
        ..fields['receiver_id'] = receiverId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          messages.value = List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print("⚠️ Fetch exception: $e");
    }
  }

  /// Send message instantly (optimistic UI)
  Future<void> sendMessageApi({
    required String receiverId,
    required String message,
    String messageType = "text",
  }) async {
    final userId = box.read('user_id').toString();
    final token = box.read('token');
    if (token == null) return;

    // Instant UI update
    addLocalMessage({
      "sender_id": userId,
      "receiver_id": receiverId,
      "message": message,
      "created_at": DateTime.now().toIso8601String(),
      "is_read": 0,
    });

    // Send to server
    try {
      final request = http.MultipartRequest(
          'POST',
          Uri.parse(
              "https://kotiboxglobaltech.com/travel_app/api/messages/send"))
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..fields['receiver_id'] = receiverId
        ..fields['sender_id'] = userId
        ..fields['message'] = message
        ..fields['message_type'] = messageType;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          // Refresh immediately
          await fetchMessages(receiverId);
        }
      }
    } catch (e) {
      print("⚠️ Send exception: $e");
    }
  }

  /// Fast Stream (poll every 1 second using async* and yield)
  Stream<List<Map<String, dynamic>>> messageStream(String receiverId) async* {
    while (true) {
      await fetchMessages(receiverId); // fast fetch
      yield messages;
      await Future.delayed(const Duration(seconds: 1)); // fast polling
    }
  }

  /// Generate unique chatId
  String getChatId(dynamic userA, dynamic userB) {
    final idA = userA.toString();
    final idB = userB.toString();
    return idA.hashCode <= idB.hashCode ? '${idA}_$idB' : '${idB}_$idA';
  }

  /// Start chat with user and navigate to ChatView
/// Start chat with user and navigate to ChatView
void startChatWithUser(Map<String, dynamic> otherUserProfile) {
  final currentUserId = box.read('user_id').toString();
  final otherUserId = otherUserProfile['id'].toString();
  final otherUserName = otherUserProfile['name'] ?? "Unknown";
  final otherUserImage = otherUserProfile['profile'] ?? "";
  final chatId = getChatId(currentUserId, otherUserId);

  // ✅ Debug prints for terminal
  print("========= Chat Debug Info =========");
  print("Current User ID: $currentUserId");
  print("Other User ID: $otherUserId");
  print("Other User Name: $otherUserName");
  print("Other User Image: $otherUserImage");
  print("Generated Chat ID: $chatId");
  print("===================================");

  Get.to(() => ChatView(
        currentUser: currentUserId,
        otherUser: otherUserName,
        otherUserImage: otherUserImage,
        otherUserId: otherUserId,
        chatId: chatId,
      ));
}
}