import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme;
  static ThemeData temaOscuro = ThemeData.dark();
  static ThemeData temaClaro = ThemeData.light();

  ThemeProvider({bool? isDarkTheme})
      : _isDarkTheme = isDarkTheme ?? 
            (PlatformDispatcher.instance.platformBrightness == Brightness.dark) {
    _loadThemeFromPreferences();
  }

  bool get isDarkTheme => _isDarkTheme;

  ThemeData get currentTheme {
    return isDarkTheme ? temaOscuro : temaClaro;
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _saveThemeToPreferences();
    notifyListeners();
  }

  void _loadThemeFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? _isDarkTheme;
    notifyListeners();
  }

  void _saveThemeToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _isDarkTheme);
  }

  String getLogo() {
    return isDarkTheme ? 'assets/adrenalux_logo_white.png' : 'assets/adrenalux_logo_black.png';
  }
}
