// lib/viewmodels/admin_chat_viewmodel.dart (Create this new file)

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For TextEditingController and ScrollController
import 'package:get/get.dart';
import '../../../../models/chat_message.dart';

class AdminChatViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Passed from the UI
  final String conversationId;
  final String userName;
  final TextEditingController messageInputController;
  final ScrollController chatScrollController;

  // Observable properties for UI to react to
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ChatMessage?> replyingTo = Rx<ChatMessage?>(null);
  final RxBool isUserTyping = false.obs; // Customer typing status
  final RxString customerEmail = ''.obs; // Customer's email from conversation doc

  // Internal state for admin typing indicator
  Timer? _typingTimer;
  bool _isLocalAdminTyping = false; // Flag to prevent multiple redundant updates

  // Stream subscriptions
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _conversationStatusSubscription;

  AdminChatViewModel({
    required this.conversationId,
    required this.userName,
    required this.messageInputController,
    required this.chatScrollController,
  });

  @override
  void onInit() {
    super.onInit();
    _markMessagesAsRead(); // Mark messages as read when entering the chat
    _listenToMessages();
    _listenToConversationStatus();
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    _conversationStatusSubscription?.cancel();
    _typingTimer?.cancel();
    // Controllers are typically disposed by the widget if they manage their lifecycle
    // However, if the ViewModel owns them, dispose here:
    // messageInputController.dispose();
    // chatScrollController.dispose();
    super.onClose();
  }

  // --- Data Fetching & Listening ---

  void _listenToMessages() {
    _messagesSubscription = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
        messages.value = snapshot.docs.map((doc) {
          return ChatMessage.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        isLoading.value = false;
        errorMessage.value = '';
        _scrollToBottom(); // Scroll to bottom when new messages arrive
      },
      onError: (error) {
        isLoading.value = false;
        errorMessage.value = 'Error loading messages: $error';
        print('Error loading messages: $error');
      },
    );
  }

  void _listenToConversationStatus() {
    _conversationStatusSubscription = _firestore
        .collection('conversations')
        .doc(conversationId)
        .snapshots()
        .listen(
          (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            isUserTyping.value = data['isUserTyping'] == true;
            customerEmail.value = data['userEmail'] as String? ?? 'No email available';
          }
        }
      },
      onError: (error) {
        print('Error listening to conversation status: $error');
      },
    );
  }

  // --- Message Actions ---

  Future<void> _markMessagesAsRead() async {
    try {
      final batch = _firestore.batch();
      final unreadMessages = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('isSentByUser', isEqualTo: true) // Messages from the user
          .where('status', isLessThan: MessageStatus.read.index)
          .get();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'status': MessageStatus.read.index});
      }
      batch.update(_firestore.collection('conversations').doc(conversationId), {
        'hasUnreadMessages': false, // Admin has now read them in chat list
        'unreadCount': 0, // Admin's unread count reset in chat list
      });

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void _sendTypingStatus(bool isTyping) {
    _firestore
        .collection('conversations')
        .doc(conversationId)
        .update({'isAdminTyping': isTyping}).catchError((e) {
      print('Error updating admin typing status: $e');
    });
  }

  void onMessageInputChanged() {
    if (!_isLocalAdminTyping) {
      _isLocalAdminTyping = true;
      _sendTypingStatus(true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _isLocalAdminTyping = false;
      _sendTypingStatus(false);
    });
  }

  Future<void> sendMessage() async {
    final text = messageInputController.text.trim();
    if (text.isEmpty) return;

    messageInputController.clear();
    _typingTimer?.cancel();
    _isLocalAdminTyping = false;
    _sendTypingStatus(false); // Stop typing indicator immediately after sending

    try {
      final message = ChatMessage(
        id: '', // ID will be set by Firestore
        message: text,
        timestamp: DateTime.now(),
        isSentByUser: false, // This message is sent by the admin
        userId: 'admin_id_here', // Replace with actual admin ID if available
        userName: 'Admin', // Admin's display name
        status: MessageStatus.sent,
        replyToMessageId: replyingTo.value?.id,
      );

      // Add message to sub-collection
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(message.toMap());

      // Update conversation document
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSentByUser': false, // Correct: Admin sent this message
        'userHasUnreadMessages': true, // Set to true for the user to see unread
        'userUnreadCount': FieldValue.increment(1), // Increment user's unread count
      });

      replyingTo.value = null; // Clear reply state
      _scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error sending message: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      print('Error sending message: $e');
    }
  }

  void replyToMessage(ChatMessage message) {
    replyingTo.value = message;
    // Request focus on the text field after setting reply
    FocusManager.instance.primaryFocus?.requestFocus();
  }

  void cancelReply() {
    replyingTo.value = null;
  }

  Future<ChatMessage?> fetchRepliedMessage(String messageId) async {
    try {
      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .get();
      if (doc.exists) {
        return ChatMessage.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching replied message: $e');
      return null;
    }
  }

  // --- UI Helpers (can be in ViewModel or UI) ---

  void _scrollToBottom() {
    // Ensure the scroll controller is attached and we're not disposing
    if (chatScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (chatScrollController.hasClients) { // Re-check after delay
          chatScrollController.animateTo(
            chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return 'Today ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}