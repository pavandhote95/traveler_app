import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/modules/chat_with_expert/controllers/chat_with_expert_controller.dart';
import '../../../constants/app_color.dart';

class ExpertChatView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final ChatWithExpertController controller =
        Get.put(ChatWithExpertController());

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
          // 🔹 Chat messages
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMe = msg['sender'] == "me";

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
                      child: Text(
                        msg['text'] ?? '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // 🔹 Input field with Send & Pay
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
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
                      ),
                      onSubmitted: (text) => controller.sendMessageToExpert(
                        receiverId: expertId,
                        message: text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 24,
                    child: const Icon(Icons.currency_rupee, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => CircleAvatar(
                        backgroundColor: Colors.blue.shade700,
                        radius: 24,
                        child: controller.isSending.value
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)
                            : IconButton(
                                icon: const Icon(Icons.send,
                                    color: Colors.white),
                                onPressed: () {
                                  controller.sendMessageToExpert(
                                    receiverId: expertId,
                                    message: controller
                                        .messageController.text
                                        .trim(),
                                  );
                                },
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
}
