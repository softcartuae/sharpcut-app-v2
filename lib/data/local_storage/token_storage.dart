import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharp_cut/utils/helpers/convertion.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _deviceIdKey = 'device_id';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = generateUniqueInt().toString();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
