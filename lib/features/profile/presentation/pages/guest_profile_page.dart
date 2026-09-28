import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class GuestProfilePage extends StatelessWidget {
  const GuestProfilePage({super.key});

  final Color _vbatBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF0D2B5E);
  final Color _textGray = const Color(0xFF434751);
  final Color _greenSuccess = const Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    if (!SessionManager.isLoggedIn.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!SessionManager.isLoggedIn.value && context.mounted) {
          context.push('/login');
        }
      });
    }

    final bool isDark = ThemeManager.isDark(context);
    final Color cardColor = isDark ? ThemeManager.darkCard : Colors.white;
    final Color textColor = isDark ? Colors.white : _textDark;
    final Color textGrayColor = isDark ? ThemeManager.darkTextSecondary : _textGray;

    return Scaffold(
      backgroundColor: isDark ? ThemeManager.darkBg : _bgLight,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        // Padding bottom agar tidak tertutup BottomNavigationBar dari MainScaffold
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // --- 1. Bagian Atas (Header & Call to Action) ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _vbatBlue,
                // Memberikan lengkungan sedikit di bawah agar estetik
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                bottom: 32,
                left: 24,
                right: 24,
              ),
              child: Column(
                children: [
                  // Logo / Judul
                  Image.asset(
                    'assets/images/vbat_logo_shadow.png',
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      "VBat Ponsel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Masuk untuk pengalaman lebih baik",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Avatar Tamu
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Tamu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Belum masuk ke akun",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- 2. Tombol Aksi (Auth) ---
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _vbatBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.push('/register'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Daftar Gratis",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 3. Kartu Benefit ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: ThemeManager.darkBorder) : null,
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kenapa harus daftar?",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem("Akses video gratis tanpa batas", textGrayColor),
                    _buildBenefitItem("Bergabung komunitas teknisi", textGrayColor),
                    _buildBenefitItem("Sertifikat digital resmi", textGrayColor),
                    _buildBenefitItem("Harga member spesial sparepart", textGrayColor),
                  ],
                ),
              ),
            ),

            // --- 4. Tombol Jelajah (Guest Browse) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    "Atau jelajahi tanpa login:",
                    style: TextStyle(fontSize: 14, color: textGrayColor),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildBrowseChip(
                        "Lihat Produk",
                        Icons.shopping_bag_outlined,
                        () {
                          SessionManager.currentTabIndex.value = 1;
                        },
                        isDark,
                      ),
                      _buildBrowseChip(
                        "Cari Brand",
                        Icons.branding_watermark_outlined,
                        () {
                          SessionManager.currentTabIndex.value = 3;
                        },
                        isDark,
                      ),
                      _buildBrowseChip(
                        "Lihat Kursus",
                        Icons.school_outlined,
                        () {
                          SessionManager.currentTabIndex.value = 3;
                        },
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildBenefitItem(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: _greenSuccess, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseChip(String label, IconData icon, VoidCallback onTap, bool isDark) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? const Color(0xFF60A5FA) : _vbatBlue,
        side: BorderSide(color: (isDark ? const Color(0xFF60A5FA) : _vbatBlue).withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
