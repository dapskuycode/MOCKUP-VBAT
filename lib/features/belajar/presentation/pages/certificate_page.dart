import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class CertificatePage extends StatefulWidget {
  const CertificatePage({super.key});

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _greenSuccess = const Color(0xFF10B981);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  bool _isLoading = true;
  List<Map<String, dynamic>> _certificates = [];

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    _loadCertificates();
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      // Coba fetch dari backend (user 4 / Andi Teknisi token mock)
      final response = await dio.get('/certificates/verify/CERT-VBAT-2026-0004-AND');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final item = response.data['data'];
        setState(() {
          _certificates = [
            {
              'id': 1,
              'title': item['title'] ?? 'Sertifikat Kelulusan: Teknisi Spesialis Android & Hardware',
              'certificate_number': item['certificate_number'] ?? 'CERT-VBAT-2026-0004-AND',
              'user_name': item['user_name'] ?? SessionManager.userName,
              'date': '21 September 2026',
              'is_valid': item['is_valid'] ?? true,
              'pdf_url': 'https://vbat.id/storage/certificates/CERT-VBAT-2026-0004-AND.pdf',
              'category': 'Android Hardware',
            },
            {
              'id': 2,
              'title': 'Sertifikat Kelulusan: Diagnosis Micro-Soldering Level 1',
              'certificate_number': 'CERT-VBAT-2026-0002-MSL',
              'user_name': SessionManager.userName,
              'date': '12 Agustus 2026',
              'is_valid': true,
              'pdf_url': 'https://vbat.id/storage/certificates/CERT-VBAT-2026-0002-MSL.pdf',
              'category': 'Soldering Specialist',
            },
          ];
          _isLoading = false;
        });
        return;
      }
    } catch (_) {
      // Fallback data terverifikasi offline
    }

    setState(() {
      _certificates = [
        {
          'id': 1,
          'title': 'Sertifikat Kelulusan: Teknisi Spesialis Android & Hardware',
          'certificate_number': 'CERT-VBAT-2026-0004-AND',
          'user_name': SessionManager.userName,
          'date': '21 September 2026',
          'is_valid': true,
          'pdf_url': 'https://vbat.id/storage/certificates/CERT-VBAT-2026-0004-AND.pdf',
          'category': 'Android Hardware',
        },
        {
          'id': 2,
          'title': 'Sertifikat Kelulusan: Diagnosis Micro-Soldering Level 1',
          'certificate_number': 'CERT-VBAT-2026-0002-MSL',
          'user_name': SessionManager.userName,
          'date': '12 Agustus 2026',
          'is_valid': true,
          'pdf_url': 'https://vbat.id/storage/certificates/CERT-VBAT-2026-0002-MSL.pdf',
          'category': 'Soldering Specialist',
        },
      ];
      _isLoading = false;
    });
  }

  void _showQrDialog(BuildContext context, Map<String, dynamic> cert) {
    final certNumber = cert['certificate_number'] as String;
    final verifyUrl = 'https://vbat.id/certificates/verify/$certNumber';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _cardColor,
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
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                           Icons.verified_rounded,
                          color: Color(0xFF10B981),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Verifikasi Publik",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            "QR Validasi Keaslian VBAT",
                            style: TextStyle(
                              fontSize: 11,
                              color: _textGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: _textGray),
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
                  data: verifyUrl,
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF001944),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1B4F9B),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                certNumber,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cert['title'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: _textGray,
                ),
              ),
              const SizedBox(height: 8),
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
                      "TERDAFTAR & SAH PERMANEN",
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
                    Clipboard.setData(ClipboardData(text: verifyUrl));
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
                  label: const Text("Salin URL Verifikasi"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1B4F9B),
                    side: BorderSide(
                      color: _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1B4F9B),
                    ),
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

  void _downloadOrOpenPdf(String pdfUrl) async {
    final uri = Uri.parse(pdfUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Membuka PDF sertifikat: $pdfUrl"),
            backgroundColor: _primaryBlue,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Menyiapkan dokumen sertifikat..."),
          backgroundColor: _primaryBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _isDark ? Colors.white : _primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Sertifikat Digital",
          style: TextStyle(
            color: _isDark ? Colors.white : _primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: _isDark ? Colors.white : _primaryBlue),
            onPressed: _loadCertificates,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCertificates,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. Summary Card ---
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1B4F9B),
                            const Color(0xFF0F172A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B4F9B).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.amberAccent,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${_certificates.length} Sertifikat Resmi",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Terdaftar secara publik di database VBAT",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 2. List Sertifikat Diraih ---
                    const Text(
                      "SERTIFIKAT KELULUSAN ANDA",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Color(0xFF737782),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._certificates.map((cert) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCertificateCard(context, cert),
                        )),

                    const SizedBox(height: 24),

                    // --- 3. Sertifikat Mendatang ---
                    Text(
                      "Sertifikat Mendatang",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildUpcomingCard(
                      title: "Master iPhone Board Repair & CPU Reballing",
                      subtitle: "Capai 90% modul Hardware Solution untuk lulus",
                      progress: 0.65,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCertificateCard(
    BuildContext context,
    Map<String, dynamic> cert,
  ) {
    final title = cert['title'] as String;
    final date = cert['date'] as String;
    final certNumber = cert['certificate_number'] as String;
    final category = cert['category'] as String;
    final pdfUrl = cert['pdf_url'] as String;

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: _isDark
                ? const Color(0xFF60A5FA).withValues(alpha: 0.1)
                : const Color(0xFF1B4F9B).withValues(alpha: 0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.military_tech_rounded,
                      color: _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1B4F9B),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1B4F9B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _greenSuccess.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: _greenSuccess, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        "VERIFIED",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _greenSuccess,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "No. Seri: $certNumber",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1B4F9B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Diterbitkan: $date",
                  style: TextStyle(fontSize: 12, color: _textGray),
                ),

                const SizedBox(height: 16),
                Divider(height: 1, color: _borderColor),
                const SizedBox(height: 14),

                // Actions: QR Verifikasi & Unduh PDF
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showQrDialog(context, cert),
                        icon: const Icon(Icons.qr_code_rounded, size: 18),
                        label: const Text(
                          "QR Verifikasi",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B4F9B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadOrOpenPdf(pdfUrl),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text(
                          "Unduh PDF",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textDark,
                          side: BorderSide(color: _borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard({
    required String title,
    required String subtitle,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: _textGray),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryBlue.withValues(alpha: _isDark ? 0.25 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              color: _greenSuccess,
              backgroundColor: _isDark
                  ? const Color(0xFF2D3748)
                  : const Color(0xFF4A9EE0).withValues(alpha: 0.2),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
