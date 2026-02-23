import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications(BuildContext context) async {
    // Request permission for iOS mostly, but good practice
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      // TODO: Send this token to backend `/api/v1/user/auth/fcm-token`

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground notification! ${message.notification?.title}');
        
        // Show local snackbar/dialog
        if (message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${message.notification?.title}: ${message.notification?.body}'),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      });
    }
  }
}

// Background handler (Must be a top-level function)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
