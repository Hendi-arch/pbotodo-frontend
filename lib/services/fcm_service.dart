import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:todo/services/local_notification_service.dart';
import 'shared_pref_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  factory FirebaseMessagingService() => _instance;

  FirebaseMessagingService._();

  final _notificationService = LocalNotificationService();

  Future<void> initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received a new message!');
      _notificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('User tapped on the notification!');
      debugPrint('${message.toMap()}');
      // Handle the notification tap
    });

    try {
      await _firebaseMessaging.requestPermission();
      debugPrint('Firebase Messaging permission granted.');
    } catch (e) {
      debugPrint('Failed to request Firebase Messaging permission: $e');
    }

    await saveTokenToSharedPref();
  }

  Future<void> saveTokenToSharedPref() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await SharedPrefService().setDeviceId(token);
        debugPrint('Firebase Messaging token $token');
        debugPrint('Firebase Messaging token saved to shared preferences.');
      }
    } catch (e) {
      debugPrint(
          'Failed to save Firebase Messaging token to shared preferences: $e');
    }
  }
}
