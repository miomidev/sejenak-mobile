import 'dart:convert';
import 'package:selena/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:selena/models/user_models/user_models.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  UserModels? _user;
  static const String _userKey = 'user_data';

  UserModels? get user => _user;

  /// Simpan user ke memory dan SharedPreferences
  Future<void> setUser(UserModels user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    // Set token ke Dio client
    if (user.token != null) {
      DioHttpClient.getInstance().setToken(user.token!);
    }
  }

  /// Load user dari SharedPreferences saat app dibuka
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);

    if (jsonString != null) {
      try {
        final jsonData = jsonDecode(jsonString);
        print("Data dari SharedPreferences = $jsonData");

        _user = UserModels.fromJson(jsonData);

        // Pasang token ke Dio
        if (_user?.token != null) {
          DioHttpClient.getInstance().setToken(_user!.token!);
        }
      } catch (e) {
        print("Gagal memuat user dari prefs: $e");
        _user = null;
      }
    } else {
      print("Tidak ada data user di SharedPreferences.");
    }
  }

  /// Hapus data user dari memory dan SharedPreferences
  Future<void> clearUser() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Cek apakah user sudah login
  bool get isLoggedIn => _user != null;
}
