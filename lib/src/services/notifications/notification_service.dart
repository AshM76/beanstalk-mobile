import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  //Singleton pattern
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  //instance of FlutterLocalNotificationsPlugin
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  void requestIOSPermissions() {
    _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future init() async {
    //Initialization Settings for android devices
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    //Initialization Settings for iOS devices
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final notificationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      notificationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // switch (notificationResponse.notificationResponseType) {
        //   case NotificationResponseType.selectedNotification:
        //     selectNotificationStream.add(notificationResponse.payload);
        //     break;
        //   case NotificationResponseType.selectedNotificationAction:
        //     if (notificationResponse.actionId == navigationActionId) {
        //       selectNotificationStream.add(notificationResponse.payload);
        //     }
        //     break;
        // }
      },
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  static Future _notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        playSound: true,
        // icon: android?.smallIcon,
        priority: Priority.max,
        importance: Importance.max,
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: false),
    );
  }

  int getHashCode() {
    final kToday = DateTime.now();
    return kToday.hour * 1000000 + kToday.minute * 10000 + kToday.second;
  }

  Future<void> showNotification({
    String? title,
    String? body,
    String? payload,
  }) async {
    await _notifications.show(
      getHashCode(),
      title,
      body,
      await (_notificationDetails() as FutureOr<NotificationDetails?>),
      payload: payload,
    );
  }

  Future<void> showNotificationSchedule({String? title, String? body, String? payload, required DateTime scheduledNotificationDateTime}) async {
    await _notifications.zonedSchedule(
      getHashCode(),
      title,
      body,
      tz.TZDateTime.from(
        scheduledNotificationDateTime,
        tz.local,
      ),
      await (_notificationDetails() as FutureOr<NotificationDetails>),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
