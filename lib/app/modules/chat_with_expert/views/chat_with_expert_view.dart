import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_color.dart';

class ExpertChatView extends StatefulWidget {
  final int expertId;
  final String expertName;
  final String expertImage;

  const ExpertChatView({
    super.key,
    this.expertId = 0,
    this.expertName = "Expert",
    this.expertImage = "",
  });

  @override
  State<ExpertChatView> createState() => _ExpertChatViewState();
}


class _ExpertChatViewState extends State<ExpertChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Temporary static chat messages (dummy data)
  final List<Map<String, dynamic>> messages = [
    {"sender": "me", "message": "Hello Expert!", "time": "10:30 AM"},
    {"sender": "expert", "message": "Hi! How can I help you today?", "time": "10:32 AM"},
    {"sender": "me", "message": "I need some advice.", "time": "10:33 AM"},
    {"sender": "expert", "message": "Sure, please tell me more.", "time": "10:34 AM"},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "sender": "me",
        "message": _messageController.text.trim(),
        "time": "Now",
      });
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final expertName = args['expertName'] ?? widget.expertName;
    final expertImage = args['expertImage'] ?? widget.expertImage;

    final profileImage = expertImage.isNotEmpty
        ? (expertImage.startsWith("http")
            ? expertImage
            : "https://kotiboxglobaltech.com/$expertImage")
        : "https://via.placeholder.com/150";

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.mainBg,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(expertImage)),
            const SizedBox(width: 12),
            Text(
              expertName,
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Messages List (Static)
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender'] == "me";

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: 6,
                      bottom: 6,
                      left: isMe ? 50 : 8,
                      right: isMe ? 8 : 50,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue.shade700 : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMe
                            ? Colors.blue.shade600
                            : Colors.grey.shade700,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['message'] ?? '',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] ?? '',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 Pay Now Button
          
          // Input Field
      // Input Field with Pay Now
SafeArea(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
    child: Row(
      children: [
        // Message Input
        Expanded(
          child: TextField(
            controller: _messageController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Message',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (_) => _sendMessage(),
          ),
        ),
        const SizedBox(width: 8),

        // Pay Now Button (like PhonePe)
        CircleAvatar(
          backgroundColor: Colors.green,
          radius: 24,
          child: IconButton(
            icon: const Icon(Icons.currency_rupee, color: Colors.white),
            onPressed: () {
              Get.snackbar("Payment", "Pay Now button clicked!",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white);
            },
          ),
        ),
        const SizedBox(width: 8),

        // Send Button
        CircleAvatar(
          backgroundColor: Colors.blue.shade700,
          radius: 24,
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _sendMessage,
          ),
        ),
      ],
    ),
  ),
),

        ],
      ),
    );
  }
}
