// lib/core/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _languageKey = 'language_code';
  
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      state = Locale(languageCode);
    } catch (e) {
      state = const Locale('en');
    }
  }

  Future<void> setLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      state = Locale(languageCode);
    } catch (e) {
      state = const Locale('en');
    }
  }

  String getCurrentLanguage() {
    return state.languageCode;
  }

  bool isArabic() {
    return state.languageCode == 'ar';
  }

  bool isEnglish() {
    return state.languageCode == 'en';
  }

  Future<void> toggleLanguage() async {
    final newLang = isArabic() ? 'en' : 'ar';
    await setLocale(newLang);
  }
}