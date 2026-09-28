import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class KtaDigitalCard extends StatelessWidget {
  final VoidCallback? onUpgradePressed;
  final bool? isDark;

  const KtaDigitalCard({
    super.key,
    this.onUpgradePressed,
    this.isDark,
  });

  void _showQrDialog(BuildContext context, String memberId, String memberName) {
    final bool isDark = ThemeManager.isDark(context);
    final verificationUrl = 'https://vbat.id/membership/verify/$memberId';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? ThemeManager.darkCard : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B4F9B).withValues(alpha: isDark ? 0.25 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          color: isDark ? Colors.blue.shade300 : const Color(0xFF1B4F9B),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Verifikasi KTA Publik",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF001944),
                            ),
                          ),
                          Text(
                            "Scan untuk validasi keaslian",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? ThemeManager.darkTextSecondary : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: verificationUrl,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0A192F),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1B4F9B),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                memberId,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFF001944),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                memberName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 4),
                    Text(
                      "STATUS: AKTIF SEUMUR HIDUP",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: verificationUrl));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Link verifikasi publik berhasil disalin!"),
                        backgroundColor: Color(0xFF1B4F9B),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text("Salin Link Verifikasi"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1B4F9B),
                    side: const BorderSide(color: Color(0xFF1B4F9B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeModeNotifier,
      builder: (context, currentThemeMode, _) {
        final bool effectiveDark = isDark ?? ThemeManager.isDark(context);

        return ValueListenableBuilder<Set<String>>(
          valueListenable: SessionManager.activeEntitlements,
          builder: (context, entitlements, _) {
            final bool isPermanent = SessionManager.hasPermanentMembership;
            final String memberId = SessionManager.membershipNumber;
            final String memberName = SessionManager.userName;

            // --- Explicit If-Else untuk Styling Tema (Light vs Dark) ---
            final Gradient cardGradient;
            final Border? cardBorder;
            final Color textColorPrimary;
            final Color textColorSecondary;
            final Color contactlessIconColor;
            final Color watermarkColor;
            final double watermarkOpacity;
            final List<Shadow>? idShadow;
            final BoxShadow cardShadow;

            if (isPermanent) {
              // --- KTA AKTIF (VIP PERMANENT) ---
              if (effectiveDark) {
                // Dark Mode: Deep Midnight Navy Blue VIP
                cardGradient = const LinearGradient(
                  colors: [
                    Color(0xFF0F172A), // Slate 900
                    Color(0xFF1E3A8A), // Blue 900
                    Color(0xFF1B4F9B), // VBAT Primary
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                );
                cardBorder = Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  width: 1.2,
                );
                textColorPrimary = Colors.white;
                textColorSecondary = Colors.white.withValues(alpha: 0.7);
                contactlessIconColor = Colors.white70;
                watermarkColor = Colors.white;
                watermarkOpacity = 0.08;
                idShadow = const [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ];
                cardShadow = BoxShadow(
                  color: const Color(0xFF0A192F).withValues(alpha: 0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                );
              } else {
                // Light Mode: Vibrant Official VBAT Blue VIP
                cardGradient = const LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E3A8A),
                    Color(0xFF1B4F9B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                );
                cardBorder = null;
                textColorPrimary = Colors.white;
                textColorSecondary = Colors.white.withValues(alpha: 0.75);
                contactlessIconColor = Colors.white70;
                watermarkColor = Colors.white;
                watermarkOpacity = 0.08;
                idShadow = const [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ];
                cardShadow = BoxShadow(
                  color: const Color(0xFF0A192F).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                );
              }
            } else {
              // --- KTA BELUM AKTIF ---
              if (effectiveDark) {
                // Dark Mode: Charcoal Dark Slate
                cardGradient = const LinearGradient(
                  colors: [
                    Color(0xFF1F2937),
                    Color(0xFF111827),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                );
                cardBorder = Border.all(
                  color: const Color(0xFF374151),
                  width: 1.2,
                );
                textColorPrimary = Colors.white;
                textColorSecondary = Colors.white.withValues(alpha: 0.65);
                contactlessIconColor = Colors.white70;
                watermarkColor = Colors.white;
                watermarkOpacity = 0.08;
                idShadow = const [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ];
                cardShadow = BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                );
              } else {
                // Light Mode: Sleek Platinum / Silver White Card
                cardGradient = const LinearGradient(
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFE2E8F0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                );
                cardBorder = Border.all(
                  color: const Color(0xFFCBD5E1),
                  width: 1.5,
                );
                textColorPrimary = const Color(0xFF0F172A); // Teks gelap kontras tinggi
                textColorSecondary = const Color(0xFF64748B);
                contactlessIconColor = const Color(0xFF64748B);
                watermarkColor = const Color(0xFF0F172A);
                watermarkOpacity = 0.04;
                idShadow = null;
                cardShadow = BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                );
              }
            }

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [cardShadow],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    // Background Card Gradient & Border
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: cardGradient,
                        border: cardBorder,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card: Chip + VBAT Logo / Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // Holographic EMV Chip
                                  Container(
                                    width: 36,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD700),
                                          Color(0xFFFFA500),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.amber.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 10,
                                          top: 0,
                                          bottom: 0,
                                          width: 1,
                                          child: Container(color: Colors.amber.shade800),
                                        ),
                                        Positioned(
                                          right: 10,
                                          top: 0,
                                          bottom: 0,
                                          width: 1,
                                          child: Container(color: Colors.amber.shade800),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.contactless_rounded,
                                    color: contactlessIconColor,
                                    size: 22,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPermanent
                                      ? const Color(0xFF10B981)
                                      : Colors.orange.shade700,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPermanent
                                          ? Icons.verified_user_rounded
                                          : Icons.lock_clock_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isPermanent ? "PERMANENT ID" : "BELUM AKTIF",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // Member ID Number
                          Text(
                            isPermanent ? memberId : "VBAT-XXXX-XXXX",
                            style: TextStyle(
                              color: textColorPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.5,
                              shadows: idShadow,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Footer Card: Name & Action / QR Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "MEMBER RESMI VBAT ACADEMY",
                                    style: TextStyle(
                                      color: textColorSecondary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    memberName.toUpperCase(),
                                    style: TextStyle(
                                      color: textColorPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              if (isPermanent)
                                GestureDetector(
                                  onTap: () => _showQrDialog(context, memberId, memberName),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.qr_code_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "QR KTA",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ElevatedButton(
                                  onPressed: onUpgradePressed ?? () => context.push('/pricelist'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF97316),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Aktifkan KTA",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Holographic watermark decoration
                    Positioned(
                      right: -25,
                      bottom: -25,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: watermarkOpacity,
                          child: Icon(
                            Icons.military_tech_rounded,
                            size: 160,
                            color: watermarkColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
