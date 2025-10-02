import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/constants/api_url.dart';
import 'package:travel_app2/app/modules/expert_user_profile/controllers/expert_user_profile_controller.dart';

class TalkToTravellersChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var selectedRating = 0.obs;

  final box = GetStorage();

  late int travellerId;
  late String travellerName;
  late String? travellerImage;
  late int myUserId;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    travellerId = args["travellerId"];
    travellerName = args["travellerName"];
    travellerImage = args["travellerImage"];
    myUserId = box.read("user_id") ?? 0;

    fetchChat();
  }

  /// Fetch chat messages
  Future<void> fetchChat() async {
    try {
      isLoading.value = true;
      final token = box.read('token') ?? '';

      final response = await http.post(
        Uri.parse(ApiUrls.fetchChatMessages),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "receiver_id": travellerId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == true) {
          List<Map<String, dynamic>> newMessages =
              List<Map<String, dynamic>>.from(data["data"]);

          for (var msg in newMessages) {
            addNewMessage(msg); // ✅ Add with automatic rating check
          }
        }
      }
    } catch (e) {
      print("❌ Error fetching chat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Add new message and show rating if chat ended
  void addNewMessage(Map<String, dynamic> msg) {
    messages.add(msg);

    // ✅ Automatically show rating if expert ended chat
    if (msg["message_type"] == "system" &&
        (msg["message"] ?? "").toLowerCase().contains("chat ended")) {
      _showRatingDialog();
    }
  }

  /// Send message
  Future<void> sendMessageToExpert({
    required int receiverId,
    required String message,
    String messageType = "text",
  }) async {
    if (message.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Message cannot be empty");
      return;
    }

    try {
      isSending.value = true;
      final token = box.read('token');
      if (token == null) {
        Fluttertoast.showToast(msg: "Please login first");
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiUrls.sendMessage),
      );

      request.fields.addAll({
        'receiver_id': receiverId.toString(),
        'message': message,
        'message_type': messageType,
      });

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final data = jsonDecode(responseString);

      if (response.statusCode == 201 && data["status"] == true) {
        addNewMessage({
          "sender_id": myUserId,
          "receiver_id": receiverId,
          "message": message,
          "message_type": messageType,
          "created_at": DateTime.now().toIso8601String(),
        });
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Failed to send message");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to send message");
      print("❌ Error sending message: $e");
    } finally {
      isSending.value = false;
    }
  }

  /// End chat manually (expert or user)
  Future<void> endChat() async {
    try {
      final token = box.read("token");
      if (token == null) {
        Fluttertoast.showToast(msg: "Please login again");
        return;
      }

      final response = await http.post(
        Uri.parse(ApiUrls.endChat),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "user_id": travellerId.toString(),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        Fluttertoast.showToast(msg: "Chat ended successfully");

        // ✅ Show rating immediately if user
        if (box.read("user_type") == "user") {
          _showRatingDialog();
        }
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Failed to end chat");
      }
    } catch (e) {
      print("❌ Error ending chat: $e");
      Fluttertoast.showToast(msg: "Error ending chat");
    }
  }

  /// ⭐ Rating Dialog
  void _showRatingDialog() {
    if (Get.isDialogOpen ?? false) return; // Prevent multiple dialogs
    selectedRating.value = 0;

    Get.dialog(
      AlertDialog(
        title: const Text("⭐ Rate your Experience"),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please give a rating for your chat."),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < selectedRating.value
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.orange,
                      size: 36,
                    ),
                    onPressed: () {
                      selectedRating.value = index + 1;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedRating.value == 0) {
                Fluttertoast.showToast(msg: "Please select a rating first");
                return;
              }

              Get.back(); // close dialog first
              final token = box.read("token") ?? '';
              if (token.isEmpty) {
                Fluttertoast.showToast(msg: "Please login first");
                return;
              }

              try {
                final response = await http.post(
                  Uri.parse(
                      "https://kotiboxglobaltech.com/travel_app/api/add-rating/experts"),
                  headers: {
                    "Authorization": "Bearer $token",
                    "Accept": "application/json",
                  },
                  body: {
                    "expert_id": travellerId.toString(),
                    "rating": selectedRating.value.toString(),
                  },
                );

                final data = jsonDecode(response.body);

                if (response.statusCode == 201 && data["status"] == true) {
                  Fluttertoast.showToast(
                    
                      msg: "Thanks! You rated ${selectedRating.value} stars ⭐");
                             final expertuserprofileController = Get.find<ExpertUserProfileController>();
                expertuserprofileController.fetchExpertUserProfile();

                } else {
                  Fluttertoast.showToast(
                      msg: data["message"] ?? "Failed to submit rating");
                }
              } catch (e) {
                print("❌ Error submitting rating: $e");
                Fluttertoast.showToast(msg: "Error submitting rating");
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
