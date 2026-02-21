import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharp_cut/utils/helpers/convertion.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _deviceIdKey = 'device_id';
  static const String _modeKey = 'auth_mode';
  static const String _isChairKey = 'auth_is_chair';
  static const String _syncTimeKey = 'auth_sync_time';

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

  Future<void> saveMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode);
  }

  Future<String?> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modeKey);
  }

  Future<void> saveIsChair(bool isChair) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isChairKey, isChair);
  }

  Future<bool?> getIsChair() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isChairKey);
  }

  Future<void> saveSyncTime(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_syncTimeKey, minutes);
  }

  Future<int> getSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_syncTimeKey) ?? 15; // Default to 30 mins
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
