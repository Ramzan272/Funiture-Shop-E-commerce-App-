// lib/viewmodels/admin_chat_list_viewmodel.dart (Create this new file)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../models/chat_conversation.dart';

class AdminChatListViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<ChatConversation> conversations = <ChatConversation>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchConversations();
  }

  void _fetchConversations() {
    _firestore
        .collection('conversations')
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        conversations.value = snapshot.docs.map((doc) {
          return ChatConversation.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
        isLoading.value = false;
        errorMessage.value = ''; // Clear any previous error
      },
      onError: (error) {
        isLoading.value = false;
        errorMessage.value = 'Error loading conversations: $error';
        print(errorMessage.value); // Log the error for debugging
      },
    );
  }

  // Method to format time, keeping it in the ViewModel for data presentation logic
  String formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}