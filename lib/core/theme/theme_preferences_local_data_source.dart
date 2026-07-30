import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferencesLocalDataSource {
  ThemePreferencesLocalDataSource({SharedPreferences? prefs})
      : _injectedPrefs = prefs;

  final SharedPreferences? _injectedPrefs;
  SharedPreferences? _cachedPrefs;

  static const _themeModeKey = 'app_theme_mode';

  Future<SharedPreferences> get _storage async {
    return _injectedPrefs ??
        (_cachedPrefs ??= await SharedPreferences.getInstance());
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await _storage;
    final value = prefs.getString(_themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await _storage;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeModeKey, value);
  }
}
