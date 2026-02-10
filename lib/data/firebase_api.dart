import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sharp_cut/firebase_push/firebase_push_service.dart';
import 'package:sharp_cut/main.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Got a message whilst in the background!');
  debugPrint('Message data: ${message.data}');

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'background_notification_data',
      jsonEncode(message.data),
    );
    log('Saved background message data to SharedPreferences');
  } catch (e) {
    debugPrint('Error saving background message: $e');
  }
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    debugPrint('Token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
 
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      final context = navigatorKey.currentContext;
      debugPrint("context: $context");
      if (context != null) {
        debugPrint('Context available: $context');
        // ignore: use_build_context_synchronously
        FirebasePushService.callingApiAndChangeStateByPushNotification(
          message,
          context,
        );
      } else {
        debugPrint('Context not available');
        // Fallback to no-context handling if needed, or just log
        FirebasePushService.callingApiAndChangeStateByPushNotification(
          message,
          null,
        );
      }
      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
      }
    });
  }
}
