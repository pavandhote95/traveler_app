import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_with_expert_controller.dart';
import 'package:travel_app2/app/constants/app_color.dart';

class ChatWithExpertView extends StatefulWidget {
  final int expertId;
  final String expertName;
  final String expertImage;

  const ChatWithExpertView({
    super.key,
    required this.expertId,
    required this.expertName,
    required this.expertImage,
  });

  @override
  State<ChatWithExpertView> createState() => _ChatWithExpertViewState();
}

class _ChatWithExpertViewState extends State<ChatWithExpertView> {
  late final ChatWithExpertController controller;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ChatWithExpertController>()
        ? Get.find()
        : Get.put(ChatWithExpertController());

    controller.fetchMessages(receiverId: widget.expertId);

    ever(controller.messages, (_) => scrollToBottom());
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
String formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  try {
    final dt = DateTime.parse(dateStr).toLocal(); // Convert UTC to local
    return DateFormat('hh:mm a, dd MMM yyyy').format(dt);
  } catch (_) {
    return dateStr;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.expertImage),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Text(
              widget.expertName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return const Center(
                  child: Text(
                    "No messages yet",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMe = msg['sender'] == "me";

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.buttonBg : Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['message'] ?? "",
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(msg['created_at']),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Message input field
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.cardBg,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => controller.isSending.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : IconButton(
                            icon:
                                const Icon(Icons.send, color: Colors.tealAccent),
                            onPressed: () {
                              final text = messageController.text.trim();
                              if (text.isNotEmpty) {
                                controller.sendMessageToExpert(
                                  receiverId: widget.expertId,
                                  message: text,
                                );
                                messageController.clear();
                                scrollToBottom();
                              }
                            },
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
