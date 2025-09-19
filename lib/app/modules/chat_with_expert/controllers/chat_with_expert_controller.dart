import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ChatWithExpertController extends GetxController {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final box = GetStorage();

  var messages = <Map<String, dynamic>>[].obs;
  var isSending = false.obs;
  var isLoading = false.obs;

  late int expertId;
  late String userId;

@override
void onInit() {
  super.onInit();
  final args = Get.arguments ?? {};
  expertId = args['expertId'] ?? 0;
  userId = box.read("user_id").toString();

  // 🔹 Print expertId for debugging
  print("👨‍💼 Expert ID: $expertId");

  if (expertId != 0) {
    fetchMessages(expertId);
  }
}

  /// 🔹 Fetch messages API (needs sender_id + receiver_id)
  Future<void> fetchMessages(int receiverId) async {
    try {
      isLoading.value = true;
      final token = box.read("token");
      if (token == null) {
        Get.snackbar("Error", "Auth token not found");
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("https://kotiboxglobaltech.com/travel_app/api/messages"),
      )
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..fields['sender_id'] = userId
        ..fields['receiver_id'] = receiverId.toString();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📩 Fetch Response Code: ${response.statusCode}");
      print("📩 Fetch Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == true ) {
          final serverMessages = List<Map<String, dynamic>>.from(data["data"]);

          // Convert created_at to local time
          for (var msg in serverMessages) {
            if (msg['created_at'] != null) {
              msg['created_at'] =
                  DateTime.parse(msg['created_at']).toLocal().toIso8601String();
            }
          }

          messages.assignAll(
            serverMessages.map((msg) => {
                  "sender": msg["sender_id"].toString(),
                  "text": msg["message"],
                  "time": msg["created_at"],
                }),
          );

          scrollToBottom();
        } else {
          print("⚠️ No messages found");
        }
      } else {
        Get.snackbar("Error", "Failed to load messages");
      }
    } catch (e) {
      print("🔥 Exception in fetchMessages: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Send message API
  Future<void> sendMessageToExpert({
    required int receiverId,
    required String message,
    String messageType = "text",
  }) async {
    if (message.trim().isEmpty) return;

    // Optimistic UI
    messages.add({"sender": userId, "text": message.trim(), "time": "Now"});
    messageController.clear();
    scrollToBottom();

    try {
      isSending.value = true;
      final token = box.read("token");
      if (token == null) {
        Get.snackbar("Error", "Auth token not found");
        return;
      }

      final url = Uri.parse(
          "https://kotiboxglobaltech.com/travel_app/api/expert-messages/send");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "receiver_id": receiverId.toString(),
          "sender_id": userId,
          "message": message,
          "message_type": messageType,
        },
      );

      print("📤 Send Response: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data["status"] == true) {
          Fluttertoast.showToast(msg: "Message Sent ✅");
          // Refresh after sending
          await fetchMessages(receiverId);
        } else {
          Get.snackbar("Error", data["message"] ?? "Failed to send");
        }
      } else {
        Get.snackbar("Error", "Failed to send message (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSending.value = false;
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }
}
