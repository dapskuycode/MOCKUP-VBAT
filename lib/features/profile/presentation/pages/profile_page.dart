import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/features/profile/presentation/widgets/kta_digital_card.dart';
import 'package:vbat_ponsel/features/profile/presentation/widgets/gamification_badges_section.dart';
import 'package:vbat_ponsel/core/widgets/profile_bubble_chat.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);
  final Color _orangeCTA = const Color(0xFFF97316);

  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  bool get _isDark => ThemeManager.isDark(context);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _pageBgColor => _isDark ? ThemeManager.darkBg : _bgLight;
  Color get _itemTextColor => _isDark ? Colors.white : _textDark;
  Color get _itemSubtextColor => _isDark ? ThemeManager.darkTextSecondary : _textGray;
  Color get _itemBorderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: 100,
        ), // Safe area dari BottomNavigationBar
        child: Column(
          children: [
            // --- 1. Header Profile & Avatar ---
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 40, // Ruang ekstra untuk overlap kartu statistik
              ),
              decoration: BoxDecoration(
                color: _isDark ? const Color(0xFF101C2E) : _primaryBlue,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Top Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40), // Spacer
                        Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.centerRight,
                              children: [
                                _buildTopIconButton(
                                  Icons.edit_rounded,
                                  onPressed: () async {
                                    final updated = await context.push<bool>('/edit-profile');
                                    if (!context.mounted) return;
                                    setState(() {});
                                    if (updated == true) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Perubahan berhasil disimpan! (Nama: ${SessionManager.userName})"),
                                          backgroundColor: const Color(0xFF1B4F9B),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                // Bubble chat "lengkapi profile anda" mengarah ke tombol pensil
                                ValueListenableBuilder<bool>(
                                  valueListenable: SessionManager.isProfileCompleteNotifier,
                                  builder: (context, isComplete, _) {
                                    return ValueListenableBuilder<bool>(
                                      valueListenable: SessionManager.isLoggedIn,
                                      builder: (context, isLoggedIn, _) {
                                        if (isLoggedIn && !isComplete) {
                                          return Positioned(
                                            right: 44,
                                            child: ProfileBubbleChat(
                                              onTap: () async {
                                                final updated = await context.push<bool>('/edit-profile');
                                                if (!context.mounted) return;
                                                setState(() {});
                                                if (updated == true) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text("Perubahan berhasil disimpan! (Nama: ${SessionManager.userName})"),
                                                      backgroundColor: const Color(0xFF1B4F9B),
                                                      behavior: SnackBarBehavior.floating,
                                                      duration: const Duration(seconds: 3),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            _buildTopIconButton(
                              Icons.notifications_rounded,
                              onPressed: () => context.push('/notification'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Avatar & User Info
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://i.pravatar.cc/150?img=11',
                            ), // Dummy avatar
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _orangeCTA,
                          shape: BoxShape.circle,
                          border: Border.all(color: _primaryBlue, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: SessionManager.userNameNotifier,
                    builder: (context, name, _) {
                      return Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: SessionManager.userEmailNotifier,
                    builder: (context, email, _) {
                      return Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  ValueListenableBuilder<bool>(
                    valueListenable: SessionManager.isProfileCompleteNotifier,
                    builder: (context, isComplete, _) {
                      final city = SessionManager.city;
                      final age = SessionManager.userAge;
                      final label = isComplete
                          ? "$city • Usia: $age Thn"
                          : (city != null && age != null
                              ? "$city • Usia: $age Thn (Belum Lengkap)"
                              : "⚠️ Profil Belum Lengkap");

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isComplete
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.amber.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: isComplete
                              ? null
                              : Border.all(color: Colors.amber.shade300, width: 1),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isComplete ? Colors.white : Colors.amber.shade100,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // --- 2. Main Content (Overlap) ---
            Transform.translate(
              offset: const Offset(
                0,
                -24,
              ), // Menarik konten naik ke atas header biru
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Stats Bento Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: _isDark ? Border.all(color: _itemBorderColor) : null,
                        boxShadow: [
                          if (!_isDark)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            Icons.play_circle_fill_rounded,
                            "42",
                            "VIDEO",
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: _itemBorderColor,
                          ),
                          _buildStatItem(
                            Icons.workspace_premium_rounded,
                            "5",
                            "CERT",
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: _itemBorderColor,
                          ),
                          _buildStatItem(
                            Icons.trending_up_rounded,
                            "78%",
                            "PROG",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- KTA DIGITAL VBAT PERMANENT CARD ---
                    KtaDigitalCard(isDark: _isDark),

                    // --- GAMIFICATION: STREAK & BADGES ---
                    GamificationBadgesSection(isDark: _isDark),

                    // Menu: PEMBELAJARAN
                    _buildMenuSection("PEMBELAJARAN", [
                      _buildMenuItem(
                        Icons.space_dashboard_outlined,
                        "Dashboard Saya",
                        onTap: () => context.push('/learning-dashboard'),
                      ),
                      _buildMenuItem(
                        Icons.military_tech_outlined,
                        "Sertifikasi",
                        onTap: () => context.push('/certificate'),
                      ),
                      _buildMenuItem(
                        Icons.library_books_outlined,
                        "Riwayat Belajar",
                        showBorder: false,
                        onTap: () => context.push('/learning-history'),
                      ),
                      _buildMenuItem(
                        Icons.favorite_border_rounded,
                        "Wishlist Toko",
                        onTap: () => context.push('/wishlist'),
                      ),
                      _buildMenuItem(
                        Icons.menu_book_rounded,
                        "E-Book & Modul Panduan",
                        showBorder: false,
                        onTap: () => context.push('/ebooks'),
                      ),
                    ]),

                    // Menu: AKUN & LANGGANAN
                    _buildMenuSection("AKUN & LANGGANAN", [
                      _buildMenuItem(
                        Icons.receipt_long_outlined,
                        "Riwayat Transaksi",
                        onTap: () => context.push('/transaction-history'),
                      ),
                      _buildMenuItem(
                        Icons.card_membership_rounded,
                        "Langganan",
                        showBorder: false,
                        onTap: () => context.push('/subscription'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _orangeCTA,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "PRO",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ]),

                    // Menu: PENGATURAN
                    _buildMenuSection("PENGATURAN", [
                      _buildMenuItem(
                        Icons.palette_outlined,
                        "Tema",
                        trailing: _buildThemeToggle(),
                        onTap: () => context.push('/theme-settings'),
                      ),
                      _buildMenuItem(
                        Icons.notifications_active_outlined,
                        "Notifikasi",
                        trailing: Switch.adaptive(
                          value: _isNotificationEnabled,
                          activeThumbColor: _primaryBlue,
                          onChanged: (val) =>
                              setState(() => _isNotificationEnabled = val),
                        ),
                      ),
                      _buildMenuItem(
                        Icons.language_rounded,
                        "Bahasa",
                        showBorder: false,
                        onTap: () => context.push('/language'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "ID",
                              style: TextStyle(
                                color: _textGray,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ]),

                    // Menu: LAINNYA
                    _buildMenuSection("LAINNYA", [
                      _buildMenuItem(
                        Icons.help_outline_rounded,
                        "Bantuan & FAQ",
                        onTap: () => context.push('/help-center'),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: SessionManager.isPremium,
                        builder: (context, isPremium, child) {
                          return _buildMenuItem(
                            isPremium
                                ? Icons.chat_bubble_outline_rounded
                                : Icons.lock_outline_rounded,
                            "Dukungan Bantuan (WhatsApp)",
                            trailing: isPremium
                                ? Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey.shade400,
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "PREMIUM",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            onTap: () async {
                              if (!isPremium) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Fitur Dukungan Bantuan Khusus Pengguna Langganan/Premium',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final Uri waUri = Uri.parse(
                                'https://wa.me/62811268717',
                              );
                              if (!await launchUrl(
                                waUri,
                                mode: LaunchMode.externalApplication,
                              )) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal membuka WhatsApp'),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                      _buildMenuItem(
                        Icons.explore_outlined,
                        "Tour Aplikasi (Onboarding)",
                        onTap: () => context.push('/onboarding'),
                      ),
                      _buildMenuItem(
                        Icons.info_outline_rounded,
                        "Tentang VBat Ponsel",
                        showBorder: false,
                        onTap: () => context.push('/about'),
                      ),
                    ]),

                    // Logout Button
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () async {
                        await SessionManager.logout();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Berhasil keluar dari akun."),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        "Keluar dari Akun",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTopIconButton(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryBlue.withValues(alpha: _isDark ? 0.25 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: _itemSubtextColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _itemSubtextColor,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              border: _isDark ? Border.all(color: _itemBorderColor) : null,
              boxShadow: [
                if (!_isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                  ),
              ],
            ),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    Widget? trailing,
    bool showBorder = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(bottom: BorderSide(color: _itemBorderColor))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _isDark ? Colors.grey.shade400 : _textGray,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: _itemTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: _isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
          ],
        ),
      ),
    );
  }

  // Sakelar Interaktif Tema (Light / Dark / System)
  Widget _buildThemeToggle() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeModeNotifier,
      builder: (context, currentMode, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF151B26) : _bgLight,
            borderRadius: BorderRadius.circular(8),
            border: _isDark ? Border.all(color: _itemBorderColor) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeBtn(
                icon: Icons.light_mode_rounded,
                isSelected: currentMode == ThemeMode.light,
                onTap: () => ThemeManager.setTheme(ThemeMode.light),
              ),
              _buildThemeBtn(
                icon: Icons.dark_mode_rounded,
                isSelected: currentMode == ThemeMode.dark,
                onTap: () => ThemeManager.setTheme(ThemeMode.dark),
              ),
              _buildThemeBtn(
                icon: Icons.settings_suggest_rounded,
                isSelected: currentMode == ThemeMode.system,
                onTap: () => ThemeManager.setTheme(ThemeMode.system),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeBtn({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? (_isDark ? const Color(0xFF243042) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected && !_isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? (_isDark ? const Color(0xFF60A5FA) : _primaryBlue)
              : (_isDark ? Colors.grey.shade500 : _textGray),
          size: 16,
        ),
      ),
    );
  }
}
