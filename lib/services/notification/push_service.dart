// lib/services/notification/push_service.dart
//
// Firebase Cloud Messaging integration: requests permission, obtains the device
// token, registers it with the backend (POST /api/notifications/register-token),
// and renders foreground pushes via a local notification.
//
// Mobile only. On web (used for `flutter run -d chrome` dev) this is a no-op —
// there is no web Firebase config wired up, and dart:io isn't available there.

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../api/api_service.dart';
import '../../config/app_config.dart';

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

  // TEMP push diagnostic: a run id tags each launch's reports so they can be
  // read together via GET /api/notifications/debug-report.
  final String _runId = DateTime.now().millisecondsSinceEpoch.toRadixString(36);

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'beanstalk_default',
    'Beanstalk',
    description: 'Contest updates, leaderboard changes, and reminders',
    importance: Importance.high,
  );

  // TEMP: phone home a push-init stage over plain HTTP (no auth / no JWT), so we
  // can see exactly where iOS push fails even when login or Firebase init is the
  // cause. Readable at GET /api/notifications/debug-report. Best-effort.
  Future<void> _report(String stage, {String? detail}) async {
    try {
      await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/api/notifications/debug-report'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'run': _runId,
              'platform': kIsWeb
                  ? 'web'
                  : (Platform.isIOS
                      ? 'ios'
                      : (Platform.isAndroid ? 'android' : 'other')),
              'stage': stage,
              if (detail != null) 'detail': detail,
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // never throw from a diagnostic
    }
  }

  /// Initialize FCM. Call once at startup after Firebase.initializeApp() and
  /// ApiService().init(). Idempotent — call it again after login to register
  /// the token now that the user is authenticated.
  Future<void> start() async {
    if (kIsWeb) return; // no web FCM config; keeps chrome dev working

    await _report('start-called', detail: _started ? 'already-started' : 'first');

    if (_started) {
      await _registerToken();
      return;
    }
    _started = true;

    try {
      // Local notifications: foreground display + the Android channel.
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
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
      await _report('local-notif-ok');

      // Permission prompt (iOS, and Android 13+).
      final settings = await FirebaseMessaging.instance.requestPermission();
      await _report('permission',
          detail: settings.authorizationStatus.toString());

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
        _report('token-refresh', detail: 'set');
      });

      await _registerToken();
    } catch (e) {
      await _report('start-error', detail: e.toString());
    }
  }

  Future<void> _registerToken() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        var apns = await FirebaseMessaging.instance.getAPNSToken();
        for (var i = 0; apns == null && i < 12; i++) {
          await Future.delayed(const Duration(seconds: 1));
          apns = await FirebaseMessaging.instance.getAPNSToken();
        }
        await _report('apns', detail: apns == null ? 'null' : 'set');
        if (apns == null) return;
      }
      final token = await FirebaseMessaging.instance.getToken();
      await _report('fcm', detail: token == null ? 'null' : 'set');
      if (token != null && token.isNotEmpty) {
        await ApiService().registerPushToken(token, platform: _platform());
        await _report('registered',
            detail: token.substring(0, token.length < 12 ? token.length : 12));
      }
    } catch (e) {
      await _report('token-error', detail: e.toString());
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
