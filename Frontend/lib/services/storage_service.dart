// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../data/models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get _instance async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveTempToken(String tempToken) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.tempTokenKey, tempToken);
  }

  Future<String?> getTempToken() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.tempTokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await _instance;
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.tempTokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  Future<void> clearTempToken() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.tempTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _instance;
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }
}