import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList<QueryDocumentSnapshot<Map<String, dynamic>>> messages = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  // Stream for real-time updates
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> chatStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Send a message
  Future<void> sendMessage(String chatId, String text, String senderId) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'text': text,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Generate chat ID for two users
  String getChatId(String userA, String userB) {
    return userA.hashCode <= userB.hashCode ? '$userA\_$userB' : '$userB\_$userA';
  }
}
