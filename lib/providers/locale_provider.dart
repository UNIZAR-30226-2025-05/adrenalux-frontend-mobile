import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale? _locale;

  LocaleProvider() {
    loadSavedLocale();
  }

  Locale? get locale => _locale;

  Future<void> loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? localeString = prefs.getString(_localeKey);
    if (localeString != null) {
      final parts = localeString.split('_');
      _locale = Locale(parts[0], parts.length > 1 ? parts[1] : null);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _locale = newLocale;
    await prefs.setString(
      _localeKey,
      '${newLocale.languageCode}_${newLocale.countryCode ?? ''}'
    );
    notifyListeners();
  }

  Future<void> clearSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
    _locale = null;
    notifyListeners();
  }
}