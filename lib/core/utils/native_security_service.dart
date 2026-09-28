import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service untuk berinteraksi dengan Native Security Platform (Android FLAG_SECURE)
/// Melindungi konten premium dari screenshot, screen recording, dan recent apps preview.
class NativeSecurityService {
  static const MethodChannel _channel = MethodChannel('id.nawa.vbat.vbat_ponsel/security');

  static bool _isSecureActive = false;
  static bool get isSecureActive => _isSecureActive;

  /// Mengaktifkan proteksi screenshot & screen recording (FLAG_SECURE)
  static Future<bool> enableSecureMode() async {
    // Pada web/desktop, method channel ini di-skip
    if (kIsWeb) return false;

    try {
      final bool? result = await _channel.invokeMethod<bool>('enableSecureMode');
      _isSecureActive = result ?? false;
      debugPrint('[NativeSecurityService] Secure Mode (FLAG_SECURE) Enabled: $_isSecureActive');
      return _isSecureActive;
    } on MissingPluginException {
      debugPrint('[NativeSecurityService] Security channel not implemented on this platform');
      return false;
    } catch (e) {
      debugPrint('[NativeSecurityService] Error enabling secure mode: $e');
      return false;
    }
  }

  /// Menonaktifkan proteksi setelah user keluar dari video/materi berbayar
  static Future<bool> disableSecureMode() async {
    if (kIsWeb) return false;

    try {
      final bool? result = await _channel.invokeMethod<bool>('disableSecureMode');
      _isSecureActive = !(result ?? false);
      debugPrint('[NativeSecurityService] Secure Mode Disabled');
      return true;
    } on MissingPluginException {
      return false;
    } catch (e) {
      debugPrint('[NativeSecurityService] Error disabling secure mode: $e');
      return false;
    }
  }

  /// Cek apakah platform mendukung FLAG_SECURE
  static Future<bool> isSecureModeSupported() async {
    if (kIsWeb) return false;
    try {
      final bool? result = await _channel.invokeMethod<bool>('isSecureModeSupported');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
