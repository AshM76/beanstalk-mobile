// lib/services/notification/push_service.dart
//
// Firebase Cloud Messaging integration: requests permission, obtains the device
// token, registers it with the backend (POST /api/notifications/register-token),
// and renders foreground pushes via a local notification.
//
// Mobile only. On web (used for `flutter run -d chrome` dev) this is a no-op —
// there is no web Firebase config wired up, and dart:io isn't available there.

import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api/api_service.dart';

/// Background/terminated-state handler. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Notification-type messages are rendered by the OS; nothing to do here.
  // Firebase must be initialized in this isolate before touching any APIs.
  await Firebase.initializeApp();
}

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  bool _started = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'beanstalk_default',
    'Beanstalk',
    description: 'Contest updates, leaderboard changes, and reminders',
    importance: Importance.high,
  );

  /// Initialize FCM. Call once at startup after Firebase.initializeApp() and
  /// ApiService().init(). Idempotent — call it again after login to register
  /// the token now that the user is authenticated.
  Future<void> start() async {
    if (kIsWeb) return; // no web FCM config; keeps chrome dev working

    if (_started) {
      await _registerToken();
      return;
    }
    _started = true;

    // Local notifications: foreground display + the Android channel.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // firebase_messaging.requestPermission() owns the iOS prompt.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _local.initialize(initSettings);
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Permission prompt (iOS, and Android 13+).
    await FirebaseMessaging.instance.requestPermission();

    // iOS: also surface notifications while the app is in the foreground.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      ApiService().registerPushToken(t, platform: _platform());
    });

    await _registerToken();
  }

  Future<void> _registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await ApiService().registerPushToken(token, platform: _platform());
        debugPrint('[Push] registered device token ${token.substring(0, 12)}…');
      }
    } catch (e) {
      debugPrint('[Push] token registration failed: $e');
    }
  }

  void _showForeground(RemoteMessage m) {
    final n = m.notification;
    if (n == null) return;
    _local.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  String _platform() =>
      Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'other');
}
