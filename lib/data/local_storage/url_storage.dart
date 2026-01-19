import 'package:shared_preferences/shared_preferences.dart';

class UrlStorage {
  static const String _ipKey = 'ip_address';
  static const String _portKey = 'port';

  Future<void> saveConnectionDetails(String ip, String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);
    await prefs.setString(_portKey, port);
  }

  Future<Map<String, String?>> getConnectionDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {'ip': prefs.getString(_ipKey), 'port': prefs.getString(_portKey)};
  }

  Future<void> clearConnectionDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ipKey);
    await prefs.remove(_portKey);
  }
  
}
