import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  static const _key = 'last_sign_in_method';

  static Future<void> setMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, method);
  }

  static Future<String?> getMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

}
