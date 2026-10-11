import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Sumber ikon tier dari server.
///
/// Server mengirim `icon_url` dan `badge_color` pada endpoint
/// `/api/v1/sponsors/tiers`. Admin dapat mengganti ikon kapan saja tanpa
/// memperbarui aplikasi.
class TierIconSource {
  /// URL gambar/SVG ikon di server. Null berarti pakai ikon bawaan.
  final String? url;

  /// Warna tier dari server (`badge_color`, format `#RRGGBB`).
  final Color? color;

  /// Isi berkas SVG ikon yang sudah diunduh dari server. Dipakai supaya ikon
  /// tidak perlu diunduh berulang kali, dan supaya kegagalan unduh dapat
  /// ditangani tanpa menghentikan tampilan.
  final String? svgText;

  const TierIconSource({this.url, this.color, this.svgText});

  /// Salinan dengan isi SVG diisi.
  TierIconSource withSvgText(String text) {
    return TierIconSource(url: url, color: color, svgText: text);
  }

  /// Bentuk dari data server. Menerima `badge_color` sebagai `Color` atau
  /// `String` hex, dan `icon_url` sebagai `String`.
  factory TierIconSource.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TierIconSource();

    final rawColor = json['badge_color'] ?? json['tier_color'];
    return TierIconSource(
      url: (json['icon_url'] ?? json['tier_icon'] ?? '').toString().isEmpty
          ? null
          : (json['icon_url'] ?? json['tier_icon']).toString(),
      color: rawColor is Color
          ? rawColor
          : (rawColor is String ? tierColorFromHex(rawColor) : null),
    );
  }

  /// Bentuk data dari API sponsor: field-nya berada di dalam objek `tier`.
  factory TierIconSource.fromSponsorJson(Map<String, dynamic>? json) {
    if (json == null) return const TierIconSource();
    final nested = json['tier_info'] ?? json['sponsor_tier'] ?? json['tier'];
    final Map<String, dynamic>? tierJson =
        nested is Map ? Map<String, dynamic>.from(nested) : null;
    return TierIconSource(
      url: (tierJson?['icon_url'] ?? json['tier_icon_url'])?.toString(),
      color: _colorFrom(tierJson?['badge_color'] ??
          tierJson?['color'] ??
          json['tier_color']),
    );
  }

  static Color? _colorFrom(dynamic raw) {
    if (raw is Color) return raw;
    if (raw is String) return tierColorFromHex(raw);
    return null;
  }

  bool get isEmpty => url == null && color == null;
}

/// Ubah teks warna dari server (`#RRGGBB`, `RRGGBB`, atau `#AARRGGBB`) menjadi
/// [Color]. Mengembalikan null bila tidak dikenal.
Color? tierColorFromHex(String? raw) {
  if (raw == null) return null;
  String hex = raw.trim().replaceAll('#', '');
  if (hex.isEmpty) return null;
  if (hex.length == 3) {
    hex = hex.split('').map((c) => '$c$c').join();
  }
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final value = int.tryParse(hex, radix: 16);
  return value == null ? null : Color(value);
}

/// Badge tier sponsor.
///
/// Desain mengikuti usulan PO: kotak ikon berwarna di kiri, label gelap
/// menempel di kanan dengan sudut luar membulat. Bentuk ini sama dengan badge
/// resmi pada aplikasi marketplace sehingga langsung dikenali pengguna.
///
/// Ikon diambil dari server lebih dahulu ([TierIconSource.url]). Bila server
/// belum mengirim ikon, ikon bawaan Flutter yang dipakai. Ikon dari server
/// dirender sebagai SVG bila berekstensi `.svg`, selain itu sebagai gambar
/// biasa.
class SponsorTierBadge extends StatelessWidget {
  final String rawTier;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  /// Warna dari server (`badge_color`).
  final Color? tierColor;

  /// Nama tier dari server. Dipakai saat `rawTier` berisi label mentah.
  final String? tierLabelOverride;

  /// Sumber ikon dari server (URL ikon dan warna).
  final TierIconSource? iconSource;

  /// Berkas ikon bawaan di dalam aplikasi, dipakai bila Admin belum
  /// mengunggah ikon sendiri.
  static const Map<String, String> _assetIcons = {
    'free': 'assets/icons/tiers/tier_free.svg',
    'kontribusi': 'assets/icons/tiers/tier_kontribusi.svg',
    'bronze': 'assets/icons/tiers/tier_bronze.svg',
    'silver': 'assets/icons/tiers/tier_silver.svg',
    'gold': 'assets/icons/tiers/tier_gold.svg',
    'platinum': 'assets/icons/tiers/tier_platinum.svg',
    'diamond': 'assets/icons/tiers/tier_diamond.svg',
  };

  /// Berkas ikon bawaan untuk sebuah tier. Null bila tidak tersedia.
  static String? assetIconFor(String tierName) {
    return _assetIcons[tierName.toLowerCase()];
  }

  /// Dipertahankan supaya kode lama yang masih mengirim `isSolid: true`
  /// tetap dapat dikompilasi. Tampilan badge sekarang selalu padat, jadi
  /// nilainya tidak lagi mengubah bentuk.
  final bool isSolid;

