import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static final SharedPrefService _instance = SharedPrefService._();
  static const String _usernameKey = 'username';
  static const String _tokenKey = 'token';
  static const String _deviceIdKey = 'deviceId';
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

  Future<bool> setDeviceId(String deviceId) async {
    final prefs = await this.prefs;
    return prefs.setString(_deviceIdKey, deviceId);
  }

  Future<String?> getDeviceId() async {
    final prefs = await this.prefs;
    return prefs.getString(_deviceIdKey);
  }

  Future<bool> isHaveCredentials() async {
    final username = await getUsername();
    final token = await getToken();
    return username != null && token != null;
  }
}
