import 'package:flutter/material.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class GamificationBadgesSection extends StatelessWidget {
  final bool? isDark;

  const GamificationBadgesSection({
    super.key,
    this.isDark,
  });

  final List<Map<String, dynamic>> _badges = const [
    {
      'code': 'first_login',
      'name': 'Pertama Masuk',
      'description': 'Langkah awal menuju kehebatan teknisi',
      'icon': Icons.login_rounded,
      'color': Color(0xFF3B82F6),
      'xp': 50,
    },
    {
      'code': 'lesson_complete',
      'name': 'Tamat Materi',
      'description': 'Menyelesaikan modul pelajaran pertama',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF10B981),
      'xp': 100,
    },
    {
      'code': 'quiz_master',
      'name': 'Rajin Kuis',
      'description': 'Lulus 10 kuis dengan nilai sempurna',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF8B5CF6),
      'xp': 150,
    },
    {
      'code': 'streak_7',
      'name': '7 Hari Streak',
      'description': 'Belajar 7 hari berturut-turut',
      'icon': Icons.local_fire_department_rounded,
      'color': Color(0xFFEF4444),
      'xp': 200,
    },
    {
      'code': 'certified',
      'name': 'Teknisi Tersertifikasi',
      'description': 'Mendapatkan sertifikat resmi VBAT',
      'icon': Icons.military_tech_rounded,
      'color': Color(0xFFF59E0B),
      'xp': 300,
    },
  ];

  void _showBadgeDialog(
    BuildContext context,
    Map<String, dynamic> badge,
    bool isUnlocked,
  ) {
    final bool isDark = ThemeManager.isDark(context);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? ThemeManager.darkCard : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? (badge['color'] as Color).withValues(alpha: isDark ? 0.25 : 0.15)
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked
                        ? (badge['color'] as Color)
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  badge['icon'] as IconData,
                  size: 36,
                  color: isUnlocked
                      ? (badge['color'] as Color)
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge['name'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF001944),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge['description'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? ThemeManager.darkTextSecondary : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.blue.withValues(alpha: 0.2)
                          : const Color(0xFF1B4F9B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "+${badge['xp']} XP",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.blue.shade300 : const Color(0xFF1B4F9B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? (isDark ? const Color(0xFF132F20) : const Color(0xFF10B981).withValues(alpha: 0.1))
                          : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                          size: 14,
                          color: isUnlocked
                              ? (isDark ? Colors.green.shade400 : const Color(0xFF10B981))
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isUnlocked ? "Terbuka" : "Terkunci",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isUnlocked
                                ? (isDark ? Colors.green.shade400 : const Color(0xFF10B981))
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF1B4F9B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Tutup"),
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

        // --- Explicit If-Else untuk Styling Berdasarkan Tema (Light vs Dark) ---
        // 1. Streak Tracker Bar
        final Gradient streakGradient;
        final Color streakBorderColor;
        final Color streakTitleColor;
        final Color streakSubtitleColor;
        final Color streakIconBgColor;
        final BoxShadow streakShadow;

        if (effectiveDark) {
          // Mode Gelap: Hangat Deep Mahogany / Amber Dark
          streakGradient = const LinearGradient(
            colors: [
              Color(0xFF241912),
              Color(0xFF1B130E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          streakBorderColor = const Color(0xFF7C2D12);
          streakTitleColor = const Color(0xFFFDBA74);
          streakSubtitleColor = const Color(0xFFFB923C);
          streakIconBgColor = const Color(0xFFEF4444).withValues(alpha: 0.25);
          streakShadow = BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          );
        } else {
          // Mode Terang: Soft Warm Cream Orange (Segar & Bersih)
          streakGradient = const LinearGradient(
            colors: [
              Color(0xFFFFF7ED),
              Color(0xFFFFEDD5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          streakBorderColor = const Color(0xFFFED7AA);
          streakTitleColor = const Color(0xFF9A3412); // Kontras tinggi, mudah dibaca
          streakSubtitleColor = const Color(0xFFC2410C);
          streakIconBgColor = const Color(0xFFEF4444).withValues(alpha: 0.12);
          streakShadow = BoxShadow(
            color: const Color(0xFFF97316).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          );
        }

        // 2. Badges Header & Container
        final Color sectionHeaderColor;
        final Color counterColor;
        final Color badgesCardBg;
        final Border badgesCardBorder;
        final BoxShadow badgesCardShadow;
        final Color lockedBadgeBg;
        final Color lockedBadgeBorder;
        final Color lockedBadgeIcon;
        final Color lockedBadgeText;
        final Color unlockedBadgeText;

        if (effectiveDark) {
          // Mode Gelap
          sectionHeaderColor = ThemeManager.darkTextSecondary;
          counterColor = Colors.blue.shade300;
          badgesCardBg = ThemeManager.darkCard;
          badgesCardBorder = Border.all(color: ThemeManager.darkBorder);
          badgesCardShadow = BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          );
          lockedBadgeBg = Colors.white.withValues(alpha: 0.06);
          lockedBadgeBorder = Colors.grey.shade800;
          lockedBadgeIcon = Colors.grey.shade600;
          lockedBadgeText = Colors.grey.shade500;
          unlockedBadgeText = Colors.white;
        } else {
          // Mode Terang: Putih Bersih
          sectionHeaderColor = const Color(0xFF737782);
          counterColor = const Color(0xFF1B4F9B);
          badgesCardBg = Colors.white;
          badgesCardBorder = Border.all(color: Colors.grey.shade200);
          badgesCardShadow = BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          );
          lockedBadgeBg = Colors.grey.shade100;
          lockedBadgeBorder = Colors.grey.shade300;
          lockedBadgeIcon = Colors.grey.shade400;
          lockedBadgeText = Colors.grey.shade500;
          unlockedBadgeText = const Color(0xFF001944);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Streak Tracker Bar
            ValueListenableBuilder<int>(
              valueListenable: SessionManager.streakDaysNotifier,
              builder: (context, streakDays, _) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: streakGradient,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: streakBorderColor,
                      width: 1.5,
                    ),
                    boxShadow: [streakShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: streakIconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFEF4444),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "$streakDays Hari Berturut-turut!",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: streakTitleColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Belajar tiap hari untuk raih badge Streak Master",
                              style: TextStyle(
                                fontSize: 12,
                                color: streakSubtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // 2. Badges Header
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "LENCANA & PENCAPAIAN",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: sectionHeaderColor,
                    ),
                  ),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: SessionManager.unlockedBadgeCodes,
                    builder: (context, unlocked, _) {
                      return Text(
                        "${unlocked.length}/${_badges.length} Terbuka",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: counterColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 3. Badges List
            ValueListenableBuilder<Set<String>>(
              valueListenable: SessionManager.unlockedBadgeCodes,
              builder: (context, unlocked, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: badgesCardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: badgesCardBorder,
                    boxShadow: [badgesCardShadow],
                  ),
                  child: SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _badges.length,
                      separatorBuilder: (ctx, i) => const SizedBox(width: 14),
                      itemBuilder: (ctx, i) {
                        final badge = _badges[i];
                        final isUnlocked = unlocked.contains(badge['code']);

                        return GestureDetector(
                          onTap: () => _showBadgeDialog(context, badge, isUnlocked),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? (badge['color'] as Color).withValues(alpha: effectiveDark ? 0.25 : 0.12)
                                      : lockedBadgeBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isUnlocked
                                        ? (badge['color'] as Color)
                                        : lockedBadgeBorder,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  badge['icon'] as IconData,
                                  size: 26,
                                  color: isUnlocked
                                      ? (badge['color'] as Color)
                                      : lockedBadgeIcon,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 65,
                                child: Text(
                                  badge['name'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isUnlocked
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isUnlocked
                                        ? unlockedBadgeText
                                        : lockedBadgeText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
