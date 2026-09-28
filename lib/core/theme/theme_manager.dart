import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pengelola Tema Global Aplikasi (Light, Dark, System)
class ThemeManager {
  static const String _storageKey = 'app_theme_mode';
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  static ThemeMode get themeMode => themeModeNotifier.value;

  /// Cek apakah saat ini mode gelap aktif berdasarkan notifier atau preferensi sistem
  static bool isDark(BuildContext context) {
    if (themeModeNotifier.value == ThemeMode.dark) return true;
    if (themeModeNotifier.value == ThemeMode.light) return false;
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Dark Mode Tokens
  static const Color darkBg = Color(0xFF0F141C);
  static const Color darkCard = Color(0xFF1E2430);
  static const Color darkBorder = Color(0xFF2D3748);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved == 'dark') {
        themeModeNotifier.value = ThemeMode.dark;
      } else if (saved == 'system') {
        themeModeNotifier.value = ThemeMode.system;
      } else {
        themeModeNotifier.value = ThemeMode.light;
      }
    } catch (_) {}
  }

  static Future<void> setTheme(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      String val = 'light';
      if (mode == ThemeMode.dark) val = 'dark';
      if (mode == ThemeMode.system) val = 'system';
      await prefs.setString(_storageKey, val);
    } catch (_) {}
  }

  // --- Theme Data Definition ---
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B4F9B),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      fontFamily: 'Inter',
      useMaterial3: true,
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B4F9B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B4F9B),
        brightness: Brightness.dark,
        surface: const Color(0xFF1E2430),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F141C),
      fontFamily: 'Inter',
      useMaterial3: true,
      cardColor: const Color(0xFF1E2430),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF151B26),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
