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
        // Add sent message to UI
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

  /// Fetch messages from expert
  Future<void> fetchMessagesusertoexpert({required int receiverId}) async {
    try {
      final token = box.read('token') ??
          '552|OlWZOZb6fsqgimApW1LFnbTzKVVFkVGKjv7xdKxafe7c3546';

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
}







// import 'dart:convert';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:get_storage/get_storage.dart';

// class ChatWithExpertController extends GetxController {
//   var messages = <Map<String, dynamic>>[].obs;
//   var isSending = false.obs;
//   var isLoading = false.obs;

//   final box = GetStorage();

//   /// ✅ Send message to expert (with payment fields support)
//   Future<void> sendMessageToExpert({
//     required int receiverId,
//     required String message,
//     String messageType = "text",
//     required String price,
//     String country = "IN",
//     String currency = "INR",
//     bool payNow = true,
//   }) async {
//     if (message.trim().isEmpty) {
//       Fluttertoast.showToast(msg: "Message cannot be empty");
//       return;
//     }

//     try {
//       isSending.value = true;

//       final token = box.read('token');
//       if (token == null || token.isEmpty) {
//         Fluttertoast.showToast(msg: "Please login first");
//         return;
//       }

//       var headers = {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       };

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(
//             'https://kotiboxglobaltech.com/travel_app/api/expert-messages/send'),
//       );

//       request.fields.addAll({
//         'receiver_id': receiverId.toString(),
//         'message': message,
//         'message_type': messageType,
//         'price': price,
//         'country': country,
//         'currency': currency,
//         'pay_now': payNow.toString(), // must be "true"/"false"
//       });

//       request.headers.addAll(headers);

//       print("📤 Sending message request: ${request.fields}");
//       print("📌 Headers: $headers");

//       http.StreamedResponse response = await request.send();
//       final responseString = await response.stream.bytesToString();

//       print("📥 Raw Response: $responseString");

//       final data = jsonDecode(responseString);

//       if (response.statusCode == 200 && data["status"] == true) {
//         // ✅ Add sent message to UI
//         messages.add({
//           "sender": "me",
//           "message": message,
//           "created_at": DateTime.now().toString(),
//         });
//         Fluttertoast.showToast(msg: "Message sent successfully");
//         print("✅ Message sent successfully: $message");
//       } else {
//         Fluttertoast.showToast(
//             msg: data["message"] ?? "Failed to send message");
//         print("❌ Failed to send message: ${data["message"]}");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Failed to send message");
//       print("❌ Error sending message: $e");
//     } finally {
//       isSending.value = false;
//     }
//   }

//   /// ✅ Fetch messages from expert
//   Future<void> fetchMessages({required int receiverId}) async {
//     try {
//       final token = box.read('token');
//       if (token == null || token.isEmpty) {
//         Fluttertoast.showToast(msg: "Please login first");
//         return;
//       }

//       isLoading.value = true;

//       var url = Uri.parse(
//           'https://kotiboxglobaltech.com/travel_app/api/expert-messages/get?receiver_id=$receiverId');

//       print("📤 Fetching messages for receiver: $receiverId");

//       var response = await http.post(url, headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       });

//       print("📥 Fetch response code: ${response.statusCode}");
//       print("📥 Fetch response body: ${response.body}");

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);

//         if (data["status"] == true && data["data"] != null) {
//           List messagesList = data["data"];
//           messages.value = messagesList.map<Map<String, dynamic>>((msg) {
//             return {
//               "sender": msg['sender_id'].toString() ==
//                       box.read('user_id').toString()
//                   ? "me"
//                   : "expert",
//               "message": msg['message'],
//               "created_at": msg['created_at'],
//             };
//           }).toList();

//           print("✅ Messages fetched: ${messages.length}");
//           for (var msg in messages) {
//             print("💬 ${msg['sender']}: ${msg['message']} (${msg['created_at']})");
//           }
//         }
//       } else {
//         Fluttertoast.showToast(msg: "Failed to fetch messages");
//         print("❌ Failed to fetch messages");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error fetching messages");
//       print("❌ Error fetching messages: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

