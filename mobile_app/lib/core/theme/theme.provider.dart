// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'theme_mode';
  late SharedPreferences _prefs;
  bool _isDarkMode;

  ThemeProvider() : _isDarkMode = false {
    _loadFromPrefs();
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setBool(_key, _isDarkMode);
  }
}