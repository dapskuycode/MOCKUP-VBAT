import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardBg => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _cardBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _isDark ? Colors.blue.shade300 : _primaryBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Pusat Bantuan",
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header & Search ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isDark ? const Color(0xFF132A4A) : _primaryBlue,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hai, Budi!\nAda yang bisa kami bantu?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: TextStyle(color: _textDark, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Cari topik bantuan...",
                        hintStyle: TextStyle(
                          color: _textGray,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _textGray,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Contact Options ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildContactCard(
                      context,
                      icon: Icons.chat_rounded,
                      title: "Chat Pak Tomi",
                      subtitle: "(Premium Only)",
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildContactCard(
                      context,
                      icon: Icons.email_rounded,
                      title: "Email Bantuan",
                      subtitle: "Kirim pesan umum",
                      color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- FAQ Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanya Jawab Populer (FAQ)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildFAQItem(
                          "Bagaimana cara klaim garansi baterai/LCD?",
                          "Untuk klaim garansi, pastikan segel distributor tidak rusak. Sertakan video unboxing dan tes nyala produk (khusus LCD) lalu kirimkan ke tim retur VBat melalui WhatsApp atau fitur retur pada detail pesanan.",
                        ),
                        Divider(height: 1, color: _borderColor),
                        _buildFAQItem(
                          "Apakah saya bisa mengakses video materi selamanya?",
                          "Ya, bagi Anda yang membeli Kelas Premium Teknisi (Online maupun Offline), akses video materi di aplikasi VBat Ponsel berlaku seumur hidup (lifetime).",
                        ),
                        Divider(height: 1, color: _borderColor),
                        _buildFAQItem(
                          "Metode pembayaran apa saja yang tersedia?",
                          "Kami mendukung pembayaran via Transfer Bank (BCA, Mandiri, BRI, BNI), E-Wallet (Gopay, OVO, Dana), dan QRIS.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menghubungi: $title")));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: _isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: _textGray)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Theme(
      data: ThemeData().copyWith(
        dividerColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _textDark,
          ),
        ),
        iconColor: _isDark ? Colors.blue.shade300 : _primaryBlue,
        collapsedIconColor: _textGray,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(
            answer,
            style: TextStyle(fontSize: 13, color: _textGray, height: 1.5),
          ),
        ],
      ),
    );
  }
}
