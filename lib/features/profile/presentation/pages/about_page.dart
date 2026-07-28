import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _primaryBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Tentang VBat Ponsel",
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.phone_android_rounded,
                color: _primaryBlue,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "VBat Ponsel",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Versi 1.0.0 (Build 100)",
              style: TextStyle(
                fontSize: 14,
                color: _textGray,
              ),
            ),
            const SizedBox(height: 48),

            // Links Menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildLinkItem(
                    context,
                    title: "Syarat dan Ketentuan",
                    icon: Icons.description_outlined,
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _buildLinkItem(
                    context,
                    title: "Kebijakan Privasi",
                    icon: Icons.privacy_tip_outlined,
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _buildLinkItem(
                    context,
                    title: "Lisensi Perangkat Lunak",
                    icon: Icons.gavel_rounded,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            Text(
              "© 2024 VBat Ponsel Nusantara.\nHak Cipta Dilindungi Undang-Undang.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, {required String title, required IconData icon}) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Membuka halaman $title")),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: _textGray, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
