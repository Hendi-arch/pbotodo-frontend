import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:todo/Services/shared_pref_service.dart';

class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService _instance =
      FirebaseAnalyticsService._();

  factory FirebaseAnalyticsService() => _instance;

  FirebaseAnalyticsService._();

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  Future<void> logAppOpen() async {
    await FirebaseAnalytics.instance.logAppOpen();
  }

  Future<void> logLogin() async {
    await FirebaseAnalytics.instance
        .logLogin(loginMethod: 'username_and_password');
  }

  Future<void> logSignUp() async {
    await FirebaseAnalytics.instance
        .logSignUp(signUpMethod: 'username_and_password');
  }

  Future<void> logUserInformation() async {
    String? username = await SharedPrefService().getUsername();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        await _logUserProperties(
          username: username ?? '',
          deviceId: androidInfo.id,
          deviceModel: androidInfo.model,
          manufacturer: androidInfo.manufacturer,
          osVersion: androidInfo.version.release,
        );
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        await _logUserProperties(
          username: username ?? '',
          deviceId: iosInfo.identifierForVendor ?? '',
          deviceModel: iosInfo.model,
          manufacturer: 'Apple',
          osVersion: iosInfo.systemVersion,
        );
      }
      debugPrint('Device information logged to Firebase Analytics.');
    } catch (e) {
      debugPrint('Failed to log device information to Firebase Analytics: $e');
    }
  }

  Future<void> _logUserProperties({
    required String username,
    required String deviceId,
    required String deviceModel,
    required String manufacturer,
    required String osVersion,
  }) async {
    await FirebaseAnalytics.instance
        .setUserProperty(name: 'username', value: username);
    await FirebaseAnalytics.instance
        .setUserProperty(name: 'device_id', value: deviceId);
    await FirebaseAnalytics.instance
        .setUserProperty(name: 'device_model', value: deviceModel);
    await FirebaseAnalytics.instance
        .setUserProperty(name: 'manufacturer', value: manufacturer);
    await FirebaseAnalytics.instance
        .setUserProperty(name: 'os_version', value: osVersion);
  }

  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}
