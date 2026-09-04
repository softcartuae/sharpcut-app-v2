import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sharp_cut/domain/auth/service/auth_repo.dart';
import 'package:sharp_cut/firebase_push/firebase_push_service.dart';
import 'package:sharp_cut/injection_container.dart';
import 'package:sharp_cut/main.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Got a message whilst in the background!');
  log('Message data: ${message.data}');

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
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(_androidChannel);
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await _initLocalNotifications();

    final fCMToken = await _firebaseMessaging.getToken();
    debugPrint('Token: $fCMToken');
    if (fCMToken != null) {
      await sl<AuthRepo>().refreshDeviceToken(fCMToken);
    }
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token Refreshed: $newToken');
      await sl<AuthRepo>().refreshDeviceToken(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      // Show system notification banner in foreground
      showLocalNotification(message);

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
