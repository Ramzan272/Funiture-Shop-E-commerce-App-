import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/constants.dart';
import '../../../../models/furniture.dart';
import '../admin_review_view_screen.dart';
import 'order_status_dropdown.dart';
import 'dart:math' as math;
class OrderCard extends StatelessWidget {
  final FurnitureOrder order;
  final Function(String orderId, String newStatus) onStatusUpdate;
  final bool isArchived;
  const OrderCard({
    Key? key,
    required this.order,
    required this.onStatusUpdate,
    this.isArchived = false,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDelivered = order.status.toLowerCase() == 'delivered';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isArchived ? Colors.grey[150] : null,
      // Wrap the Card with InkWell for onTap functionality
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isDelivered && !isArchived
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminReviewViewScreen(
                orderId: order.id,
                order: order,
              ),
            ),
          );
        }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order #${order.id.substring(0, math.min(8, order.id.length))}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isArchived ? Colors.grey : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Date: ${order.orderDate.toLocal().toString().split(' ')[0]}",
                          style: TextStyle(
                            color: isArchived ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        // --- Display Customer Name ---
                        if (order.customerName != null && order.customerName!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            "Customer Name: ${order.customerName}",
                            style: TextStyle(
                              color: isArchived ? Colors.grey[500] : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (order.customerEmail != null && order.customerEmail!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            "Customer Email: ${order.customerEmail}",
                            style: TextStyle(
                              color: isArchived ? Colors.grey[500] : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            "Phone: ${order.customerPhone}",
                            style: TextStyle(
                              color: isArchived ? Colors.grey[500] : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (order.shippingAddress != null && order.shippingAddress!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            "Shipping Address: ${order.shippingAddress}",
                            style: TextStyle(
                              color: isArchived ? Colors.grey[500] : Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            "Payment Method: ${order.paymentMethod}",
                            style: TextStyle(
                              color: isArchived ? Colors.grey[500] : Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                      ],
                    ),
                  ),
                  const SizedBox(width: 8), // Add some space
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isDelivered && !isArchived)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('reviews')
                                .where('orderId', isEqualTo: order.id)
                                .limit(1)
                                .snapshots(),
                            builder: (context, snapshot) {
                              final bool hasReview = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                              return Tooltip(
                                message: hasReview ? "View Customer Review" : "No Review Yet",
                                child: Icon(
                                  hasReview ? Icons.star : Icons.star_border,
                                  color: hasReview ? Colors.amber : Colors.grey,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Order Items
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isArchived ? Colors.grey[100] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Items:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${order.itemCount} item(s)",
                          style: TextStyle(
                            color: isArchived ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...order.items.take(3).map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${item['title'] ?? 'Unknown Item'} x${item['quantity'] ?? 1}",
                              style: TextStyle(
                                  fontSize: 14, color: isArchived ? Colors.grey : Colors.black),
                            ),
                          ),
                          Text(
                            "\$${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isArchived ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    if (order.items.length > 3) ...[
                      const SizedBox(height: 4),
                      Text(
                        "... and ${order.items.length - 3} more item(s)",
                        style: TextStyle(
                          color: isArchived ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Amount:",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "\$${order.totalAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isArchived ? Colors.grey[700] : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (!isArchived)
                    OrderStatusDropdown(
                      currentStatus: order.status,
                      onStatusChanged: (newStatus) {
                        onStatusUpdate(order.id, newStatus);
                      },
                    )
                  else
                    Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}