   import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.notification?.title}");
  print("Background message data: ${message.data}");
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print('User granted permission: ${settings.authorizationStatus}');
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print("FCM Token refreshed: $newToken");
      });
      _isInitialized = true;
      print("Notification service initialized successfully");
    } catch (e) {
      print("Error initializing notification service: $e");
      rethrow;
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print("Foreground message: ${message.notification?.title}");
    print("Message data: ${message.data}");
  }
  static void _handleNotificationTap(RemoteMessage message) {
    print("Notification opened app: ${message.data}");
    _handleNotificationNavigation(message.data.toString());
  }
  static void _handleNotificationNavigation(String? payload) {
    if (payload == null) return;
    print("Navigating based on payload: $payload");
  }

  static Future<void> sendOrderStatusNotification(String orderId, String status) async {
    print("Order notification: Order $orderId is now $status");
  }

  static Future<void> sendPromotionalNotification({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    print("Promotional notification: $title - $body");
  }
  static Future<void> sendChatNotification({
    required String senderName,
    required String message,
  }) async {
    print("Chat notification: New message from $senderName: $message");
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print("Subscribed to topic: $topic");
  }
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print("Unsubscribed from topic: $topic");
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.blue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  static void showOrderStatusUpdate({
    required BuildContext context,
    required String orderId,
    required String status,
  }) {
    String title = 'Order Update';
    String body = 'Your order #${orderId.substring(0, math.min(8, orderId.length))} is now $status';
    Color backgroundColor = Colors.blue;
    switch (status.toLowerCase()) {
      case 'confirmed':
        title = 'Order Confirmed! ✅';
        body = 'Your order #${orderId.substring(0, math.min(8, orderId.length))} has been confirmed and is being processed.';
        backgroundColor = Colors.green;
        break;
      case 'processing':
        title = 'Order Processing 📦';
        body = 'Your order #${orderId.substring(0, math.min(8, orderId.length))} is being prepared for shipment.';
        backgroundColor = Colors.orange;
        break;
      case 'shipped':
        title = 'Order Shipped! 🚚';
        body = 'Your order #${orderId.substring(0, math.min(8, orderId.length))} has been shipped and is on its way.';
        backgroundColor = Colors.purple;
        break;
      case 'delivered':
        title = 'Order Delivered! 🎉';
        body = 'Your order #${orderId.substring(0, math.min(8, orderId.length))} has been delivered. Enjoy your furniture!';
        backgroundColor = Colors.green;
        break;
      case 'cancelled':
        title = 'Order Cancelled ❌';
        body = 'Your order #${orderId.substring(0, math.min(8, orderId.length))} has been cancelled.';
        backgroundColor = Colors.red;
        break;
    }
    showInAppNotification(
      context: context,
      title: title,
      message: body,
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 5),
    );
  }
}