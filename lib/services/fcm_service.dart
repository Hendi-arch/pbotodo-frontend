import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'shared_pref_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  factory FirebaseMessagingService() => _instance;

  FirebaseMessagingService._();

  Future<void> initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received a new message!');
      // Handle the received message
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('User tapped on the notification!');
      // Handle the notification tap
    });

    try {
      await _firebaseMessaging.requestPermission();
      debugPrint('Firebase Messaging permission granted.');
    } catch (e) {
      debugPrint('Failed to request Firebase Messaging permission: $e');
    }

    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await saveTokenToSharedPref(token);
    }
  }

  Future<void> saveTokenToSharedPref(String token) async {
    try {
      await SharedPrefService().setDeviceId(token);
      debugPrint('Firebase Messaging token $token');
      debugPrint('Firebase Messaging token saved to shared preferences.');
    } catch (e) {
      debugPrint(
          'Failed to save Firebase Messaging token to shared preferences: $e');
    }
  }
}
