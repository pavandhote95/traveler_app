import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatWithExpertController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  var messages = <Map<String, dynamic>>[].obs; // {sender: "user/expert", text: "msg"}

  void sendMessage(String text, {String sender = "user"}) {
    if (text.trim().isEmpty) return;
    messages.add({"sender": sender, "text": text.trim()});
    messageController.clear();

    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 300), () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }
}
