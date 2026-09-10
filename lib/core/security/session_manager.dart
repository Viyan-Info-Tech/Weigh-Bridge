import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userIdKey = 'session_user_id';
  static const String _usernameKey = 'session_username';
  static const String _roleKey = 'session_role';

  final SharedPreferences _prefs;

  SessionManager(this._prefs);

  Future<void> saveSession({
    required int userId,
    required String username,
    required String role,
  }) async {
    await _prefs.setInt(_userIdKey, userId);
    await _prefs.setString(_usernameKey, username);
    await _prefs.setString(_roleKey, role);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_usernameKey);
    await _prefs.remove(_roleKey);
  }

  bool hasActiveSession() {
    return _prefs.containsKey(_userIdKey);
  }

  int? getUserId() => _prefs.getInt(_userIdKey);

  String? getUsername() => _prefs.getString(_usernameKey);

  String? getRole() => _prefs.getString(_roleKey);
}
