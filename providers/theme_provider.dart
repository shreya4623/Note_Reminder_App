import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._prefs) {
    _isDarkMode = _prefs.getBool(AppConstants.themeKey) ?? false;
  }

  final SharedPreferences _prefs;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(AppConstants.themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool(AppConstants.themeKey, _isDarkMode);
    notifyListeners();
  }
}
