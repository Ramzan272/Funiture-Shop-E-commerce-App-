import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  final String id;
  final String productId;
  final String title;
  final String image;
  final String price;
  final String? description;
  final DateTime timestamp;
  final String? userId; // <--- Add this field

  WishlistItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    this.description,
    required this.timestamp,
    required this.userId, // <--- Add to constructor
  });

  factory WishlistItem.fromMap(Map<String, dynamic> map, String documentId) {
    return WishlistItem(
      id: documentId,
      productId: map['productId'] ?? '',
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      price: map['price']?.toString() ?? '0',
      description: map['description'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: map['userId'] ?? '', // <--- Add to fromMap
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'image': image,
      'price': price,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId, // <--- Add to toMap
    };
  }
}