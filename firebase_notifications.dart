import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseNotifications {
  static Future<void> initialize(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      // Request permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('User granted permission: ${settings.authorizationStatus}');

      // Retrieve FCM token
      String? token = await messaging.getToken();
      debugPrint('FCM Token: $token');
      // TODO: Send token to the backend for user identification

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notification: ${message.notification?.title}'),
            ),
          );
        }
      });

      // Handle notification clicks (background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(context, message);
      });

      // Handle notification clicks (terminated state)
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(context, initialMessage);
      }
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  static void _handleNotificationTap(BuildContext context, RemoteMessage message) {
    Navigator.pushNamed(context, 'notificationScreen');
  }
}
