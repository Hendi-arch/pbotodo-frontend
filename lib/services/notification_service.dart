import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo/shared/notification_category.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  factory LocalNotificationService() => _instance;

  LocalNotificationService._internal();

  // create initialization settings for specific platform
  static AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('app_icon');

  static DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  static AndroidNotificationChannel _androidNotificationChannel({
    required String channelId,
    required String channelName,
    RawResourceAndroidNotificationSound? sound,
  }) {
    return AndroidNotificationChannel(
      channelId,
      channelName,
      sound: sound,
      playSound: true,
      showBadge: true,
      enableLights: true,
      enableVibration: true,
      importance: Importance.max,
    );
  }

  static InitializationSettings initializationSettings = InitializationSettings(
    iOS: initializationSettingsIOS,
    android: initializationSettingsAndroid,
  );

  static NotificationDetails _platformChannelSpecifics({
    required String channelId,
    required String channelName,
    required String sound,
  }) {
    return NotificationDetails(
      iOS: DarwinNotificationDetails(
        sound: sound,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        playSound: true,
        enableLights: true,
        enableVibration: true,
        priority: Priority.max,
        importance: Importance.max,
        sound: sound == NotificationCategory.unknown.sound
            ? null
            : RawResourceAndroidNotificationSound(sound),
      ),
    );
  }

  // Android notification channels
  static AndroidNotificationChannel _importantNotificationChannel() =>
      _androidNotificationChannel(
        channelId: NotificationCategory.importantNotification.value,
        channelName: 'Important Notification Channel',
        sound: const RawResourceAndroidNotificationSound('important'),
      );

  static AndroidNotificationChannel _notImportantNotificationChannel() =>
      _androidNotificationChannel(
        channelId: NotificationCategory.notImportantNotification.value,
        channelName: 'Not Important Notification Channel',
      );
  // End

  // initialization service
  Future initializeLocalNotification() async {
    try {
      bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();

      debugPrint('Local Notification permission status: $result');
    } catch (e) {
      debugPrint('Failed to request Local Notification permission: $e');
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_importantNotificationChannel());

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_notImportantNotificationChannel());

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );
  }

  Future showNotification(RemoteMessage remoteMessage) async {
    NotificationCategory notificationCategory = NotificationCategory.fromString(
        remoteMessage.data['taskUrgency'] ?? '');
    await flutterLocalNotificationsPlugin.show(
      remoteMessage.hashCode,
      remoteMessage.notification?.title,
      remoteMessage.notification?.body,
      _platformChannelSpecifics(
        channelId: notificationCategory.value,
        channelName: notificationCategory.phrase,
        sound: notificationCategory.sound,
      ),
      payload: jsonEncode(remoteMessage.data),
    );
  }

  Future cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void onSelectNotification(NotificationResponse? response) {
    debugPrint("Payload string ${response?.payload}");
  }
}
