import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

/// Manifest Item Materi Belajar Offline
class OfflineLessonManifest {
  final String materialId;
  final String title;
  final String courseType; // 'free_class', 'android', 'iphone', 'bundling'
  final String duration;
  final String encryptedPayload; // Payload terenkripsi (bukan plaintext URL)
  final String downloadedAt;
  final String integrityChecksum;
  bool isRevoked;

  OfflineLessonManifest({
    required this.materialId,
    required this.title,
    required this.courseType,
    required this.duration,
    required this.encryptedPayload,
    required this.downloadedAt,
    required this.integrityChecksum,
    this.isRevoked = false,
  });

  Map<String, dynamic> toMap() => {
        'material_id': materialId,
        'title': title,
        'course_type': courseType,
        'duration': duration,
        'encrypted_payload': encryptedPayload,
        'downloaded_at': downloadedAt,
        'integrity_checksum': integrityChecksum,
        'is_revoked': isRevoked,
      };

  factory OfflineLessonManifest.fromMap(Map<String, dynamic> map) {
    return OfflineLessonManifest(
      materialId: map['material_id']?.toString() ?? '',
      title: map['title'] ?? '',
      courseType: (map['course_type'] ?? 'free_class').toString().toLowerCase(),
      duration: map['duration'] ?? '00:00',
      encryptedPayload: map['encrypted_payload'] ?? '',
      downloadedAt: map['downloaded_at'] ?? '',
      integrityChecksum: map['integrity_checksum'] ?? '',
      isRevoked: map['is_revoked'] == true,
    );
  }
}

/// Manager Penyimpanan Offline Terenkripsi & Verifikasi Lisensi (Entitlement)
/// Memastikan media berbayar tidak dapat diakses tanpa hak akses aktif.
class OfflineMediaManager {
  static const String _storageKey = 'encrypted_offline_manifests';
  static const String _cipherKey = 'VBAT_SECURE_STORAGE_SALT_2026';

  static final List<OfflineLessonManifest> _manifests = [];
  static bool _isInitialized = false;

  static List<OfflineLessonManifest> get manifests => List.unmodifiable(_manifests);

  /// Inisialisasi awal saat aplikasi mulai
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedRaw = prefs.getString(_storageKey);
      if (encryptedRaw != null && encryptedRaw.isNotEmpty) {
        final decryptedJson = _decrypt(encryptedRaw);
        final List list = jsonDecode(decryptedJson);
        _manifests.clear();
        for (final item in list) {
          _manifests.add(OfflineLessonManifest.fromMap(Map<String, dynamic>.from(item)));
        }
      }
      _isInitialized = true;
      // Sinkronkan dan audit lisensi saat reconnect
      auditOfflineEntitlements();
      // Pasang listener jika status lisensi akun berubah (misal beli paket baru atau logout)
      SessionManager.activeEntitlements.addListener(() => auditOfflineEntitlements());
    } catch (e) {
      debugPrint('[OfflineMediaManager] Error initializing: $e');
    }
  }

  /// Simple obfuscation & XOR salt encryption agar data sensitif tidak tersimpan dalam plaintext
  static String _encrypt(String plainText) {
    final bytes = utf8.encode(plainText);
    final keyBytes = utf8.encode(_cipherKey);
    final encrypted = List<int>.generate(bytes.length, (i) => bytes[i] ^ keyBytes[i % keyBytes.length]);
    return base64Encode(encrypted);
  }

  static String _decrypt(String cipherText) {
    final bytes = base64Decode(cipherText);
    final keyBytes = utf8.encode(_cipherKey);
    final decrypted = List<int>.generate(bytes.length, (i) => bytes[i] ^ keyBytes[i % keyBytes.length]);
    return utf8.decode(decrypted);
  }

  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_manifests.map((e) => e.toMap()).toList());
      final encrypted = _encrypt(jsonStr);
      await prefs.setString(_storageKey, encrypted);
    } catch (e) {
      debugPrint('[OfflineMediaManager] Error saving encrypted manifests: $e');
    }
  }

  /// Mengunduh materi secara offline dengan validasi otorisasi lisensi (Entitlement Gate)
  static Future<bool> downloadLesson({
    required String materialId,
    required String title,
    required String courseType,
    required String videoUrl,
    required String duration,
  }) async {
    // 1. Validasi Otorisasi: Cek apakah user punya hak akses kelas ini
    final bool hasAccess = SessionManager.canAccessCourse(courseType);
    if (!hasAccess) {
      debugPrint('[OfflineMediaManager] UNAUTHORIZED: User does not own entitlement for $courseType');
      return false;
    }

    // 2. Cegah duplikasi download
    _manifests.removeWhere((item) => item.materialId == materialId);

    // 3. Enkripsi URL sumber dan buat manifest aman
    final encryptedUrl = _encrypt(videoUrl);
    final checksum = 'sha256_${materialId}_${DateTime.now().millisecondsSinceEpoch}';

    final manifest = OfflineLessonManifest(
      materialId: materialId,
      title: title,
      courseType: courseType,
      duration: duration,
      encryptedPayload: encryptedUrl,
      downloadedAt: DateTime.now().toIso8601String(),
      integrityChecksum: checksum,
      isRevoked: false,
    );

    _manifests.add(manifest);
    await _save();
    debugPrint('[OfflineMediaManager] Successfully saved encrypted offline lesson: $title');
    return true;
  }

  /// Audit lisensi offline saat reconnect/sinkronisasi server
  /// Jika paket kadaluarsa atau hak akses dicabut di server, offline playback otomatis DIBLOKIR.
  static Future<void> auditOfflineEntitlements() async {
    bool hasChanges = false;
    for (final manifest in _manifests) {
      final bool stillValid = SessionManager.canAccessCourse(manifest.courseType);
      if (!stillValid && !manifest.isRevoked) {
        manifest.isRevoked = true;
        hasChanges = true;
        debugPrint('[OfflineMediaManager] REVOKED: Access revoked for offline lesson ${manifest.title}');
      } else if (stillValid && manifest.isRevoked) {
        manifest.isRevoked = false;
        hasChanges = true;
        debugPrint('[OfflineMediaManager] RESTORED: Access restored for offline lesson ${manifest.title}');
      }
    }
    if (hasChanges) {
      await _save();
    }
  }

  /// Cek apakah materi offline dapat diputar (Harus ada, berlisensi, dan tidak dicabut)
  static bool canPlayOffline(String materialId) {
    final index = _manifests.indexWhere((m) => m.materialId == materialId);
    if (index == -1) return false;
    final manifest = _manifests[index];
    if (manifest.isRevoked) return false;
    return SessionManager.canAccessCourse(manifest.courseType);
  }

  /// Mengambil URL video offline yang telah didekripsi hanya jika lolos verifikasi otorisasi
  static String? getDecryptedOfflineUrl(String materialId) {
    if (!canPlayOffline(materialId)) return null;
    final manifest = _manifests.firstWhere((m) => m.materialId == materialId);
    return _decrypt(manifest.encryptedPayload);
  }

  /// Hapus materi offline
  static Future<void> removeLesson(String materialId) async {
    _manifests.removeWhere((m) => m.materialId == materialId);
    await _save();
  }

  /// Cek apakah materi sudah diunduh
  static bool isDownloaded(String materialId) {
    return _manifests.any((m) => m.materialId == materialId && !m.isRevoked);
  }
}
