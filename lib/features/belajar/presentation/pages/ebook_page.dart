import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class EbookItem {
  final String id;
  final String title;
  final String author;
  final String pages;
  final String courseType; // 'free_class', 'android', 'iphone'
  final String pdfUrl;
  final String description;
  final IconData icon;
  final Color themeColor;

  const EbookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.pages,
    required this.courseType,
    required this.pdfUrl,
    required this.description,
    required this.icon,
    required this.themeColor,
  });
}

class EbookPage extends StatefulWidget {
  const EbookPage({super.key});

  @override
  State<EbookPage> createState() => _EbookPageState();
}

class _EbookPageState extends State<EbookPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF0D2B5E);
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

  final List<EbookItem> _ebooks = const [
    EbookItem(
      id: 'ebook-free-1',
      title: 'Dasar Mikrosolder & Standar Lab Ponsel',
      author: 'Tim Ahli VBAT Indonesia',
      pages: '48 Halaman',
      courseType: 'free_class',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'Panduan pengenalan alat ukur multimeter, stasiun solder T12, mikroskop trinokuler, dan SOP penanganan ESD.',
      icon: Icons.menu_book_rounded,
      themeColor: Color(0xFF1B4F9B),
    ),
    EbookItem(
      id: 'ebook-android-1',
      title: 'Skematik Jalur Daya & Troubleshooting Android',
      author: 'Master Trainer Android VBAT',
      pages: '124 Halaman',
      courseType: 'android',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'Analisis mendalam jalur VPH_PWR, PMIC Qualcomm/MTK, injeksi tegangan short, dan reballing CPU UFS.',
      icon: Icons.android_rounded,
      themeColor: Color(0xFF10B981),
    ),
    EbookItem(
      id: 'ebook-iphone-1',
      title: 'Mastering Logic Board & Face ID iPhone',
      author: 'Spesialis Hardware iPhone VBAT',
      pages: '160 Halaman',
      courseType: 'iphone',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'Teknik pemisahan double-board (sandwich), reka ulang dot projector Face ID, dan perbaikan error panic log.',
      icon: Icons.apple_rounded,
      themeColor: Color(0xFF6B7280),
    ),
  ];

  void _openPdf(EbookItem ebook) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1E2430) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF001944);

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (ctx, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ebook.themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.picture_as_pdf_rounded, color: ebook.themeColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ebook.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${ebook.author} • ${ebook.pages}",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF151B26) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sinopsis & Deskripsi E-Book",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ebook.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF151B26) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Daftar Bab & Silabus Pembahasan:",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              const SizedBox(height: 10),
                              const Text("• Bab 1: Pengenalan Arsitektur Jalur Daya & Standar Tegangan", style: TextStyle(fontSize: 12, height: 1.6)),
                              const Text("• Bab 2: Cara Membaca Schematic Diagram & Boardview", style: TextStyle(fontSize: 12, height: 1.6)),
                              const Text("• Bab 3: Diagnosa Kerusakan Short-Circuit VDD_MAIN & VBUS", style: TextStyle(fontSize: 12, height: 1.6)),
                              const Text("• Bab 4: Teknik Jumper Jalur Putus & Reballing IC", style: TextStyle(fontSize: 12, height: 1.6)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(ebook.pdfUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Dokumen telah siap dibaca pada penampil terintegrasi.")),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.open_in_new_rounded, size: 18),
                            label: const Text("Buka File PDF Eksternal", style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ebook.themeColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _isDark ? ThemeManager.darkCard : _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "E-Book & Modul Panduan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: SessionManager.activeEntitlements,
        builder: (context, entitlements, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: _ebooks.length,
            itemBuilder: (context, index) {
              final ebook = _ebooks[index];
              final bool canAccess = SessionManager.canAccessCourse(ebook.courseType);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: canAccess
                        ? _borderColor
                        : (_isDark ? Colors.red.shade900 : Colors.red.shade100),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 72,
                          decoration: BoxDecoration(
                            color: ebook.themeColor.withValues(alpha: _isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ebook.themeColor.withValues(alpha: 0.3)),
                          ),
                          child: Icon(ebook.icon, color: ebook.themeColor, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: canAccess
                                      ? (_isDark
                                          ? Colors.green.shade900.withValues(alpha: 0.3)
                                          : Colors.green.shade50)
                                      : (_isDark
                                          ? Colors.orange.shade900.withValues(alpha: 0.3)
                                          : Colors.orange.shade50),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  canAccess ? "TERSEDIA UNTUK ANDA" : "MEMERLUKAN AKSES KELAS",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: canAccess
                                        ? (_isDark ? Colors.green.shade300 : Colors.green.shade800)
                                        : (_isDark ? Colors.orange.shade300 : Colors.orange.shade900),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ebook.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _textDark,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${ebook.author} • ${ebook.pages}",
                                style: TextStyle(fontSize: 12, color: _textGray),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ebook.description,
                      style: TextStyle(fontSize: 13, color: _textGray, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (canAccess) {
                            _openPdf(ebook);
                          } else {
                            context.push('/pricelist', extra: {
                              'highlightPackage': ebook.courseType == 'android' ? 'Kelas Android' : 'Kelas iPhone',
                            });
                          }
                        },
                        icon: Icon(
                          canAccess ? Icons.picture_as_pdf_rounded : Icons.lock_outline_rounded,
                          size: 18,
                        ),
                        label: Text(
                          canAccess ? "Buka & Baca E-Book" : "Beli Paket untuk Membuka",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAccess ? _primaryBlue : const Color(0xFFFD761A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
