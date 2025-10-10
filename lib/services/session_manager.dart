import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static String? _cachedToken;
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    _cachedToken = token;
  }

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString("auth_token");
    return _cachedToken;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
  }
}