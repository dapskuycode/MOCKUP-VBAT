import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Konfigurasi Global Aplikasi & Environment
/// Mendukung konfigurasi aman saat build (via --dart-define) atau dinamis di runtime
class AppConfig {
  static const String appName = 'VBat Ponsel';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 4;
  static const String buildEnvironment = kReleaseMode ? 'production' : 'staging/local';

  static const String _defaultApiUrl = 'http://127.0.0.1:8000/api/v1';
  static const String _prefKeyApiBaseUrl = 'custom_api_base_url';

  // Base URL yang dapat di-override melalui compile-time flag:
  // flutter build apk --dart-define=API_BASE_URL=https://api.vbat.id/api/v1
  static String _apiBaseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiUrl,
  );

  static String get apiBaseUrl => _apiBaseUrl;

  /// Inisialisasi konfigurasi saat startup
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customUrl = prefs.getString(_prefKeyApiBaseUrl);
      if (customUrl != null && customUrl.isNotEmpty) {
        _apiBaseUrl = customUrl;
      }
      debugPrint('[AppConfig] Initialized. Env: $buildEnvironment | API Base URL: $_apiBaseUrl');
    } catch (e) {
      debugPrint('[AppConfig] Error initializing config: $e');
    }
  }

  /// Override URL secara dinamis untuk pengujian staging/production
  static Future<void> setBaseUrl(String newUrl) async {
    _apiBaseUrl = newUrl;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyApiBaseUrl, newUrl);
    } catch (e) {
      debugPrint('[AppConfig] Error saving custom URL: $e');
    }
  }
}
