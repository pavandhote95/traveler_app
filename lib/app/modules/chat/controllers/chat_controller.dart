import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/modules/chat/views/chat_view.dart';

class ChatController extends GetxController {
  final box = GetStorage();

  /// messages list
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  /// Fetch all messages from API
  Future<void> fetchMessages(dynamic receiverId) async {
    final userId = box.read('user_id').toString();
    final token = box.read('token');
    final url = Uri.parse("https://kotiboxglobaltech.com/travel_app/api/messages");

    if (token == null) {
      print("⚠️ Error: Token not found");
      return;
    }

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..fields['sender_id'] = userId
        ..fields['receiver_id'] = receiverId.toString();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          messages.value = List<Map<String, dynamic>>.from(data['data']);
        } else {
          print("❌ Fetch error: ${data['message']}");
        }
      } else {
        print("❌ HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Exception: $e");
    }
  }

  /// Send message
  Future<void> sendMessageApi({
    required dynamic receiverId,
    required dynamic message,
    dynamic messageType = "text",
  }) async {
    final url = Uri.parse("https://kotiboxglobaltech.com/travel_app/api/messages/send");
    final token = box.read('token');
    final userId = box.read('user_id').toString();

    if (token == null) {
      print("⚠️ Error: Token not found");
      return;
    }

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..fields['receiver_id'] = receiverId.toString()
        ..fields['sender_id'] = userId
        ..fields['message'] = message.toString()
        ..fields['message_type'] = messageType.toString();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          fetchMessages(receiverId); // refresh
        } else {
          print("❌ Error sending: ${data['message']}");
        }
      }
    } catch (e) {
      print("⚠️ Exception sending message: $e");
    }
  }

  /// Start chat with user and navigate to ChatView
  void startChatWithUser(Map<String, dynamic> otherUserProfile) {
    final currentUserId = box.read('user_id').toString();
    final otherUserId = otherUserProfile['id'];
    final otherUserName = otherUserProfile['name'] ?? "Unknown";
    final otherUserImage = otherUserProfile['image_url'] ?? "";
    final chatId = getChatId(currentUserId, otherUserId);

    Get.to(
      () => ChatView(
        currentUser: currentUserId,
        otherUser: otherUserName,
        otherUserImage: otherUserImage,
        chatId: chatId,
      ),
    );
  }

  /// Polling Stream for messages
  Stream<List<Map<String, dynamic>>> messageStream(String receiverId) async* {
    while (true) {
      await fetchMessages(receiverId);
      await Future.delayed(const Duration(seconds: 3));
      yield messages;
    }
  }

  /// Generate unique chatId
  String getChatId(dynamic userA, dynamic userB) {
    final idA = userA.toString();
    final idB = userB.toString();
    return idA.hashCode <= idB.hashCode ? '${idA}_$idB' : '${idB}_$idA';
  }
}
