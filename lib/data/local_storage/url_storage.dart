import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UrlStorage {
  final SharedPreferences _prefs;

  UrlStorage([SharedPreferences? prefs])
      : _prefs = prefs ?? GetIt.instance<SharedPreferences>();

  static const String _ipKey = 'ip_address';
  static const String _portKey = 'port';

  Future<void> saveConnectionDetails(String ip, String port) async {
    await _prefs.setString(_ipKey, ip);
    await _prefs.setString(_portKey, port);
  }

  Future<Map<String, String?>> getConnectionDetails() async {
    return {'ip': _prefs.getString(_ipKey), 'port': _prefs.getString(_portKey)};
  }

  Future<void> clearConnectionDetails() async {
    await _prefs.remove(_ipKey);
    await _prefs.remove(_portKey);
  }
}
