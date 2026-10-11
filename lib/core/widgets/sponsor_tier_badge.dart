import 'package:flutter/material.dart';

/// Badge tier sponsor.
///
/// Warna dan ikon di sini adalah nilai CADANGAN yang dipakai saat server tidak
/// mengirim data tier. Sumber utama tetap server: field `badge_color` dan
/// `icon_url` pada endpoint /api/v1/sponsors/tiers.
///
/// Untuk memakai warna/ikon dari server, kirim `tierColor` dan `tierIconCode`
/// ke konstruktor. Bila kosong, nilai cadangan di bawah yang dipakai.
class SponsorTierBadge extends StatelessWidget {
  final String rawTier;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final bool isSolid;

  /// Warna dari server (field `badge_color`). Null berarti pakai cadangan.
  final Color? tierColor;

  /// Nama tier dari server. Dipakai saat `rawTier` berisi label mentah.
  final String? tierLabelOverride;

  const SponsorTierBadge({
    super.key,
    required this.rawTier,
    this.fontSize = 9.0,
    this.iconSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.isSolid = false,
    this.tierColor,
    this.tierLabelOverride,
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
  static Color getFallbackColor(String tierName) {
    final lower = tierName.toLowerCase();
    switch (lower) {
      case 'diamond':
        return const Color(0xFF0096C7);
      case 'platinum':
        return const Color(0xFF6C5CE7);
      case 'gold':
        return const Color(0xFFE65100);
      case 'silver':
        return const Color(0xFF5A6B82);
      case 'bronze':
        return const Color(0xFF8D6E63);
      case 'kontribusi':
        return const Color(0xFF0284C7);
      case 'free':
        return const Color(0xFF64748B);
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
    final String tierName =
        tierLabelOverride ?? cleanTierName(rawTier);
    final Color color = getTierColor(tierName, fromServer: tierColor);
    final IconData icon = getFallbackIcon(tierName);

    if (isSolid) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: Colors.white),
            const SizedBox(width: 3.5),
            Text(
              tierName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: fontSize,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 3.5),
          Text(
            tierName,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
