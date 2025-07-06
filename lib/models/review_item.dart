import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String productId;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final String userName;

  Review({
    required this.id,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.timestamp,
    required this.userName,
  });

  factory Review.fromMap(Map<String, dynamic> map, String documentId) {
    return Review(
      id: documentId,
      productId: map['productId'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userName: map['userName'] ?? 'Anonymous',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
      'userName': userName,
    };
  }
}
