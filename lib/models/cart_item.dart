// models/cart_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final String image;
  final double price;
  final int quantity;
  final String userId; // Make sure this is here

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
    required this.userId, // Make sure this is in constructor
  });

  factory CartItem.fromMap(Map<String, dynamic> map, String documentId) {
    // Robust parsing for price
    double parsedPrice = 0.0;
    final dynamic priceData = map['price'];
    if (priceData != null) {
      if (priceData is num) {
        parsedPrice = priceData.toDouble();
      } else if (priceData is String) {
        parsedPrice = double.tryParse(priceData) ?? 0.0;
      } else {
        // Optional: Log an error if an unexpected type is found
        print("Warning: Unexpected type for price in CartItem: ${priceData.runtimeType}");
      }
    }

    // Robust parsing for quantity
    int parsedQuantity = 1;
    final dynamic quantityData = map['quantity'];
    if (quantityData != null) {
      if (quantityData is int) {
        parsedQuantity = quantityData;
      } else if (quantityData is String) {
        parsedQuantity = int.tryParse(quantityData) ?? 1;
      } else {
        // Optional: Log an error if an unexpected type is found
        print("Warning: Unexpected type for quantity in CartItem: ${quantityData.runtimeType}");
      }
    }

    return CartItem(
      id: documentId,
      productId: map['productId'] ?? '', // Add null check for safety
      title: map['title'] ?? '', // Add null check for safety
      image: map['image'] ?? '', // Add null check for safety
      price: parsedPrice,
      quantity: parsedQuantity,
      userId: map['userId'] ?? '', // Make sure this handles null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'image': image,
      'price': price,
      'quantity': quantity,
      'userId': userId, // Make sure this is here
      'timestamp': FieldValue.serverTimestamp(), // Add timestamp for ordering
    };
  }
}