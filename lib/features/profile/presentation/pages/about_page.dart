import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import '../../../../core/config/app_config.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final Color _primaryBlue = const Color(0xFF1B4F9B);

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark(context);
    final bgColor = isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
    final cardBg = isDark ? ThemeManager.darkCard : Colors.white;
    final textColor = isDark ? ThemeManager.darkText : const Color(0xFF001944);
    final textSub = isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
    final borderColor = isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Tentang VBat Ponsel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151B26) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.phone_android_rounded,
                color: _primaryBlue,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppConfig.appName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Versi ${AppConfig.appVersion} (Build ${AppConfig.buildNumber})",
              style: TextStyle(fontSize: 13, color: textSub),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Environment: ${AppConfig.buildEnvironment.toUpperCase()}",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Profile Perusahaan Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.corporate_fare_rounded, color: _primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Profil Perusahaan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "PT Quantum Telematika Nusantara",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Pelopor platform edukasi teknisi ponsel dan telekomunikasi terintegrasi di Indonesia. VBat Ponsel menghadirkan kurikulum berbasis video, dokumen panduan teknis, dan sertifikasi keahlian terstandarisasi industri.",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: textSub,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Links Menu
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildLinkItem(
                    context,
                    title: "Syarat dan Ketentuan",
                    icon: Icons.description_outlined,
                    onTap: () => _showTermsDialog(context),
                  ),
                  Divider(height: 1, color: borderColor),
                  _buildLinkItem(
                    context,
                    title: "Kebijakan Privasi",
                    icon: Icons.privacy_tip_outlined,
                    onTap: () => _showPrivacyDialog(context),
                  ),
                  Divider(height: 1, color: borderColor),
                  _buildLinkItem(
                    context,
                    title: "Lisensi Perangkat Lunak",
                    icon: Icons.gavel_rounded,
                    onTap: () => _showLicenseDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),
            Text(
              "© 2026 PT Quantum Telematika Nusantara.\nHak Cipta Dilindungi Undang-Undang.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF001944);
    final textSub = isDark ? Colors.grey.shade400 : const Color(0xFF737782);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: textSub, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textSub, size: 20),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (sheetCtx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Syarat & Ketentuan Layanan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "1. Hak Akses & Akun\n"
                    "Akun VBat Ponsel bersifat personal dan tidak dapat dipindahtangankan. Pengguna bertanggung jawab penuh atas kerahasiaan kata sandi dan aktivitas yang dilakukan melalui akun tersebut.\n\n"
                    "2. Hak Cipta & Materi Pelatihan\n"
                    "Seluruh konten video, dokumen skematik, e-book, dan bahan ajar dilindungi oleh hak cipta PT Quantum Telematika Nusantara. Pengguna dilarang keras merekam, menyebarluaskan, atau mengomersialkan materi tanpa izin tertulis.\n\n"
                    "3. Skema Langganan & Akses Kursus\n"
                    "Akses materi premium (Tier Basic, Pro, Master) berlaku sesuai masa aktif paket berlangganan yang telah diselesaikan pembayarannya.",
                    style: TextStyle(fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (sheetCtx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Kebijakan Privasi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "PT Quantum Telematika Nusantara berkomitmen melindungi privasi data pribadi Anda:\n\n"
                    "1. Pengumpulan Data\n"
                    "Kami mengumpulkan data nama, alamat email, nomor telepon, dan riwayat pelatihan untuk keperluan sertifikasi keahlian serta personalisasi kurikulum.\n\n"
                    "2. Keamanan Data & Penyimpanan\n"
                    "Token autentikasi dan data kredensial disimpan menggunakan penyimpanan terenkripsi pada perangkat Anda (Keystore / Keyring).\n\n"
                    "3. Perlindungan Rekaman Layar\n"
                    "Aplikasi dilengkapi proteksi keamanan native (FLAG_SECURE) guna mencegah pengambilan screenshot atau perekaman layar saat memutar konten materi berhak cipta.",
                    style: TextStyle(fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLicenseDialog(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: "v${AppConfig.appVersion}",
      applicationLegalese: "© 2026 PT Quantum Telematika Nusantara",
    );
  }
}

