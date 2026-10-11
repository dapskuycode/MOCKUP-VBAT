import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/widgets/sponsor_tier_badge.dart';

/// Data satu tier sponsor seperti yang dikirim server.
class SponsorTierInfo {
  final String slug;
  final String name;
  final String badgeLabel;
  final TierIconSource icon;

  const SponsorTierInfo({
    required this.slug,
    required this.name,
    required this.badgeLabel,
    required this.icon,
  });

  factory SponsorTierInfo.fromJson(Map<String, dynamic> json) {
    return SponsorTierInfo(
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      badgeLabel: (json['badge_label'] ?? '').toString(),
      icon: TierIconSource.fromJson(json),
    );
  }
}

/// Simpanan data tier dari server.
///
/// Admin dapat mengganti nama, warna, dan ikon tier kapan saja. Aplikasi
/// mengambil data itu sekali saat mulai, menyimpannya di sini, lalu seluruh
/// badge tier di aplikasi memakai data yang sama. Jadi pergantian ikon di
/// Admin langsung terpakai tanpa perlu memperbarui aplikasi.
///
/// Bila server tidak dapat dihubungi, bagian ini kosong dan badge memakai
/// ikon serta warna bawaan. Tidak ada yang rusak.
class SponsorTierStore {
  SponsorTierStore._();

  static final ValueNotifier<Map<String, SponsorTierInfo>> tiers =
      ValueNotifier<Map<String, SponsorTierInfo>>({});

  static bool _loading = false;

  /// Ambil daftar tier dari server. Aman dipanggil berkali-kali.
  static Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (!force && tiers.value.isNotEmpty) return;
    _loading = true;

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
          headers: {'Accept': 'application/json'},
        ),
      );
      final res = await dio.get('/sponsors/tiers');
      final dynamic raw = res.data;
      final List list = (raw is Map ? (raw['data'] ?? const []) : raw) as List;

      final Map<String, SponsorTierInfo> parsed = {};
      for (final item in list) {
        if (item is! Map) continue;
        final info = SponsorTierInfo.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (info.slug.isNotEmpty) {
          parsed[info.slug.toLowerCase()] = info;
        }
        if (info.name.isNotEmpty) {
          parsed[info.name.toLowerCase()] = info;
        }
      }
      tiers.value = parsed;

      // Unduh isi berkas SVG ikon sekali, lalu simpan hasilnya. Dengan begitu
      // ikon tampil seketika di seluruh halaman, dan bila berkasnya gagal
      // diunduh aplikasi tetap memakai ikon bawaan tanpa error.
      await _prefetchSvgIcons(parsed);
    } catch (e) {
      debugPrint('SponsorTierStore: gagal memuat tier dari server ($e). '
          'Badge memakai ikon dan warna bawaan.');
    } finally {
      _loading = false;
    }
  }

  /// Cari tier berdasarkan nama atau label mentah seperti "PLATINUM SPONSOR".
  static SponsorTierInfo? find(String rawTier) {
    if (tiers.value.isEmpty) return null;

    final clean = SponsorTierBadge.cleanTierName(rawTier).toLowerCase();
    final exact = tiers.value[clean];
    if (exact != null) return exact;

    final raw = rawTier.toLowerCase();
    for (final entry in tiers.value.entries) {
      if (raw.contains(entry.key)) return entry.value;
    }
    return null;
  }

  /// Unduh isi berkas SVG tiap tier, lalu perbarui simpanan.
  ///
  /// Hanya berkas berakhiran `.svg` yang diunduh isinya. Berkas PNG atau JPG
  /// cukup ditampilkan lewat tautannya. Bila unduhan gagal, tier itu tetap
  /// memakai ikon bawaan aplikasi.
  static Future<void> _prefetchSvgIcons(
    Map<String, SponsorTierInfo> parsed,
  ) async {
    final List<MapEntry<String, SponsorTierInfo>> svgEntries = parsed.entries
        .where((e) =>
            (e.value.icon.url ?? '').toLowerCase().split('?').first.endsWith('.svg'))
        .toList(growable: false);

    if (svgEntries.isEmpty) return;

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        responseType: ResponseType.plain,
      ),
    );

    bool changed = false;

    for (final entry in svgEntries) {
      final info = entry.value;
      final url = info.icon.url;
      if (url == null) continue;

      try {
        final res = await dio.get<String>(url);
        final text = res.data;
        if (text != null &&
            text.contains('<svg') &&
            !text.contains('<html')) {
          final Map<String, SponsorTierInfo> updated =
              Map<String, SponsorTierInfo>.from(tiers.value);
          updated[entry.key] = SponsorTierInfo(
            slug: info.slug,
            name: info.name,
            badgeLabel: info.badgeLabel,
            icon: info.icon.withSvgText(text),
          );
          tiers.value = updated;
          changed = true;
        }
      } catch (e) {
        debugPrint('SponsorTierStore: ikon SVG $url gagal diunduh ($e). '
            'Ikon bawaan aplikasi yang dipakai.');
      }
    }

    if (changed) {
      debugPrint('SponsorTierStore: ${svgEntries.length} ikon tier dari '
          'server siap dipakai.');
    }
  }

  /// Sumber ikon untuk nama tier mentah. Null bila server belum mengirim data.
  static TierIconSource? iconFor(String rawTier) => find(rawTier)?.icon;

  /// Dipakai pengujian: kosongkan simpanan.
  @visibleForTesting
  static void reset() {
    tiers.value = {};
  }

  /// Ubah isi simpanan langsung, dipakai pengujian.
  @visibleForTesting
  static void seedForTest(Map<String, SponsorTierInfo> data) {
    tiers.value = data;
  }
}

/// Bantu baca data tier yang menempel pada objek sponsor atau kampanye dari API.
SponsorTierInfo? tierInfoFromPayload(Map<String, dynamic>? json) {
  if (json == null) return null;

  final direct = json['tier_name'] ?? json['tier'];
  if (direct is String && direct.isNotEmpty) {
    final found = SponsorTierStore.find(direct);
    if (found != null) return found;
  }

  final nested = json['tier_info'] ??
      json['sponsor_tier'] ??
      (json['sponsor'] is Map ? (json['sponsor'] as Map)['tier_info'] : null);
  if (nested is Map) {
    final info = SponsorTierInfo.fromJson(Map<String, dynamic>.from(nested));
    if (info.slug.isNotEmpty || info.name.isNotEmpty) return info;
  }

  return null;
}

/// Bantu pengujian: baca data tier dari teks JSON.
@visibleForTesting
Map<String, SponsorTierInfo> parseTiersForTest(String jsonText) {
  final decoded = jsonDecode(jsonText);
  final List list = (decoded is Map ? (decoded['data'] ?? const []) : decoded) as List;
  final Map<String, SponsorTierInfo> parsed = {};
  for (final item in list) {
    if (item is! Map) continue;
    final info = SponsorTierInfo.fromJson(Map<String, dynamic>.from(item));
    if (info.slug.isNotEmpty) parsed[info.slug.toLowerCase()] = info;
  }
  return parsed;
}
