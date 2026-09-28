import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';

class ForumDetailPage extends StatefulWidget {
  final Map<String, dynamic>? data;

  const ForumDetailPage({super.key, this.data});

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textContent => _isDark ? ThemeManager.darkText : Colors.black87;
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

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

  @override
  Widget build(BuildContext context) {
    // Fallback data jika null (terjadi jika state extra GoRouter hilang akibat Hot Reload)
    final infoData =
        widget.data ??
        {
          "category": "Ruang Konsultasi",
          "title": "Jadwal Konsultasi Tanya Jawab Kasus Bersama Instruktur",
          "content":
              "Halo Sobat Teknisi,\n\nMengingatkan kembali bahwa sesi konsultasi teknikal minggu ini akan diadakan secara live (via Zoom/Grup) pada hari Jumat pukul 19.30 WIB.\n\nSilakan siapkan pertanyaan mengenai studi kasus perbaikan (troubleshooting) HP, analisa skema jalur, maupun kendala-kendala software dan hardware yang belum terselesaikan di tempat servis masing-masing.\n\nHarap mencatat detail kasus (Tipe HP, Kronologi kerusakaan, dan hasil pengecekan tegangan) agar pembahasan bisa langsung tepat sasaran.\n\nTerima kasih dan salam solder!",
          "date": "1 Jam yang lalu",
          "imageUrl":
              "https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        };

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _textDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Detail Informasi",
          style: TextStyle(
            color: _textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _borderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (infoData['imageUrl'] != null)
              Image.network(
                infoData['imageUrl'],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isDark ? _primaryBlue.withValues(alpha: 0.25) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      infoData['category'],
                      style: TextStyle(
                        color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    infoData['title'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: _textGray,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        infoData['date'],
                        style: TextStyle(
                          fontSize: 13,
                          color: _textGray,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 48, thickness: 1, color: _borderColor),
                  Text(
                    infoData['content'],
                    style: TextStyle(
                      fontSize: 16,
                      color: _textContent,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
