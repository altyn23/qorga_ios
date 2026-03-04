import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  ThemeController._();

  static const _prefKey = 'dark_mode_enabled';
  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefKey) ?? false;
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDark => mode.value == ThemeMode.dark;

  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, isDark);
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
