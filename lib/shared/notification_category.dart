import 'package:flutter/foundation.dart';

/// The available categories of notifications.
@immutable
class NotificationCategory {
  /// Constructs an instance of [NotificationCategory].
  const NotificationCategory(this.value, this.phrase, {this.sound = 'default'});

  /// This category is indicate that the notification is about important task.
  static const NotificationCategory importantNotification =
      NotificationCategory(
          'important_notification_channel_id', 'Important Notification Channel',
          sound: 'important',);

  /// This category is indicate that the notification is about not important task.
  static const NotificationCategory notImportantNotification =
      NotificationCategory('not_important_notification_channel_id',
          'Not Important Notification Channel');

  /// This category is indicate that the notification is unknown.
  static const NotificationCategory unknown =
      NotificationCategory('unknown', 'Unknown');

  /// All the possible values for the [NotificationCategory] enumeration.
  static List<NotificationCategory> get values => [
        importantNotification,
        notImportantNotification,
        unknown,
      ];

  /// Get [NotificationCategory] from [String].
  static NotificationCategory fromString(String? value) {
    return values.firstWhere((category) => category.value == value,
        orElse: () => unknown);
  }

  /// The value representation.
  final String value;

  /// The phrase representation.
  final String phrase;

  /// The sound representation.
  final String sound;
}
