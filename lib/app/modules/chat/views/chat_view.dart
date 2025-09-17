
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/chat/controllers/chat_controller.dart';

class ChatView extends StatefulWidget {
  final String currentUser;
  final String otherUser;
  final String chatId;
  final String otherUserImage;

  const ChatView({
    Key? key,
    required this.currentUser,
    required this.otherUser,
    required this.chatId,
    required this.otherUserImage,
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ChatController controller = Get.put(ChatController());
  final box = GetStorage();
  final ScrollController _scrollController = ScrollController();

  late String receiverId;

  @override
  void initState() {
    super.initState();
    final parts = widget.chatId.split('_');
    receiverId = (parts[0] == widget.currentUser) ? parts[1] : parts[0];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    controller.sendMessageApi(
      receiverId: receiverId,
      message: text,
    );
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = widget.otherUserImage.isNotEmpty
        ? (widget.otherUserImage.startsWith("http")
            ? widget.otherUserImage
            : "https://kotiboxglobaltech.com/${widget.otherUserImage}")
        : "https://via.placeholder.com/150";

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.mainBg,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(profileImage)),
            const SizedBox(width: 12),
            Text(
              widget.otherUser,
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
          // Messages
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: controller.messageStream(receiverId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Lottie.asset(
                        'assets/lottie/Loading.json',
                        repeat: true,
                        animate: true,
                      ),
                    ),
                  );
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  
                  return const Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    final isMe = msg['sender_id'].toString() == widget.currentUser;

                    // Convert server time to IST
                    final timestamp = msg['created_at'] ?? DateTime.now().toString();
                    DateTime date = DateTime.tryParse(timestamp) ?? DateTime.now();
                    date = date.toUtc().add(const Duration(hours: 5, minutes: 30));
                    final time = DateFormat('hh:mm a').format(date);

                 return Align(
  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
  child: Container(
    margin: EdgeInsets.only(
      top: 6,
      bottom: 6,
      left: isMe ? 50 : 8,
      right: isMe ? 8 : 50,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.7,
    ),
    decoration: BoxDecoration(
      color: isMe ? Colors.blue.shade700 : Colors.grey.shade800,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isMe ? Colors.blue.shade600 : Colors.grey.shade700,
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          msg['message'] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
            if (isMe) ...[
              const SizedBox(width: 4),
              Icon(
                msg['is_read'] == 0
                    ? Icons.done_all   // ✅ Seen
                    : Icons.done,      // ✔ Sent but not seen
                size: 16,
                color: msg['is_read'] == 1
                    ? Colors.green
                    : Colors.grey.shade400,
              ),
            ]
          ],
        ),
      ],
    ),
  ),
);

                
                  },
                );
              },
            ),
          ),

          // Input Field
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
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