import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../controllers/talk_to_travellers_chat_controller.dart';

class TalkToTravellersChatView extends GetView<TalkToTravellersChatController> {
  const TalkToTravellersChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController msgController = TextEditingController();
    final box = GetStorage();
    final String userType = box.read("role") ?? "traveller"; // "expert" / "traveller"

    void _sendMessage() {
      final text = msgController.text.trim();
      if (text.isNotEmpty) {
        controller.sendMessageToExpert(
          receiverId: controller.travellerId,
          message: text,
        );
        msgController.clear();
      }
    }

    void _showPaymentModal() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Payment Required",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text("To chat further, please complete your payment."),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Integrate Razorpay or payment function here
                  },
                  child: const Text("Proceed to Pay"),
                ),
              ],
            ),
          );
        },
      );
    }

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
      body: SafeArea(
        child: Column(
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

                    // 🔹 Format time
                    String time = "";
                    try {
                      if (msg["created_at"] != null) {
                        DateTime parsedTime = DateTime.parse(msg["created_at"]);
                        time = DateFormat("hh:mm a").format(parsedTime);
                      }
                    } catch (e) {
                      time = "";
                    }

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
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg["message"] ?? "",
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: const TextStyle(
                                color: Colors.white70,
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

            /// 🔹 Message Input
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade900,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: msgController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.grey.shade800,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    /// 🔹 Payment Button (Only for travellers)
                    if (userType != "expert")
                      InkWell(
                        onTap: _showPaymentModal,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              "₹",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),

                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
