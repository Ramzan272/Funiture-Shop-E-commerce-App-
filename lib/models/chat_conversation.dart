import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  final String id;
  final String userId;
  final String userName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool hasUnreadMessages;
  final int unreadCount;
  final bool userHasUnreadMessages;
  final int userUnreadCount;
  final String? userEmail;
  final String? userPhotoUrl;
  final bool lastMessageSentByUser;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.hasUnreadMessages = false,
    this.unreadCount = 0,
    this.userHasUnreadMessages = false,
    this.userUnreadCount = 0,
    this.userEmail,
    this.userPhotoUrl,
    this.lastMessageSentByUser = false,
  });

  factory ChatConversation.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatConversation(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hasUnreadMessages: map['hasUnreadMessages'] ?? false,
      unreadCount: map['unreadCount'] ?? 0,
      userHasUnreadMessages: map['userHasUnreadMessages'] ?? false,
      userUnreadCount: map['userUnreadCount'] ?? 0,
      userEmail: map['userEmail'],
      userPhotoUrl: map['userPhotoUrl'],
      lastMessageSentByUser: map['lastMessageSentByUser'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'hasUnreadMessages': hasUnreadMessages,
      'unreadCount': unreadCount,
      'userHasUnreadMessages': userHasUnreadMessages,
      'userUnreadCount': userUnreadCount,
      'userEmail': userEmail,
      'userPhotoUrl': userPhotoUrl,
      'lastMessageSentByUser': lastMessageSentByUser,
    };
  }
}