// models/furniture.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FurnitureOrder {
  final String id;
  final List<Map<String, dynamic>> items; // More specific type for items
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String? customerEmail;
  final String? customerName;
  final String? customerPhone;
  final String? shippingAddress;
  final String? paymentMethod; // NEW FIELD: To store the selected payment method
  final bool adminViewed;
  final bool isArchived;

  FurnitureOrder({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.customerEmail,
    this.customerName,
    this.customerPhone,
    this.shippingAddress,
    this.paymentMethod, // NEW: Added to constructor
    this.adminViewed = false,
    this.isArchived = false,
  });

  factory FurnitureOrder.fromMap(Map<String, dynamic> map, String documentId) {
    return FurnitureOrder(
      id: documentId,
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      orderDate: (map['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      customerEmail: map['customerEmail'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      shippingAddress: map['shippingAddress'],
      paymentMethod: map['paymentMethod'], // NEW: Read from map
      adminViewed: map['adminViewed'] ?? false,
      isArchived: map['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items,
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': Timestamp.fromDate(orderDate),
      'customerEmail': customerEmail,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod, // NEW: Write to map
      'adminViewed': adminViewed,
      'isArchived': isArchived,
    };
  }

  FurnitureOrder copyWith({
    String? id,
    List<Map<String, dynamic>>? items,
    double? totalAmount,
    String? status,
    DateTime? orderDate,
    String? customerEmail,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    String? paymentMethod, // NEW: Added to copyWith
    bool? adminViewed,
    bool? isArchived,
  }) {
    return FurnitureOrder(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      customerEmail: customerEmail ?? this.customerEmail,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod, // NEW: Update copy
      adminViewed: adminViewed ?? this.adminViewed,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  double calculateTotal() {
    return items.fold(0.0, (sum, item) {
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      return sum + (price * quantity);
    });
  }

  int get itemCount {
    return items.fold(0, (sum, item) {
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      return sum + quantity;
    });
  }

  bool get canBeCancelled {
    return status.toLowerCase() == 'pending' || status.toLowerCase() == 'processing';
  }

  String get formattedDate {
    return "${orderDate.day}/${orderDate.month}/${orderDate.year}";
  }
}