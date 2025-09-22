import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/talk_to_travellers_chat_controller.dart';

class TalkToTravellersChatView extends GetView<TalkToTravellersChatController> {
  const TalkToTravellersChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController msgController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: controller.travellerImage != null &&
                      controller.travellerImage!.isNotEmpty
                  ? NetworkImage(controller.travellerImage!)
                  : null,
              child: controller.travellerImage == null ||
                      controller.travellerImage!.isEmpty
                  ? Text(controller.travellerName[0])
                  : null,
            ),
            const SizedBox(width: 10),
            Text(controller.travellerName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return const Center(child: Text("No messages yet"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMe = msg["sender_id"] == controller.myUserId;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        msg["message"] ?? "",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // 🔹 Input field
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                Obx(() => controller.isSending.value
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          if (msgController.text.trim().isNotEmpty) {
                            controller.sendMessageToExpert(
                              receiverId: controller.travellerId,
                              message: msgController.text.trim(),
                            );
                            msgController.clear();
                          }
                        },
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
