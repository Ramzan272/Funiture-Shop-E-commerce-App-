import 'package:flutter/material.dart';

import '../user_side/chat_screen.dart';
import '../user_side/orders_screen.dart';
import '../user_side/product/products_screen.dart';

class NotificationHelper {
  static void handleNotificationNavigation(String? payload, BuildContext context) {
    if (payload == null) return;
    try {
      if (payload.contains('order_update')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrdersScreen()),
        );
      } else if (payload.contains('chat')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      } else if (payload.contains('promotional')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductsScreen()),
        );
      } else {
        print('Unknown notification type: $payload');
      }
    } catch (e) {
      print('Error handling notification navigation: $e');
    }
  }
  static void showInAppNotification({
    required BuildContext context,
    required String title,
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.blue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
