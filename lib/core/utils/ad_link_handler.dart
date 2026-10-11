import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:vbat_ponsel/core/utils/session_manager.dart';

/// Membuka tujuan yang diatur pada sebuah iklan.
///
/// Satu iklan bisa diarahkan ke mana saja. Tujuannya ditulis di kolom
/// `target_url` pada data iklan, dengan bentuk:
///
/// **Tautan luar** — dibuka di browser atau aplikasi lain:
/// - `https://shopee.co.id/produk-abc`
/// - `https://tokopedia.com/toko-mitra`
///
/// **Halaman di dalam aplikasi** — dibuka tanpa keluar dari aplikasi:
/// - `vbat://home` — tab Beranda
/// - `vbat://shop` — tab Shop
/// - `vbat://belajar` — tab Belajar
/// - `vbat://forum` — tab Forum
/// - `vbat://akun` — tab Akun
/// - `vbat://event` — halaman Event Diskon
/// - `vbat://best-deals` — halaman Best Deal
/// - `vbat://product/12` — halaman produk nomor 12
/// - `vbat://sponsor/5` — halaman mitra nomor 5
///
/// Nama menu tanpa awalan juga diterima, misalnya `event` atau `best-deals`.
/// Kalau tujuannya tidak dikenali, tautan dicoba dibuka sebagai tautan luar.
class AdLinkHandler {
  AdLinkHandler._();

  /// Buka [raw] sebagai tujuan iklan.
  static Future<void> open(BuildContext context, String raw) async {
    final String target = raw.trim();
    if (target.isEmpty) return;

    final String lower = target.toLowerCase();

    // 1. Tautan luar.
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      await _openExternal(target);
      return;
    }

    // 2. Halaman di dalam aplikasi.
    String path = target;
    if (lower.startsWith('vbat://')) {
      path = target.substring('vbat://'.length);
    } else if (path.startsWith('/')) {
      path = path.substring(1);
    }

    final List<String> segments = path
        .split('/')
        .where((s) => s.trim().isNotEmpty)
        .toList(growable: false);

    final String name = (segments.isEmpty ? path : segments.first)
        .split('?')
        .first
        .toLowerCase()
        .trim();

    final String id = segments.length > 1
        ? segments[1].split('?').first.trim()
        : (_queryValue(target, 'id') ?? '');

    switch (name) {
      case 'home':
      case 'beranda':
      case 'main':
        _goTab(context, 0);
        return;
      case 'shop':
      case 'toko':
        _goTab(context, 1);
        return;
      case 'belajar':
      case 'learning':
      case 'kursus':
        _goTab(context, 2);
        return;
      case 'forum':
        _goTab(context, 3);
        return;
      case 'akun':
      case 'profil':
      case 'profile':
        _goTab(context, 4);
        return;
      case 'event':
      case 'event-diskon':
      case 'discount-event':
      case 'diskon':
      case 'promo':
        if (context.mounted) context.push('/discount-event');
        return;
      case 'best-deals':
      case 'best-deal':
      case 'bestdeal':
        if (context.mounted) context.push('/best-deals');
        return;
      case 'product':
      case 'produk':
      case 'product-detail':
        await _openProduct(context, id);
        return;
      case 'sponsor':
      case 'mitra':
      case 'sponsor-detail':
        await _openSponsor(context, id);
        return;
    }

    // 3. Tidak dikenali: coba sebagai tautan luar.
    await _openExternal(target);
  }

  /// Pindah ke tab bawah aplikasi.
  static void _goTab(BuildContext context, int index) {
    SessionManager.currentTabIndex.value = index;
    try {
      final String location = GoRouterState.of(context).matchedLocation;
      if (!location.startsWith('/main')) {
        context.go('/main');
      }
    } catch (_) {
      // Bila dipanggil di luar jangkauan router, perubahan tab tetap terpakai.
    }
  }

  /// Buka halaman produk tertentu dengan mengambil datanya dari server.
  static Future<void> _openProduct(BuildContext context, String id) async {
    if (id.isEmpty) return;
    final Map<String, dynamic>? data = await _fetchData('/products/$id');
    if (data == null || !context.mounted) return;

    final Map<String, dynamic>? image = _asMap(data['image']);
    final String sponsorName =
        (_asMap(data['sponsor'])?['name'] ?? '').toString();

    context.push('/product-detail', extra: <String, dynamic>{
      ...data,
      'name': data['name'],
      'price': _rupiah(data['price']),
      'image': _firstNonEmpty([
        data['image'],
        data['image_path'],
        image?['url'],
      ]),
      'link': _firstNonEmpty([
        data['shopee_url'],
        data['tokopedia_url'],
        data['link'],
      ]),
      'sponsor_name': sponsorName,
      'isFromAd': true,
    });
  }

  /// Buka halaman mitra tertentu dengan mengambil datanya dari server.
  static Future<void> _openSponsor(BuildContext context, String id) async {
    if (id.isEmpty) return;
    final Map<String, dynamic>? data = await _fetchData('/sponsors/$id');
    if (data == null || !context.mounted) return;

    final Map<String, dynamic> tierBadge = _asMap(data['tier_badge']) ?? {};
    final Map<String, dynamic> tierInfo =
        _asMap(data['sponsor_tier']) ?? _asMap(data['tier_info']) ?? {};

    context.push('/sponsor-detail', extra: <String, dynamic>{
      ...data,
      'tier_label': tierBadge['label'],
      'tier_color': tierBadge['color'],
      if (tierInfo.isNotEmpty) 'tier_info': tierInfo,
      'isFromAd': true,
    });
  }

  static Future<void> _openExternal(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Tautan tidak dapat dibuka. Tidak ada yang perlu ditampilkan.
    }
  }

  static Future<Map<String, dynamic>?> _fetchData(String path) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
          headers: {'Accept': 'application/json'},
        ),
      );
      final res = await dio.get(path);
      final dynamic body = res.data;
      if (body is Map && body['data'] is Map) {
        return Map<String, dynamic>.from(body['data']);
      }
      if (body is Map) return Map<String, dynamic>.from(body);
    } catch (_) {
      // Gagal mengambil data. Iklan tetap dapat ditutup.
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = (value ?? '').toString();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static String? _queryValue(String url, String key) {
    try {
      final uri = Uri.parse(url.replaceFirst('vbat://', 'https://x/'));
      return uri.queryParameters[key];
    } catch (_) {
      return null;
    }
  }

  /// Ubah angka menjadi teks rupiah, misalnya 1250000 menjadi `Rp1.250.000`.
  static String _rupiah(dynamic value) {
    if (value == null) return '';
    if (value is String && value.trim().isNotEmpty) {
      final parsed = num.tryParse(
        value.replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      if (parsed == null) return value;
      return _rupiah(parsed);
    }
    final num? number = value is num ? value : num.tryParse(value.toString());
    if (number == null) return value.toString();

    final String digits = number.toInt().toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return 'Rp$buffer';
  }
}
