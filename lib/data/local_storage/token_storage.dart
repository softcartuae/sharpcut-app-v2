import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  static const String _tokenKey = 'auth_token';
  static const String _modeKey = 'auth_mode';
  static const String _isChairKey = 'auth_is_chair';
  static const String _isCashierKey = 'auth_is_cashier';

  // ─────────────── Token ───────────────

  Future<void> saveToken(String token) async =>
      _prefs.setString(_tokenKey, token);

  String? getToken() => _prefs.getString(_tokenKey);

  // ─────────────── Mode ────────────────

  Future<void> saveMode(String mode) async =>
      _prefs.setString(_modeKey, mode);

  String? getMode() => _prefs.getString(_modeKey);

  // ─────────────── isChair ─────────────

  Future<void> saveIsChair(bool isChair) async =>
      _prefs.setBool(_isChairKey, isChair);

  bool? getIsChair() => _prefs.getBool(_isChairKey);

  // ─────────────── isCashier ───────────

  Future<void> saveIsCashier(bool isCashier) async =>
      _prefs.setBool(_isCashierKey, isCashier);

  bool? getIsCashier() => _prefs.getBool(_isCashierKey);

  // ─────────────── Cleanup ─────────────

  Future<void> deleteToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_modeKey);
    await _prefs.remove(_isChairKey);
    await _prefs.remove(_isCashierKey);
  }
}
