import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const String _prefKey = 'app_language_code';

  final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(const Locale('id'));

  Locale get currentLocale => localeNotifier.value;
  bool get isIndonesian => localeNotifier.value.languageCode == 'id';
  bool get isEnglish => localeNotifier.value.languageCode == 'en';

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null && (savedCode == 'en' || savedCode == 'id')) {
        localeNotifier.value = Locale(savedCode);
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale newLocale) async {
    if (newLocale.languageCode != 'en' && newLocale.languageCode != 'id') return;
    localeNotifier.value = newLocale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLocale.languageCode);
    } catch (_) {}
  }

  Future<void> toggleLocale() async {
    final target = isIndonesian ? const Locale('en') : const Locale('id');
    await setLocale(target);
  }
}
