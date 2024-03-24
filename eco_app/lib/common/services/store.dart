import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  const Store._();

  static const String _tokenKey = "TOKEN";
  static const String _refreshToken = "REFRESH_TOKEN";
  static const String _isDarkMode = "IS_DARK_MODE";
  static const String _userAvatar = "USER_AVATAR";
  static const String _guestUserId = "GUEST_USER_ID";

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  static Future<void> setTheme(bool isDarkMode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_isDarkMode, isDarkMode);
  }

  static Future<bool?> getTheme() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isDarkMode);
  }

  static Future<void> setToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_refreshToken, refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_refreshToken);
  }

  static Future<Uint8List> getUserAvatar() async {
    final preferences = await SharedPreferences.getInstance();
    final avatar = preferences.getString(_userAvatar);
    if (avatar != null) {
      return Uint8List.fromList(avatar.codeUnits);
    }
    return Uint8List(0);
  }

  static Future<void> setUserAvatar(Uint8List avatar) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userAvatar, String.fromCharCodes(avatar));
  }

  static Future<void> setGuestUserId(String guestUserId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_guestUserId, guestUserId);
  }

  static Future<String?> getGuestUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_guestUserId);
  }
}