  const SponsorTierBadge({
    super.key,
    required this.rawTier,
    this.fontSize = 9.0,
    this.iconSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.tierColor,
    this.tierLabelOverride,
    this.iconSource,
    this.isSolid = false,
  });

  /// Standardisasi nama tier ringkas (APP-02):
  /// Mengubah "Sponsor Platinum" -> "Platinum", "SPONSOR GOLD" -> "Gold", dsb.
  static String cleanTierName(String raw) {
    String clean = raw
        .replaceAll(RegExp(r'sponsor\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'•\s*', caseSensitive: false), '')
        .trim();

    if (clean.isEmpty) return 'Partner';

    final lower = clean.toLowerCase();
    if (lower == 'diamond') return 'Diamond';
    if (lower == 'platinum') return 'Platinum';
    if (lower == 'gold') return 'Gold';
    if (lower == 'silver') return 'Silver';
    if (lower == 'bronze') return 'Bronze';
    if (lower == 'kontribusi') return 'Kontribusi';
    if (lower == 'free') return 'Free';
    return clean[0].toUpperCase() + clean.substring(1).toLowerCase();
  }

  /// Warna cadangan bila server tidak mengirim `badge_color`.
  ///
  /// Susunan warna ini sama dengan rancangan ikon tier dari PO supaya badge di
  /// aplikasi dan berkas ikon tidak berbeda warna.
  static Color getFallbackColor(String tierName) {
    final lower = tierName.toLowerCase();
    switch (lower) {
      case 'diamond':
        return const Color(0xFF00B8D9);
      case 'platinum':
        return const Color(0xFF7C5CE0);
      case 'gold':
        return const Color(0xFFE0A81B);
      case 'silver':
        return const Color(0xFF8A97A8);
      case 'bronze':
        return const Color(0xFFC2814A);
      case 'kontribusi':
        return const Color(0xFF5B8FA8);
      case 'free':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFF1B4F9B);
    }
  }

  /// Warna yang dipakai: server bila ada, cadangan bila tidak.
  static Color getTierColor(String tierName, {Color? fromServer}) {
    return fromServer ?? getFallbackColor(tierName);
  }

  /// Ikon cadangan bila server tidak mengirim ikon.
  static IconData getFallbackIcon(String tierName) {
    final lower = tierName.toLowerCase();
    switch (lower) {
      case 'diamond':
        return Icons.diamond_rounded;
      case 'platinum':
        return Icons.workspace_premium_rounded;
      case 'gold':
        return Icons.military_tech_rounded;
      case 'silver':
        return Icons.shield_rounded;
      case 'bronze':
        return Icons.verified_rounded;
      case 'kontribusi':
        return Icons.handshake_rounded;
      case 'free':
        return Icons.person_outline_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String tierName = tierLabelOverride ?? cleanTierName(rawTier);
    final Color color = getTierColor(
      tierName,
      fromServer: tierColor ?? iconSource?.color,
    );

    // Ukuran kotak ikon dan label dihitung dari `iconSize`/`fontSize` supaya
    // proporsinya tetap sama di semua tempat pemakaian.
    final double boxSize = (iconSize * 2.5).clamp(18.0, 40.0);
    final double glyphSize = (iconSize * 1.55).clamp(11.0, 26.0);
    final double radius = (boxSize * 0.26).clamp(4.0, 11.0);
    final EdgeInsets labelPad = EdgeInsets.symmetric(
      horizontal: (padding.horizontal / 2 + 8).clamp(7.0, 16.0),
      vertical: (padding.vertical / 2 + 3).clamp(3.0, 8.0),
    );

    final Widget glyph = _buildGlyph(
      tierName: tierName,
      size: glyphSize,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: glyph,
        ),
        Transform.translate(
          offset: Offset(-boxSize * 0.16, 0),
          child: Container(
            padding: labelPad,
            decoration: BoxDecoration(
              color: const Color(0xFF15161A),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(radius + 1),
                bottomRight: Radius.circular(radius + 1),
              ),
            ),
            child: Text(
              tierName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: fontSize,
                letterSpacing: -0.2,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Ikon dari server bila ada, ikon bawaan bila tidak.
Widget _buildGlyph({required String tierName, required double size}) {
    final String? svgText = iconSource?.svgText;
    if (svgText != null && svgText.trim().isNotEmpty) {
      return SvgPicture.string(
        svgText,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        placeholderBuilder: (_) => _fallbackIcon(tierName, size),
      );
    }

    final String url = (iconSource?.url ?? '').trim();
    if (url.isEmpty) return _fallbackIcon(tierName, size);

    // Ikon dari server berbentuk gambar biasa. Bila gagal dimuat, ikon
    // bawaan aplikasi yang dipakai sehingga badge tidak pernah rusak.
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          _fallbackIcon(tierName, size),
    );
  }

  /// Ikon bawaan: berkas SVG di dalam aplikasi bila tersedia, selain itu
  /// ikon bawaan Flutter.
  Widget _fallbackIcon(String tierName, double size) {
    final asset = SponsorTierBadge.assetIconFor(tierName);

    if (asset != null) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    }

    return Icon(
      SponsorTierBadge.getFallbackIcon(tierName),
      size: size,
      color: Colors.white,
    );
  }
}
