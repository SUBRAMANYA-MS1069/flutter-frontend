import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeProvider() {
    _loadThemeFromPrefs();
  }
  
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(AppConfig.themeKey);
    
    if (themeName == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeName == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    String themeName;
    
    switch (mode) {
      case ThemeMode.light:
        themeName = 'light';
        break;
      case ThemeMode.dark:
        themeName = 'dark';
        break;
      default:
        themeName = 'system';
    }
    
    await prefs.setString(AppConfig.themeKey, themeName);
    notifyListeners();
  }
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}