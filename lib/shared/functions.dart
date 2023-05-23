import 'package:intl/intl.dart';

bool hasMinimumLength(String value, int minLength) {
  return value.length >= minLength;
}

bool hasMaximumLength(String value, int maxLength) {
  return value.length > maxLength;
}

bool doesNotContainUppercase(String value) {
  return !value.contains(RegExp(r'[A-Z]'));
}

bool containLowercase(String value) {
  return value.contains(RegExp(r'[a-z]'));
}

bool containsOnlyValidCharacters(String value) {
  return value.contains(RegExp(r'^[a-z0-9_]+$'));
}

bool containsDigitAndSymbol(String value) {
  return RegExp(r'^(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value);
}

String formatDate(DateTime timestamp, [String format = 'd MMM, y hh:mm:ss a']) {
  return DateFormat(format).format(timestamp);
}
