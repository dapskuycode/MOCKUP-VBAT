import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/widgets/skeleton_loading.dart';

class CourseSyllabusPage extends StatefulWidget {
  final String category;
  final String? type;
  final List<Map<String, dynamic>>? serverCourses;

  const CourseSyllabusPage({
    super.key,
    required this.category,
    this.type,
    this.serverCourses,
  });

  @override
  State<CourseSyllabusPage> createState() => _CourseSyllabusPageState();
}

class _CourseSyllabusPageState extends State<CourseSyllabusPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  bool _isLoading = true;
  int? _resolvedCourseId;
  String _courseTitle = "";
  List<Map<String, dynamic>> _lessons = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    _courseTitle = widget.category;
    _fetchSyllabusFromBackend();
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchSyllabusFromBackend() async {
    setState(() => _isLoading = true);
    final dio = Dio(
      BaseOptions(
        baseUrl: SessionManager.apiBaseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    );

    try {
      int? targetCourseId;

      // 1. Cari course ID dari server
      final courseRes = await dio.get('/courses');
      if (courseRes.data != null && courseRes.data['data'] != null) {
        final List courses = courseRes.data['data'];
        final targetType = (widget.type ?? widget.category).toLowerCase();

        for (final c in courses) {
          final cType = (c['type'] ?? '').toString().toLowerCase();
          final isFree = c['is_free_class'] == true;

          if (targetType.contains('free') && (isFree || cType == 'free_class')) {
            targetCourseId = c['id'];
            _courseTitle = c['title'] ?? widget.category;
            break;
          } else if (targetType.contains('android') && cType == 'android' && !isFree) {
            targetCourseId = c['id'];
            _courseTitle = c['title'] ?? widget.category;
            break;
          } else if (targetType.contains('iphone') && cType == 'iphone' && !isFree) {
            targetCourseId = c['id'];
            _courseTitle = c['title'] ?? widget.category;
            break;
          }
        }
      }

      _resolvedCourseId = targetCourseId;

      // 2. Fetch lessons dari course tersebut
      if (targetCourseId != null) {
        final lessonRes = await dio.get(
          '/lessons',
          queryParameters: {'course_id': targetCourseId},
        );
        if (lessonRes.data != null && lessonRes.data['data'] != null) {
          final List list = lessonRes.data['data'];
          if (list.isNotEmpty && mounted) {
            setState(() {
              _lessons = list.map((item) {
                return {
                  'id': item['id'],
                  'course_id': item['course_id'],
                  'title': item['title'] ?? 'Modul Pelajaran',
                  'desc': item['description'] ??
                      'Materi teknisi terverifikasi & panduan praktik.',
                  'count': 'Materi Tersedia',
                  'icon': Icons.menu_book_rounded,
                };
              }).toList();
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Notice: Fetching server syllabus fallback to default: $e");
    }

    // Fallback data jika server belum diisi / offline
    if (mounted) {
      setState(() {
        _lessons = _getDefaultModules(widget.category);
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDefaultModules(String category) {
    if (category.toLowerCase().contains('free')) {
      return [
        {
          "id": 1,
          "title": "Modul 1: Pengenalan Alat Dasar & K3",
          "desc": "Mempelajari alat servis dasar, multimeter digital, dan keselamatan kerja.",
          "icon": Icons.build_circle_rounded,
          "count": "2 Materi",
        },
        {
          "id": 2,
          "title": "Modul 2: Teardown & Perakitan Casing",
          "desc": "Cara bongkar pasang perangkat dengan aman tanpa merusak fleksibel.",
          "icon": Icons.phone_android_rounded,
          "count": "3 Materi",
        },
      ];
    }
    return [
      {
        "id": 1,
        "title": "Modul 1: Pengenalan Alat & K3",
        "desc": "Mempelajari alat servis dasar, multimeter, dan keselamatan kerja.",
        "icon": Icons.build_circle_rounded,
        "count": "5 Materi",
      },
      {
        "id": 2,
        "title": "Modul 2: Teardown & Perakitan",
        "desc": "Cara bongkar pasang perangkat dengan aman tanpa merusak fleksibel.",
        "icon": Icons.phone_android_rounded,
        "count": "8 Materi",
      },
      {
        "id": 3,
        "title": "Modul 3: Penanganan Baterai & Layar",
        "desc": "Teknik penggantian baterai dan LCD/OLED beserta kalibrasinya.",
        "icon": Icons.battery_charging_full_rounded,
        "count": "6 Materi",
      },
      {
        "id": 4,
        "title": "Modul 4: Dasar Microsoldering",
        "desc": "Pengenalan mikroskop, solder, blower, dan teknik dasar angkat IC.",
        "icon": Icons.memory_rounded,
        "count": "10 Materi",
      },
      {
        "id": 5,
        "title": "Modul 5: Analisis Skema & Jalur",
        "desc": "Membaca schematic diagram, layout, dan nilai hambatan dalam (Diode Mode).",
        "icon": Icons.schema_rounded,
        "count": "7 Materi",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filteredLessons = _lessons.where((m) {
      final t = (m['title'] ?? '').toString().toLowerCase();
      final d = (m['desc'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return t.contains(q) || d.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _isDark ? ThemeManager.darkCard : _primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSyllabusFromBackend,
        color: _primaryBlue,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Deskripsi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                decoration: BoxDecoration(
                  color: _isDark ? ThemeManager.darkCard : _primaryBlue,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _courseTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Pelajari materi langkah demi langkah untuk menguasai standar perbaikan teknisi handphone profesional.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Search Bar Materi
                    Container(
                      decoration: BoxDecoration(
                        color: _isDark ? ThemeManager.darkBg : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: _isDark ? Border.all(color: _borderColor) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: TextStyle(color: _textDark, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Cari judul materi / modul...",
                          hintStyle: TextStyle(
                            color: _textGray,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Subjudul Daftar Modul
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "DAFTAR MODUL MATERI",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _textGray,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: _isDark ? 0.25 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${filteredLessons.length} Modul",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Daftar Modul Silabus
              if (_isLoading)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (_, _) => const CourseCardSkeleton(),
                )
              else if (filteredLessons.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: _textGray,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Materi tidak ditemukan",
                        style: TextStyle(
                          color: _textGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredLessons.length,
                  itemBuilder: (context, index) {
                    final item = filteredLessons[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      color: _cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: _borderColor),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context.push(
                            '/course-detail',
                            extra: {
                              'module': item['title'],
                              'category': widget.category,
                              'lessonId': item['id'],
                              'courseId': _resolvedCourseId,
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _isDark
                                      ? const Color(0xFF60A5FA).withValues(alpha: 0.15)
                                      : _primaryBlue.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item['icon'] as IconData? ?? Icons.play_lesson_rounded,
                                  color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['desc'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _textGray,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: _textGray,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
