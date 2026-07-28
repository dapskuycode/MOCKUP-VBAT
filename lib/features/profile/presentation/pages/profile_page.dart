import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
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
                color: _primaryBlue,
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
                            _buildTopIconButton(
                              Icons.edit_rounded,
                              onPressed: () => context.push('/edit-profile'),
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
                  const Text(
                    "Budi Teknisi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "budi@vbatponsel.com",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
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
                            color: Colors.grey.shade200,
                          ),
                          _buildStatItem(
                            Icons.workspace_premium_rounded,
                            "5",
                            "CERT",
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade200,
                          ),
                          _buildStatItem(
                            Icons.trending_up_rounded,
                            "78%",
                            "PROG",
                          ),
                        ],
                      ),
                    ),


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
                        "Wishlist",
                        showBorder: false,
                        onTap: () => context.push('/wishlist'),
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
                        trailing: _buildThemeToggleMock(),
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
                      onPressed: () {
                        SessionManager.logout();
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
            color: _primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _primaryBlue, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _primaryBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: _textGray,
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
                color: _textGray,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
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
              ? Border(bottom: BorderSide(color: Colors.grey.shade100))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: _textGray, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: _textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // Segmented control tiruan untuk sakelar Tema (Light/Dark/System)
  Widget _buildThemeToggleMock() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _bgLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.light_mode_rounded,
              color: _primaryBlue,
              size: 16,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(Icons.dark_mode_outlined, color: _textGray, size: 16),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              Icons.settings_suggest_outlined,
              color: _textGray,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
