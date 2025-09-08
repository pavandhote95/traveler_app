import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/modules/chat/controllers/chat_controller.dart';

class ChatView extends StatelessWidget {
  final String currentUser;
  final String otherUser;
  final String chatId; // <-- add this

  const ChatView({
    Key? key,
    required this.currentUser,
    required this.otherUser,
    required this.chatId, // <-- add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text(otherUser)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: controller.chatStream(chatId), // use chatId here
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data();
                    return ListTile(
                      title: Text(message['text']),
                      subtitle: Text(message['senderId']),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    onSubmitted: (text) {
                      controller.sendMessage(chatId, text, currentUser);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
