// controllers/chat_with_expert_controller.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ChatWithExpertController extends GetxController {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final box = GetStorage();

  // Messages and states
  var messages = <Map<String, dynamic>>[].obs;
  var isSending = false.obs;
  var isLoading = false.obs;
  var unreadCount = 0.obs;

  // Chat details
  late int expertId;
  late String userId;
  late String currentUserName;
  late String expertName;
  late String expertImage;

  @override
  void onInit() {
    super.onInit();
    print("🚀 ChatWithExpertController: onInit() called");
    // Initialize from arguments if available
    _initializeChatFromArguments();
  }

  /// 🔹 Initialize chat from route arguments (Get.to() or Get.toNamed())
  void _initializeChatFromArguments() {
    print("🔧 _initializeChatFromArguments() started");
    
    dynamic args = Get.arguments;
    print("📦 Get.arguments: $args");
    
    // Try to get from arguments first
    expertId = (args?['expertId'] as int?) ?? 0;
    expertName = (args?['expertName'] as String?) ?? 'Travel Expert';
    expertImage = (args?['expertImage'] as String?) ?? '';
    
    userId = box.read("user_id")?.toString() ?? '';
    currentUserName = box.read("user_name")?.toString() ?? 'You';

    print("👨‍💼 Expert ID from args: $expertId");
    print("👤 Current User ID: $userId");
    print("👤 Expert Name: $expertName");
    print("🖼️ Expert Image: $expertImage");

    if (expertId != 0 && userId.isNotEmpty) {
      print("✅ Valid data from arguments - fetching messages");
      fetchMessages(expertId);
    } else {
      print("⚠️ No valid arguments found - waiting for widget initialization");
    }
  }

  /// 🔹 Initialize from widget properties (when using direct widget)
  void initializeFromWidget({
    required int expertId,
    required String expertName,
    required String expertImage,
  }) {
    print("🔧 initializeFromWidget() called");
    this.expertId = expertId;
    this.expertName = expertName;
    this.expertImage = expertImage;
    
    userId = box.read("user_id")?.toString() ?? '';
    currentUserName = box.read("user_name")?.toString() ?? 'You';

    print("👨‍💼 Expert ID from widget: $expertId");
    print("👤 Current User ID: $userId");
    print("👤 Expert Name: $expertName");

    
  }

  /// 🔹 Fetch messages from API - ✅ WORKING ENDPOINT
  Future<void> fetchMessages(int receiverId) async {
    print("📨 fetchMessages() called for receiverId: $receiverId");
    
    try {
      isLoading.value = true;
      final token = box.read("token");
      
      if (token == null) {
        print("❌ No token found");
        _showErrorSnack("Please login again");
        return;
      }

      print("🌐 POST to: https://kotiboxglobaltech.com/travel_app/api/expert-messages/get");
      
      var headers = {'Authorization': 'Bearer $token'};
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://kotiboxglobaltech.com/travel_app/api/expert-messages/get')
      );
      
      request.fields.addAll({'receiver_id': receiverId.toString()});
      request.headers.addAll(headers);

      print("📤 Request fields: ${request.fields}");
      http.StreamedResponse response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("📩 Status: ${response.statusCode}");
      print("📩 Body: $responseBody");

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(responseBody);
          print("📄 Parsed JSON: $data");
          
          if (data["status"] == true) {
            final serverMessages = List<Map<String, dynamic>>.from(data["data"] ?? []);
            print("📨 Loaded ${serverMessages.length} messages");

            if (serverMessages.isNotEmpty) {
              print("📨 First message sample: ${serverMessages.first}");
            }

            // Process messages
            final processedMessages = serverMessages.map((msg) {
              final isFromMe = msg["sender_id"].toString() == userId;
              print("🔄 Processing message ID: ${msg["id"]}, from me: $isFromMe");
              
              return <String, dynamic>{
                "id": msg["id"] ?? DateTime.now().millisecondsSinceEpoch,
                "sender": isFromMe ? "me" : "other",
                "sender_id": msg["sender_id"]?.toString() ?? '',
                "sender_name": msg["sender"]?["name"] ?? (isFromMe ? currentUserName : expertName),
                "sender_image": msg["sender"]?["image_url"] ?? (isFromMe ? '' : expertImage),
                "text": msg["message"] ?? '',
                "time": _parseTimestamp(msg["created_at"]),
                "is_read": msg["is_read"] ?? 0,
                "message_type": msg["message_type"] ?? "text",
                "file": msg["file"],
              };
            }).toList()
              ..sort((a, b) => DateTime.parse(a["time"]).compareTo(DateTime.parse(b["time"])));

            messages.assignAll(processedMessages);
            unreadCount.value = data["unread_message_count"] ?? 0;
            
            print("✅ Messages loaded: ${messages.length}");
            scrollToBottom();
            
            // Mark as read after loading
            await Future.delayed(const Duration(milliseconds: 500));
            await markAsRead(receiverId);
            
          } else {
            print("⚠️ No messages: ${data["message"]}");
            messages.clear();
            _showInfoSnack("Start the conversation!");
          }
        } catch (e) {
          print("❌ JSON parse error: $e");
          _showErrorSnack("Failed to parse messages");
        }
      } else {
        print("❌ HTTP Error ${response.statusCode}: ${response.reasonPhrase}");
        _showErrorSnack("Failed to load messages (${response.statusCode})");
      }
    } catch (e) {
      print("🔥 Network error: $e");
      _showErrorSnack("Network error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Parse and format timestamp
  String _parseTimestamp(String? timestamp) {
    if (timestamp == null) {
      print("⚠️ Timestamp is null - using current time");
      return DateTime.now().toIso8601String();
    }
    
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      print("✅ Parsed timestamp: $dateTime");
      return dateTime.toIso8601String();
    } catch (e) {
      print("❌ Error parsing timestamp '$timestamp': $e");
      return DateTime.now().toIso8601String();
    }
  }

  /// 🔹 Send message to expert
  Future<void> sendMessageToExpert({
    required int receiverId,
    required String message,
    String messageType = "text",
  }) async {
    print("📤 sendMessageToExpert() called");
    print("📤 Receiver ID: $receiverId");
    print("📤 Message: '$message'");
    print("📤 Message type: $messageType");
    
    if (message.trim().isEmpty) {
      print("⚠️ Empty message - showing error");
      _showErrorSnack("Please enter a message");
      return;
    }

    // Optimistic UI update
    print("🎨 Adding optimistic message to UI");
    final optimisticId = DateTime.now().millisecondsSinceEpoch;
    final optimisticMessage = <String, dynamic>{
      "id": optimisticId,
      "sender": "me",
      "sender_id": userId,
      "sender_name": currentUserName,
      "text": message.trim(),
      "time": DateTime.now().toIso8601String(),
      "is_read": 0,
      "message_type": messageType,
    };
    
    print("➕ Adding optimistic message with ID: $optimisticId");
    messages.add(optimisticMessage);
    print("📊 Current messages count: ${messages.length}");
    
    messageController.clear();
    print("🧹 Message controller cleared");
    scrollToBottom();

    try {
      print("⏳ Setting isSending to true");
      isSending.value = true;
      final token = box.read("token");
      
      if (token == null) {
        print("❌ No token for sending - removing optimistic message");
        _removeOptimisticMessage(optimisticId);
        _showErrorSnack("Auth token not found");
        return;
      }

      // Try multiple possible send endpoints
      final possibleSendEndpoints = [
        'https://kotiboxglobaltech.com/travel_app/api/expert-messages/send',
        'https://kotiboxglobaltech.com/travel_app/api/messages/send',
        'https://kotiboxglobaltech.com/travel_app/api/send-message',
      ];

      http.StreamedResponse? sendResponse;
      String successfulEndpoint = '';
      
      for (String endpoint in possibleSendEndpoints) {
        print("📤 Trying send endpoint: $endpoint");
        
        var headers = {'Authorization': 'Bearer $token'};
        var request = http.MultipartRequest('POST', Uri.parse(endpoint));
        request.fields.addAll({
          'receiver_id': receiverId.toString(),
          'sender_id': userId,
          'message': message.trim(),
          'message_type': messageType,
        });
        request.headers.addAll(headers);

        print("📤 Send fields: ${request.fields}");
        print("📤 Send URL: ${request.url}");

        sendResponse = await request.send();
        
        print("📤 Send response code: ${sendResponse.statusCode}");
        print("📤 Send reason: ${sendResponse.reasonPhrase}");
        
        if (sendResponse.statusCode == 200 || sendResponse.statusCode == 201) {
          print("✅ Send endpoint worked: $endpoint");
          successfulEndpoint = endpoint;
          break;
        } else {
          print("❌ Send endpoint failed: $endpoint (Status: ${sendResponse.statusCode})");
        }
      }

      if (sendResponse != null && (sendResponse.statusCode == 200 || sendResponse.statusCode == 201)) {
        var sendResponseBody = await sendResponse.stream.bytesToString();
        print("📤 Final send response body: $sendResponseBody");
        
        try {
          final data = jsonDecode(sendResponseBody);
          print("📄 Send response JSON: $data");
          
          if (data["status"] == true) {
            print("✅ Message sent successfully via $successfulEndpoint");
            _showSuccessToast("Message sent successfully! ✅");
            
            _removeOptimisticMessage(optimisticId);
            await Future.delayed(const Duration(milliseconds: 500));
            await fetchMessages(receiverId);
          } else {
            print("❌ Send status false - message: ${data["message"]}");
            _removeOptimisticMessage(optimisticId);
            _showErrorSnack(data["message"] ?? "Failed to send message");
          }
        } catch (e) {
          print("⚠️ Send response not JSON: $sendResponseBody");
          print("ℹ️ Assuming success for status ${sendResponse.statusCode}");
          _showSuccessToast("Message sent!");
          _removeOptimisticMessage(optimisticId);
          await Future.delayed(const Duration(milliseconds: 500));
          await fetchMessages(receiverId);
        }
      } else {
        print("❌ All send endpoints failed");
        _removeOptimisticMessage(optimisticId);
        _showErrorSnack("Failed to send message - server error");
      }
    } catch (e) {
      print("🔥 Exception in sendMessage: $e");
      print("🔥 Exception type: ${e.runtimeType}");
      _removeOptimisticMessage(optimisticId);
      _showErrorSnack("Network error: ${e.toString()}");
    } finally {
      print("⏹️ Setting isSending to false");
      isSending.value = false;
    }
  }

  /// 🔹 Remove optimistic message if sending fails
  void _removeOptimisticMessage(int messageId) {
    print("🗑️ _removeOptimisticMessage() called for ID: $messageId");
    print("📊 Messages before removal: ${messages.length}");
    
    final initialLength = messages.length;
    messages.removeWhere((msg) => msg["id"] == messageId);
    final removed = initialLength != messages.length;
    
    print("🗑️ Message removed: $removed");
    print("📊 Messages after removal: ${messages.length}");
  }

  /// 🔹 Scroll to bottom of chat
  void scrollToBottom() {
    print("📜 scrollToBottom() called");
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        final maxExtent = scrollController.position.maxScrollExtent;
        final currentPosition = scrollController.position.pixels;
        print("📜 Scroll - current: $currentPosition, max: $maxExtent");
        
        if (maxExtent > currentPosition) {
          print("📜 Animating to bottom");
          scrollController.animateTo(
            maxExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          print("📜 Already at bottom");
        }
      } else {
        print("📜 Scroll controller has no clients yet");
      }
    });
  }

  /// 🔹 Mark messages as read
  Future<void> markAsRead(int receiverId) async {
    print("👁️ markAsRead() called for receiverId: $receiverId");
    
    try {
      final token = box.read("token");
      if (token == null) {
        print("⚠️ No token for markAsRead - skipping");
        return;
      }

      print("🌐 Trying mark as read endpoint");
      
      var headers = {'Authorization': 'Bearer $token'};
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://kotiboxglobaltech.com/travel_app/api/expert-messages/mark-read')
      );
      
      request.fields.addAll({'receiver_id': receiverId.toString()});
      request.headers.addAll(headers);

      print("📤 Mark as read fields: ${request.fields}");

      http.StreamedResponse response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("👁️ Mark as read response code: ${response.statusCode}");
      print("👁️ Mark as read response body: $responseBody");

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(responseBody);
          if (data["status"] == true) {
            print("✅ Mark as read successful");
            // Update local messages
            int updatedCount = 0;
            for (var msg in messages) {
              if (msg["sender"] == "other" && msg["is_read"] == 0) {
                msg["is_read"] = 1;
                updatedCount++;
              }
            }
            unreadCount.value = 0;
            print("✅ Updated $updatedCount local messages as read");
          } else {
            print("⚠️ Mark as read status false: ${data["message"]}");
          }
        } catch (e) {
          print("⚠️ Mark as read response not JSON: $responseBody");
          // Still update locally even if API fails
          for (var msg in messages) {
            if (msg["sender"] == "other" && msg["is_read"] == 0) {
              msg["is_read"] = 1;
            }
          }
          unreadCount.value = 0;
          print("ℹ️ Updated messages locally despite API error");
        }
      } else {
        print("❌ Mark as read failed with status: ${response.statusCode}");
        // Still update locally
        for (var msg in messages) {
          if (msg["sender"] == "other" && msg["is_read"] == 0) {
            msg["is_read"] = 1;
          }
        }
        unreadCount.value = 0;
        print("ℹ️ Updated messages locally despite HTTP error");
      }
    } catch (e) {
      print("🔥 Error marking messages as read: $e");
      // Don't show error for mark as read - it's not critical
      // Still update locally
      for (var msg in messages) {
        if (msg["sender"] == "other" && msg["is_read"] == 0) {
          msg["is_read"] = 1;
        }
      }
      unreadCount.value = 0;
      print("ℹ️ Updated messages locally despite exception");
    }
  }

  /// 🔹 Refresh messages manually
  Future<void> refreshMessages() async {
    print("🔄 refreshMessages() called");
    if (expertId != 0) {
      await fetchMessages(expertId);
    }
  }

  /// 🔹 Helper methods for showing messages
  void _showErrorSnack(String message) {
    print("❌ _showErrorSnack: $message");
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _showInfoSnack(String message) {
    print("ℹ️ _showInfoSnack: $message");
    Get.snackbar(
      "Info",
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _showSuccessToast(String message) {
    print("✅ _showSuccessToast: $message");
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // 🔹 Debug method to print current state
  void printCurrentState() {
    print("\n" + "═" * 50);
    print("📊 CHAT STATE DEBUG INFO");
    print("═" * 50);
    print("👨‍💼 Expert ID: $expertId");
    print("👤 User ID: $userId");
    print("📝 Expert Name: $expertName");
    print("🖼️ Expert Image: $expertImage");
    print("📊 Messages count: ${messages.length}");
    print("📊 Unread count: ${unreadCount.value}");
    print("⏳ Is loading: ${isLoading.value}");
    print("📤 Is sending: ${isSending.value}");
    print("📜 Scroll position: ${scrollController.hasClients ? scrollController.position.pixels : 'N/A'}");
    
    if (messages.isNotEmpty) {
      print("💬 Last message: ${messages.last['text']}");
      print("💬 Messages sender distribution: ${messages.map((m) => m['sender']).toList().join(', ')}");
    }
    
    print("═" * 50 + "\n");
  }

  @override
  void onClose() {
    print("🛑 ChatWithExpertController: onClose() called");
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}