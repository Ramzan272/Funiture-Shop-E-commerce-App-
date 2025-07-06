import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus {
  sending,
  sent,
  delivered,
  read
}
class ChatMessage {
  final String id;
  final String message;
  final DateTime timestamp;
  final bool isSentByUser;
  final String userId;
  final String userName;
  final MessageStatus status;
  final String? replyToMessageId;

  ChatMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.isSentByUser,
    required this.userId,
    required this.userName,
    this.status = MessageStatus.sending,
    this.replyToMessageId,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatMessage(
      id: documentId,
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSentByUser: map['isSentByUser'] ?? true,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      status: MessageStatus.values[map['status'] ?? 0],
      replyToMessageId: map['replyToMessageId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isSentByUser': isSentByUser,
      'userId': userId,
      'userName': userName,
      'status': status.index,
      'replyToMessageId': replyToMessageId,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? message,
    DateTime? timestamp,
    bool? isSentByUser,
    String? userId,
    String? userName,
    MessageStatus? status,
    String? replyToMessageId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isSentByUser: isSentByUser ?? this.isSentByUser,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }
}
