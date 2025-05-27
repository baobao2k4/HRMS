import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(),
);

class LocalStorageService {
  static const String _themeKey = 'app_theme';
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _settingsKey = 'app_settings';
  static const String _cacheKey = 'app_cache';

  Future<void> setTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> setUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    return jsonDecode(userStr) as Map<String, dynamic>;
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsStr = prefs.getString(_settingsKey);
    if (settingsStr == null) return {};
    return jsonDecode(settingsStr) as Map<String, dynamic>;
  }

  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    final currentSettings = await getSettings();
    final updatedSettings = {...currentSettings, ...newSettings};
    await setSettings(updatedSettings);
  }

  Future<void> setCacheData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = await getCacheData();
    cache[key] = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_cacheKey, jsonEncode(cache));
  }

  Future<Map<String, dynamic>> getCacheData() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheStr = prefs.getString(_cacheKey);
    if (cacheStr == null) return {};
    return jsonDecode(cacheStr) as Map<String, dynamic>;
  }

  Future<dynamic> getCachedItem(String key, {Duration? maxAge}) async {
    final cache = await getCacheData();
    final item = cache[key];
    if (item == null) return null;

    if (maxAge != null) {
      final timestamp = DateTime.parse(item['timestamp'] as String);
      final age = DateTime.now().difference(timestamp);
      if (age > maxAge) return null;
    }

    return item['data'];
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  Future<void> clearCacheItem(String key) async {
    final cache = await getCacheData();
    cache.remove(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(cache));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  Future<bool> hasKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<void> setCustomData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      await prefs.setString(key, jsonEncode(value));
    }
  }

  Future<dynamic> getCustomData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }
} 