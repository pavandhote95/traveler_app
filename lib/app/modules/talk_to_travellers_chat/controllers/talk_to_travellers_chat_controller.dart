import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class TalkToTravellersChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;

  final box = GetStorage();

  late int travellerId;
  late String travellerName;
  late String? travellerImage;
  late int myUserId; // ✅ Current logged in user ID

  @override
  void onInit() {
    super.onInit();

    // ✅ Get arguments from previous screen
    final args = Get.arguments as Map<String, dynamic>;
    travellerId = args["travellerId"];
    travellerName = args["travellerName"];
    travellerImage = args["travellerImage"];
    myUserId = box.read("user_id") ?? 0;

    fetchChat();
  }

  /// 🔹 Fetch Chat Messagesc
  Future<void> fetchChat() async {
    try {
      isLoading.value = true;
      final token = box.read('token') ?? '';

      final response = await http.post(
        Uri.parse("https://kotiboxglobaltech.com/travel_app/api/expert-messages/get"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "receiver_id": travellerId.toString(),
        },
      );

      print("📩 Chat API Response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == true) {
          messages.value = List<Map<String, dynamic>>.from(data["data"]);
        }
      }
    } catch (e) {
      print("❌ Error fetching chat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Send Message
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

      var headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://kotiboxglobaltech.com/travel_app/api/expert-messages/send'),
      );

      request.fields.addAll({
        'receiver_id': receiverId.toString(),
        'message': message,
        'message_type': messageType,
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final data = jsonDecode(responseString);

      if (response.statusCode == 201 && data["status"] == true) {
        // ✅ Add sent message to UI with correct structure
        messages.add({
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
}
