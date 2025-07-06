import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/chat_message.dart';
import '../../services/notification_service.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User _currentUser; // User object passed from the UI

  String? _conversationId;
  ChatMessage? _replyingTo;
  bool _isLoading = true;
  Timer? _typingTimer;
  bool _isUserTyping = false; // Internal state for user typing

  // Public getters for the UI to consume
  String? get conversationId => _conversationId;
  ChatMessage? get replyingTo => _replyingTo;
  bool get isLoading => _isLoading;

  // Constructor to initialize with the current user
  ChatViewModel(this._currentUser) {
    _initializeChat();
  }

  // --- Chat Initialization ---
  Future<void> _initializeChat() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw Exception('User not logged in.');
      }

      final userId = _currentUser.uid;
      final userName = _currentUser.displayName ?? _currentUser.email?.split('@')[0] ?? 'User';

      final conversationQuery = await _firestore
          .collection('conversations')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (conversationQuery.docs.isEmpty) {
        // Create new conversation
        final newConversation = await _firestore.collection('conversations').add({
          'userId': userId,
          'userName': userName,
          'userEmail': _currentUser.email,
          'userPhotoUrl': _currentUser.photoURL,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'hasUnreadMessages': false, // For admin's view
          'unreadCount': 0,           // For admin's view
          'userHasUnreadMessages': false, // For user's view
          'userUnreadCount': 0,         // For user's view
          'lastMessageSentByUser': false, // Initial state
          'createdAt': FieldValue.serverTimestamp(),
          'isAdminTyping': false, // Initialize admin typing status
          'isUserTyping': false, // Initialize user typing status
        });
        _conversationId = newConversation.id;
      } else {
        // Use existing conversation
        _conversationId = conversationQuery.docs.first.id;

        // Mark admin messages as read and reset user unread counts
        final conversationDocRef = _firestore.collection('conversations').doc(_conversationId);
        final batch = _firestore.batch();

        final unreadAdminMessages = await conversationDocRef
            .collection('messages')
            .where('isSentByUser', isEqualTo: false) // Messages from admin
            .where('status', isNotEqualTo: MessageStatus.read.index) // Not yet read
            .get();

        for (var doc in unreadAdminMessages.docs) {
          batch.update(doc.reference, {'status': MessageStatus.read.index});
        }
        batch.update(
          conversationDocRef,
          {
            'userHasUnreadMessages': false,
            'userUnreadCount': 0,
          },
        );
        await batch.commit();
      }
    } catch (e) {
      print('Error initializing chat: $e'); // Log error for debugging
      // In a real app, you might want to expose this error via a callback or stream
      // for the UI to display a user-friendly message.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Typing Status Management ---
  void _sendTypingStatusToFirestore(bool isTyping) {
    if (_conversationId == null) return;
    _firestore
        .collection('conversations')
        .doc(_conversationId)
        .update({'isUserTyping': isTyping});
  }

  void onUserTyping() {
    if (!_isUserTyping) {
      _isUserTyping = true;
      _sendTypingStatusToFirestore(true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _isUserTyping = false;
      _sendTypingStatusToFirestore(false);
    });
  }

  // --- Message Sending ---
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _conversationId == null) return;

    // Cancel typing status immediately after sending
    _typingTimer?.cancel();
    _isUserTyping = false;
    _sendTypingStatusToFirestore(false);

    try {
      final message = ChatMessage(
        id: '', // Firestore will assign an ID
        message: text.trim(),
        timestamp: DateTime.now(),
        isSentByUser: true,
        userId: _currentUser.uid,
        userName: _currentUser.displayName ?? _currentUser.email!.split('@')[0],
        status: MessageStatus.sending, // Initial status
        replyToMessageId: _replyingTo?.id,
      );

      final messageRef = await _firestore
          .collection('conversations')
          .doc(_conversationId)
          .collection('messages')
          .add(message.toMap());

      await _firestore.collection('conversations').doc(_conversationId).update({
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'hasUnreadMessages': true, // For admin: user sent a new message
        'unreadCount': FieldValue.increment(1), // For admin: increment their unread count
        'lastMessageSentByUser': true, // The last message was from the user
      });

      // Update message status to sent after successful write
      await messageRef.update({'status': MessageStatus.sent.index});

      // Clear reply state after sending
      _replyingTo = null;
      notifyListeners();

      // Send push notification
      NotificationService.sendChatNotification(
        senderName: _currentUser.displayName ?? _currentUser.email!.split('@')[0],
        message: text.trim(),
      );
    } catch (e) {
      print('Error sending message: $e'); // Log error
      // The UI can catch this error using .catchError() on the Future
      throw e; // Re-throw to allow UI to handle errors
    }
  }

  // --- Reply Management ---
  void setReplyingTo(ChatMessage message) {
    _replyingTo = message;
    notifyListeners();
  }

  void cancelReply() {
    _replyingTo = null;
    notifyListeners();
  }

  // --- Streams for UI consumption ---
  Stream<QuerySnapshot> get messagesStream {
    if (_conversationId == null) {
      return const Stream.empty(); // Return an empty stream if no conversation yet
    }
    return _firestore
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<DocumentSnapshot> get conversationStatusStream {
    if (_conversationId == null) {
      return const Stream.empty(); // Return an empty stream if no conversation yet
    }
    return _firestore.collection('conversations').doc(_conversationId).snapshots();
  }

  // --- Clean up ---
  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}