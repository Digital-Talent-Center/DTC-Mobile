import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Menyimpan sesi login (token Sanctum + data user) secara persisten
/// memakai shared_preferences, sekaligus cache di memori.
///
/// Dipakai sebagai singleton: `Session.instance`.
class Session {
  Session._();
  static final Session instance = Session._();

  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user';

  String? _token;
  AppUser? _user;

  String? get token => _token;
  AppUser? get user => _user;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  /// Muat sesi tersimpan saat app start.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    final userJson = prefs.getString(_kUser);
    if (userJson != null) {
      try {
        _user = AppUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        _user = null;
      }
    }
  }

  Future<void> save({required String token, AppUser? user}) async {
    _token = token;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    if (user != null) {
      await prefs.setString(_kUser, jsonEncode(user.toJson()));
    }
  }

  Future<void> updateUser(AppUser user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUser, jsonEncode(user.toJson()));
  }

  Future<void> clear() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
  }
}
