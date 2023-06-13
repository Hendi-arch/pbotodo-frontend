import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static final SharedPrefService _instance = SharedPrefService._();
  static const String _usernameKey = 'username';
  static const String _tokenKey = 'token';
  static const String _deviceIdKey = 'deviceId';
  static const String _showCaseAuthButtonKey = 'showCaseAuthButtonKey';
  static const String _showCaseAccountButtonKey = 'showCaseAccountButtonKey';
  static const String _showCaseAddTaskButtonKey = 'showCaseAddTaskButtonKey';
  static const String _showCaseLogoutButtonKey = 'showCaseLogoutButtonKey';
  static const String _showCaseFeedbackButtonKey = 'showCaseFeedbackButtonKey';
  static const String _showCaseForgotPasswordButtonKey =
      'showCaseForgotPasswordButtonKey';
  SharedPreferences? _prefs;

  factory SharedPrefService() => _instance;

  SharedPrefService._();

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveCredentials(String username, String token) async {
    final prefs = await this.prefs;
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_tokenKey, token);
  }

  Future<void> removeCredentials() async {
    final prefs = await this.prefs;
    await prefs.remove(_usernameKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_deviceIdKey);
  }

  Future<String?> getUsername() async {
    final prefs = await this.prefs;
    return prefs.getString(_usernameKey);
  }

  Future<String?> getToken() async {
    final prefs = await this.prefs;
    return prefs.getString(_tokenKey);
  }

  Future<String?> getDeviceId() async {
    final prefs = await this.prefs;
    return prefs.getString(_deviceIdKey);
  }

  Future<bool> getShowCaseAuthButtonKey() async {
    final prefs = await this.prefs;
    return prefs.getBool(_showCaseAuthButtonKey) ?? false;
  }

  Future<bool> getShowCaseAccountButtonKey() async {
    final prefs = await this.prefs;
    return prefs.getBool(_showCaseAccountButtonKey) ?? false;
  }

  Future<bool> getShowCaseAddTaskButtonKey() async {
    final prefs = await this.prefs;
    return prefs.getBool(_showCaseAddTaskButtonKey) ?? false;
  }

  Future<bool> getShowCasLogoutButtonKey() async {
    final prefs = await this.prefs;
    return prefs.getBool(_showCaseLogoutButtonKey) ?? false;
  }

  Future<bool> getShowCasFeedbackButtonKey() async {
    final prefs = await this.prefs;
    return prefs.getBool(_showCaseFeedbackButtonKey) ?? false;
  }

  Future<bool> getShowCaseForgotPasswordButtonKey() async {
    final prefs = await this.prefs;
    return prefs.getBool(_showCaseForgotPasswordButtonKey) ?? false;
  }

  Future<bool?> setShowCaseAuthButtonKey(bool value) async {
    final prefs = await this.prefs;
    return prefs.setBool(_showCaseAuthButtonKey, value);
  }

  Future<bool?> setShowCaseAccountButtonKey(bool value) async {
    final prefs = await this.prefs;
    return prefs.setBool(_showCaseAccountButtonKey, value);
  }

  Future<bool?> setShowCaseAddTaskButtonKey(bool value) async {
    final prefs = await this.prefs;
    return prefs.setBool(_showCaseAddTaskButtonKey, value);
  }

  Future<bool?> setShowCaseLogoutButtonKey(bool value) async {
    final prefs = await this.prefs;
    return prefs.setBool(_showCaseLogoutButtonKey, value);
  }

  Future<bool?> setShowCaseFeedbackButtonKey(bool value) async {
    final prefs = await this.prefs;
    return prefs.setBool(_showCaseFeedbackButtonKey, value);
  }

  Future<bool?> setShowCaseForgotPasswordButtonKey(bool value) async {
    final prefs = await this.prefs;
    return prefs.setBool(_showCaseForgotPasswordButtonKey, value);
  }

  Future<bool> setDeviceId(String deviceId) async {
    final prefs = await this.prefs;
    return prefs.setString(_deviceIdKey, deviceId);
  }

  Future<bool> isHaveCredentials() async {
    final username = await getUsername();
    final token = await getToken();
    return username != null && token != null;
  }
}
