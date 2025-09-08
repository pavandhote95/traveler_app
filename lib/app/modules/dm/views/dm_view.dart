import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/modules/chat/controllers/chat_controller.dart';
import 'package:travel_app2/app/modules/chat/views/chat_view.dart';
import 'package:travel_app2/app/modules/dm/controllers/dm_controller.dart';
import 'user_model.dart';

class DmView extends StatelessWidget {
  DmView({Key? key}) : super(key: key);

  final ChatController chatController = Get.put(ChatController());
  final DmController dmController = Get.put(DmController());
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = box.read('userId')?.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Direct Messages')),
      body: Obx(() {
        if (dmController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (dmController.users.isEmpty) {
          return const Center(child: Text('No users found'));
        } else {
          return ListView.builder(
            itemCount: dmController.users.length,
            itemBuilder: (context, index) {
              final UserModel user = dmController.users[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.image != null && user.image!.isNotEmpty
                      ? NetworkImage(user.image!)
                      : const AssetImage('assets/images/default_user.png')
                          as ImageProvider,
                ),
                title: Text(user.name),
                onTap: () {
                  if (currentUserId == null) {
                    Get.snackbar('Error', 'Current user ID not found');
                    return;
                  }

                  final chatId = chatController.getChatId(
                      currentUserId, user.id.toString());

                  Get.to(() => ChatView(
                        currentUser: currentUserId,
                        otherUser: user.id.toString(),
                        chatId: chatId,
                      ));
                },
              );
            },
          );
        }
      }),
    );
  }
}
