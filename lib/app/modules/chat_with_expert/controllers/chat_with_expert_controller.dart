import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ChatWithExpertController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isSending = false.obs;
  var isLoading = false.obs;

  final box = GetStorage();

  /// Send message to expert
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
        messages.add({
          "sender": "me",
          "message": message,
          "created_at": DateTime.now().toString(),
        });
        Fluttertoast.showToast(msg: "Message sent successfully");
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

  /// Fetch messages between user and expert
  Future<void> fetchMessagesusertoexpert({required int receiverId}) async {
    try {
      final token = box.read('token');

      var url = Uri.parse(
          'https://kotiboxglobaltech.com/travel_app/api/expert-messages/get?receiver_id=$receiverId');

      var response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["status"] == true && data["data"] != null) {
          List messagesList = data["data"];
          messages.value = messagesList.map<Map<String, dynamic>>((msg) {
            return {
              "sender": msg['sender_id'].toString() ==
                      box.read('user_id').toString()
                  ? "me"
                  : "expert",
              "message": msg['message'],
              "created_at": msg['created_at'],
            };
          }).toList();
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch messages");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching messages");
      print("❌ Error fetching messages: $e");
    }
  }



/// Verifies payment dynamically with given paymentId, expertId, and token.
Future<void> verifyPayment({
  required String paymentId,
  required int expertId,
  required String token,
}) async {
  try {
    if (token.isEmpty) {
      print("❌ Token is required. Please login first.");
      return;
    }

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    var bodyFields = {
      'payment_id': paymentId.trim(),
      'expert_id': expertId.toString(),
    };

    print("--------------------------------------------------");
    print("📤 Sending Payment Verification Request...");
    print("➡ URL: https://kotiboxglobaltech.com/travel_app/api/verify-payment-id");
    print("➡ Headers: $headers");
    print("➡ Body: $bodyFields");
    print("--------------------------------------------------");

    var request = http.Request(
      'POST',
      Uri.parse('https://kotiboxglobaltech.com/travel_app/api/verify-payment-id'),
    );

    request.bodyFields = bodyFields;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    // Convert stream to string
    final responseBody = await response.stream.bytesToString();

    print("📥 Response Body: $responseBody");

    if (response.statusCode == 200) {
      var data = jsonDecode(responseBody);
      print("✅ Payment verification response: $data");

      if (data['status'] == true) {
        print("✅ Payment verified successfully");
      } else {
        print("❌ Payment verification failed: ${data['message']}");
      }
    } else {
      print("❌ Server error: ${response.statusCode}");
      print("Reason: ${response.reasonPhrase}");
    }
  } catch (e) {
    print("🔥 Error verifying payment: $e");
  }
}

}