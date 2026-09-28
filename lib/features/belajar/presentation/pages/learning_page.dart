import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/bookmark_helper.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/features/home/presentation/pages/home_header_sliver.dart';
import 'package:vbat_ponsel/core/widgets/skeleton_loading.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  bool _isLoading = true;
  List<Map<String, dynamic>> _serverCourses = [];

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    _fetchCoursesFromBackend();
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchCoursesFromBackend() async {
    setState(() => _isLoading = true);
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final res = await dio.get('/courses');
      if (res.data != null && res.data['data'] != null) {
        if (mounted) {
          setState(() {
            _serverCourses = List<Map<String, dynamic>>.from(res.data['data']);
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint("Error fetching courses from server: $e");
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleCardTap({
    required String title,
    required String type,
    required bool isLocked,
    String? lockReason,
  }) async {
    // 1. Jika kartu terkunci
    if (isLocked) {
      if (type == 'hardware_solution') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lockReason ??
                  "Akses terkunci! Selesaikan minimal 90% materi & lulus evaluasi kuis untuk membuka otomatis.",
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: "Mengerti",
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        return;
      }

      // Mengarah ke halaman pembelian dengan paket terkait disorot (Highlighted)
      final result = await context.push<bool>(
        '/pricelist',
        extra: {'highlightPackage': title},
      );
      if (result == true && mounted) {
        setState(() {}); // Refresh UI setelah pembelian
      }
      return;
    }

    // 2. Jika kartu Hardware Solution terbuka
    if (type == 'hardware_solution') {
      context.push('/hardware-solution');
      return;
    }

    // 3. Masuk ke halaman Silabus & Materi Kelas
    context.push(
      '/course-syllabus',
      extra: {
        'category': title,
        'type': type,
        'serverCourses': _serverCourses,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: SessionManager.activeEntitlements,
        builder: (context, entitlements, child) {
          return ValueListenableBuilder<double>(
            valueListenable: SessionManager.learningProgress,
            builder: (context, progress, _) {
              final bool hasAndroid = SessionManager.canAccessCourse('android');
              final bool hasIphone = SessionManager.canAccessCourse('iphone');
              final bool isHsUnlocked = SessionManager.isHardwareSolutionUnlocked;

              return RefreshIndicator(
                onRefresh: _fetchCoursesFromBackend,
                color: _primaryBlue,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // Header Bawaan
                    const HomeHeaderSliver(),

                    // Status Bar Entitlement & Progress Belajar
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryBlue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entitlements.contains('bundling')
                                        ? "MEMBER PAKET BUNDLING (VIP)"
                                        : (hasAndroid && hasIphone)
                                            ? "MEMBER ANDROID & IPHONE"
                                            : hasAndroid
                                                ? "MEMBER KELAS ANDROID"
                                                : hasIphone
                                                    ? "MEMBER KELAS IPHONE"
                                                    : "AKUN PEMBELAJAR (FREE TIER)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Progres Lulus: ${(progress * 100).toInt()}% • Syarat HS: 90%",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _textGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quick Switcher Tester
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.tune_rounded,
                                size: 20,
                                color: Colors.grey,
                              ),
                              tooltip: "Uji Coba Matriks Akses (Dev)",
                              onSelected: (val) {
                                setState(() {
                                  if (val == 'guest') {
                                    SessionManager.activeEntitlements.value = {'free_class'};
                                    SessionManager.learningProgress.value = 0.0;
                                  } else if (val == 'android') {
                                    SessionManager.activeEntitlements.value = {'free_class', 'android'};
                                  } else if (val == 'iphone') {
                                    SessionManager.activeEntitlements.value = {'free_class', 'iphone'};
                                  } else if (val == 'bundling') {
                                    SessionManager.activeEntitlements.value = {'free_class', 'android', 'iphone', 'bundling'};
                                  } else if (val == 'unlock_hs') {
                                    SessionManager.learningProgress.value = 0.95;
                                  }
                                });
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'guest',
                                  child: Text("Mode: Tamu / Guest (Belum Beli)"),
                                ),
                                const PopupMenuItem(
                                  value: 'android',
                                  child: Text("Mode: Pembeli Android Only"),
                                ),
                                const PopupMenuItem(
                                  value: 'iphone',
                                  child: Text("Mode: Pembeli iPhone Only"),
                                ),
                                const PopupMenuItem(
                                  value: 'bundling',
                                  child: Text("Mode: Pembeli Bundling (Semua)"),
                                ),
                                const PopupMenuItem(
                                  value: 'unlock_hs',
                                  child: Text("Lulus 95% (Buka Hardware Solution)"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Teks Judul Kategori
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "PROGRAM PELATIHAN TEKNISI",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => context.push('/ebooks'),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _isDark ? const Color(0xFF332512) : Colors.amber.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _isDark ? Colors.amber.shade700 : Colors.amber.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.menu_book_rounded, 
                                              size: 13, 
                                              color: _isDark ? Colors.amber.shade400 : Colors.amber.shade900,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "E-Book",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: _isDark ? Colors.amber.shade400 : Colors.amber.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () => BookmarkHelper.show(context),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _isDark ? _primaryBlue.withValues(alpha: 0.25) : _primaryBlue.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _isDark ? const Color(0xFF60A5FA).withValues(alpha: 0.4) : _primaryBlue.withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.bookmark_rounded, 
                                              size: 13, 
                                              color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Bookmark",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Pilih fokus materi keahlian servis HP. Materi yang belum dimiliki dapat dibuka melalui paket belajar.",
                              style: TextStyle(fontSize: 12, color: _textGray),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Grid 4 Kartu Sesuai Permintaan Klien
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: _isLoading
                          ? SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => const ProductCardSkeleton(),
                                childCount: 4,
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              delegate: SliverChildListDelegate([
                                // CARD 1: KELAS ANDROID
                                _buildAccessCard(
                                  title: "Kelas Android",
                                  subtitle:
                                      "Materi perbaikan hardware, voltase VBAT & skematik Android.",
                                  icon: Icons.android_rounded,
                                  color: const Color(0xFF3DDC84),
                                  isLocked: !hasAndroid,
                                  lockLabel: "Beli Paket",
                                  type: 'android',
                                ),

                                // CARD 2: KELAS IPHONE
                                _buildAccessCard(
                                  title: "Kelas iPhone",
                                  subtitle:
                                      "Materi mendalam perbaikan hardware & reballing IC iPhone.",
                                  icon: Icons.apple_rounded,
                                  color: const Color(0xFF555555),
                                  isLocked: !hasIphone,
                                  lockLabel: "Beli Paket",
                                  type: 'iphone',
                                ),

                                // CARD 3: FREE CLASS (SELALU TERBUKA)
                                _buildAccessCard(
                                  title: "Free Class",
                                  subtitle:
                                      "Materi dasar gratis, pengenalan alat & SOP K3 teknisi ponsel.",
                                  icon: Icons.play_circle_fill_rounded,
                                  color: const Color(0xFF6366F1),
                                  isLocked: false,
                                  badge: "GRATIS",
                                  badgeColor: const Color(0xFF10B981),
                                  type: 'free_class',
                                ),

                                // CARD 4: HARDWARE SOLUTION (UNLOCK 90%)
                                _buildAccessCard(
                                  title: "Hardware Solution",
                                  subtitle:
                                      "Dokumen skematik jalur, diode mode, dan board layout.",
                                  icon: Icons.memory_rounded,
                                  color: _primaryBlue,
                                  isLocked: !isHsUnlocked,
                                  lockLabel: "Syarat 90%",
                                  lockReason:
                                      "Hardware Solution terbuka otomatis setelah Anda menyelesaikan minimal 90% materi dan lulus kuis.",
                                  type: 'hardware_solution',
                                ),
                              ]),
                            ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isLocked,
    required String type,
    String? lockLabel,
    String? lockReason,
    String? badge,
    Color? badgeColor,
  }) {
    return GestureDetector(
      onTap: () => _handleCardTap(
        title: title,
        type: type,
        isLocked: isLocked,
        lockReason: lockReason,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLocked ? _borderColor : color.withValues(alpha: 0.3),
            width: isLocked ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isLocked ? 0.03 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor ?? color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: _textGray,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Tampilan Gembok Terkunci (Overlay)
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDark ? ThemeManager.darkBg.withValues(alpha: 0.88) : Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            color: _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            size: 24,
                          ),
                        ),
                        if (lockLabel != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isDark ? const Color(0xFF243042) : const Color(0xFF001944),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _borderColor),
                            ),
                            child: Text(
                              lockLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
