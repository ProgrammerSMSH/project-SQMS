import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = "theme_preference";
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    return await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    final SharedPreferences prefs = await _initPrefs();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    final SharedPreferences prefs = await _initPrefs();
    prefs.setBool(_themeKey, _isDarkMode);
  }
}
