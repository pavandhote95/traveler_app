// views/expert_chat_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/modules/chat_with_expert/controllers/chat_with_expert_controller.dart';
import '../../../constants/app_color.dart';

class ExpertChatView extends StatefulWidget {
  final int expertId;
  final String expertName;
  final String expertImage;

  const ExpertChatView({
    super.key,
    required this.expertId,
    required this.expertName,
    required this.expertImage,
  });

  @override
  State<ExpertChatView> createState() => _ExpertChatViewState();
}

class _ExpertChatViewState extends State<ExpertChatView> {
  late final ChatWithExpertController controller;
  late final String _tag;

  @override
  void initState() {
    super.initState();
    _tag = 'expert_${widget.expertId}';
      debugPrint("✅ Expert Image: ${widget.expertImage}");

    // Reuse controller per expert using a tag. If not registered — create and keep permanent.
    if (Get.isRegistered<ChatWithExpertController>(tag: _tag)) {
      controller = Get.find<ChatWithExpertController>(tag: _tag);
    } else {
      controller = Get.put<ChatWithExpertController>(
        ChatWithExpertController(),
        tag: _tag,
        permanent: true,
      );
    }

    // Initialize controller with current widget params and fetch messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeFromWidget(
        expertId: widget.expertId,
        expertName: widget.expertName,
        expertImage: widget.expertImage,
      );

      // initial fetch
      controller.fetchMessages(widget.expertId);
    });

    // Auto-scroll to bottom when messages change
    ever(controller.messages, (_) {
      if (controller.scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            controller.scrollController.animateTo(
              controller.scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          } catch (_) {}
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.mainBg,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.expertImage.isNotEmpty
                  ? NetworkImage(widget.expertImage)
                  : null,
              backgroundColor: Colors.grey,
              child: widget.expertImage.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.expertName,
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchMessages(widget.expertId),
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading indicator
          Obx(() => controller.isLoading.value
              ? Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 2,
                  ),
                )
              : const SizedBox.shrink()),

          // Chat messages area
          Expanded(
            child: Obx(() {
              final messages = controller.messages;
              if (messages.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Start a conversation with ${widget.expertName}",
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index] as Map<String, dynamic>;
                  final isMe = (msg['sender'] ?? '') == 'me';
                  final isRead = (msg['is_read'] == 1 || msg['is_read'] == true);

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 6,
                        bottom: 6,
                        left: isMe ? 50 : 8,
                        right: isMe ? 8 : 50,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isMe ? Colors.blue.shade700 : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          // Message text
                          Text(
                            msg['text'] ?? '',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          // Timestamp
                          Text(
                            _formatTime(msg['time']?.toString()),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          // Read indicator for sent messages
                          if (isMe && !isRead)
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.done,
                                size: 12,
                                color: Colors.white54,
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

          // Input field area
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
                  // Message input
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
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
                      maxLines: null,
                      onSubmitted: (text) => _sendMessage(text),
                      enabled: !controller.isSending.value,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Pay button (placeholder)
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.green,
                    child: IconButton(
                      icon: const Icon(
                        Icons.currency_rupee,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Get.snackbar(
                          "Payment",
                          "Payment feature coming soon!",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  Obx(() => CircleAvatar(
                        radius: 24,
                        backgroundColor: controller.isSending.value
                            ? Colors.grey
                            : Colors.blue.shade700,
                        child: controller.isSending.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: controller.isSending.value
                                    ? null
                                    : () => _sendMessage(
                                        controller.messageController.text.trim()),
                              ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      controller.sendMessageToExpert(
        receiverId: widget.expertId,
        message: text.trim(),
      );
      controller.messageController.clear();
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null || timestamp.trim().isEmpty) return '';
    try {
      final t = timestamp.trim();
      DateTime dateTime;
      if (RegExp(r'^\d+$').hasMatch(t)) {
        // numeric timestamp (seconds or milliseconds)
        final parsed = int.parse(t);
        final ms = (t.length > 10) ? parsed : parsed * 1000;
        dateTime = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
      } else {
        dateTime = DateTime.parse(t).toLocal();
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    // controller is registered as permanent per-tag — do not remove here.
    // If you prefer not to keep controllers forever, remove `permanent: true` above and uncomment below:
    // if (Get.isRegistered<ChatWithExpertController>(tag: _tag)) {
    //   Get.delete<ChatWithExpertController>(tag: _tag);
    // }
    super.dispose();
  }
}
