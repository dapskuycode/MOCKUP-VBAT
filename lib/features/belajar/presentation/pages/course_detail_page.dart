import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/bookmark_helper.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/widgets/skeleton_loading.dart';

class CourseDetailPage extends StatefulWidget {
  final String module;
  final String category;
  final int? lessonId;
  final int? courseId;

  const CourseDetailPage({
    super.key,
    required this.module,
    required this.category,
    this.lessonId,
    this.courseId,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _greenSuccess = const Color(0xFF22C55E);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  bool _isLoading = false;
  int _completedStep = 0;

  List<Map<String, dynamic>> _playlist = [
    {"type": "video", "title": "1. Pengenalan Alat Dasar", "duration": "12:45"},
    {"type": "video", "title": "2. Standar Keselamatan (K3)", "duration": "08:20"},
    {"type": "video", "title": "3. Penggunaan Multimeter", "duration": "15:30"},
    {"type": "quiz", "title": "Kuis: Alat & Keselamatan"},
    {"type": "video", "title": "4. Memahami Skema Dasar", "duration": "20:15"},
    {"type": "video", "title": "5. Praktek Pembacaan Skema", "duration": "18:40"},
    {"type": "quiz", "title": "Kuis: Evaluasi Akhir Modul"},
  ];

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    if (widget.lessonId != null) {
      _fetchMaterialsFromBackend();
    }
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchMaterialsFromBackend() async {
    setState(() => _isLoading = true);
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final res = await dio.get(
        '/learning-materials',
        queryParameters: {'lesson_id': widget.lessonId},
      );
      if (res.data != null && res.data['data'] != null) {
        final List list = res.data['data'];
        if (list.isNotEmpty && mounted) {
          setState(() {
            _playlist = list.map<Map<String, dynamic>>((item) {
              final isPdf = item['material_type'] == 'pdf_document' ||
                  item['pdf_path'] != null;
              final isQuiz = item['quiz_id'] != null;
              final durationSec = item['duration_seconds'] ?? 600;
              final mins = (durationSec / 60).floor();
              final secs = (durationSec % 60).toString().padLeft(2, '0');

              return {
                'id': item['id'],
                'type': isPdf ? 'pdf' : (isQuiz ? 'quiz' : 'video'),
                'title': item['title'] ?? 'Materi Pelajaran',
                'duration': '$mins:$secs',
                'videoUrl': item['youtube_url'] ??
                    item['youtube_video_id'] ??
                    item['source_path'],
                'pdfPath': item['pdf_path'],
              };
            }).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Notice: Fetching materials from server: $e");
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleItemTap(int index, Map<String, dynamic> item) async {
    bool isLocked = index > _completedStep;

    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Terkunci! Selesaikan materi sebelumnya terlebih dahulu.",
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (item['type'] == 'video') {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        final result = await context.push<bool>(
          '/video-player',
          extra: {
            'title': item['title'],
            'playlist': _playlist,
            'currentIndex': index,
            'videoUrl': item['videoUrl'],
            'materialId': item['id'],
            'isFreeClass': widget.category.toLowerCase().contains('free') ||
                widget.module.toLowerCase().contains('free'),
          },
        );
        if (result == true && index == _completedStep) {
          setState(() {
            _completedStep++;
            _updateOverallProgress();
          });
        }
      }
    } else if (item['type'] == 'pdf') {
      _showPdfViewerSheet(index, item);
    } else if (item['type'] == 'quiz') {
      final result = await context.push<bool>('/quiz');
      if (result == true && index == _completedStep) {
        setState(() {
          _completedStep++;
          _updateOverallProgress();
        });

        if (_completedStep >= _playlist.length) {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Selamat!"),
              content: const Text(
                "Anda telah menyelesaikan seluruh materi pada modul ini.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop(); // Kembali ke silabus
                  },
                  child: const Text("Tutup"),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  void _updateOverallProgress() {
    if (_playlist.isNotEmpty) {
      final p = (_completedStep / _playlist.length).clamp(0.0, 1.0);
      SessionManager.learningProgress.value = p;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Column(
          children: [
            Text(
              widget.category,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              widget.module,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              BookmarkHelper.isBookmarked("${widget.category}_${widget.module}")
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: BookmarkHelper.isBookmarked("${widget.category}_${widget.module}")
                  ? Colors.amber
                  : Colors.white,
            ),
            tooltip: 'Simpan ke Bookmark Belajar',
            onPressed: () {
              setState(() {
                BookmarkHelper.toggleBookmark(context, {
                  "id": "${widget.category}_${widget.module}",
                  "title": widget.module,
                  "category": widget.category,
                  "module": widget.module,
                  "type": "course",
                  "duration": "${_playlist.length} Materi",
                });
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report_rounded, color: Colors.white70),
            tooltip: 'Dev Mode: Buka Semua Materi',
            onPressed: () {
              setState(() {
                _completedStep = _playlist.length;
                _updateOverallProgress();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Dev Mode: Semua materi dibuka & progress diperbarui."),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (_, _) => const CourseCardSkeleton(),
            )
          : Column(
              children: [
                // Banner Progress Modul
                Container(
                  padding: const EdgeInsets.all(16),
                  color: _cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Progress Modul",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            "$_completedStep / ${_playlist.length} Selesai",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _completedStep == _playlist.length
                                  ? _greenSuccess
                                  : (_isDark ? const Color(0xFF60A5FA) : _primaryBlue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _playlist.isEmpty
                              ? 0
                              : (_completedStep / _playlist.length).clamp(0.0, 1.0),
                          backgroundColor: _isDark ? const Color(0xFF1E2430) : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _completedStep == _playlist.length
                                ? _greenSuccess
                                : (_isDark ? const Color(0xFF60A5FA) : _primaryBlue),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                // Playlist Materi
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _playlist.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _playlist[index];
                      final isCompleted = index < _completedStep;
                      final isCurrent = index == _completedStep;
                      final isLocked = index > _completedStep;
                      final isPdf = item['type'] == 'pdf';
                      final isQuiz = item['type'] == 'quiz';

                      return InkWell(
                        onTap: () => _handleItemTap(index, item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrent
                                  ? (_isDark ? const Color(0xFF60A5FA) : _primaryBlue)
                                  : _borderColor,
                              width: isCurrent ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon Status
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isLocked
                                      ? (_isDark ? const Color(0xFF1E2430) : Colors.grey.shade100)
                                      : (isCompleted
                                          ? _greenSuccess.withValues(alpha: 0.12)
                                          : _primaryBlue.withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isLocked
                                      ? Icons.lock_rounded
                                      : (isCompleted
                                          ? Icons.check_circle_rounded
                                          : (isPdf
                                              ? Icons.picture_as_pdf_rounded
                                              : (isQuiz
                                                  ? Icons.quiz_rounded
                                                  : Icons.play_arrow_rounded))),
                                  color: isLocked
                                      ? (_isDark ? Colors.grey.shade600 : Colors.grey.shade400)
                                      : (isCompleted
                                          ? _greenSuccess
                                          : (_isDark ? const Color(0xFF60A5FA) : _primaryBlue)),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Info Materi
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isPdf
                                                ? (_isDark ? const Color(0xFF332512) : Colors.orange.shade50)
                                                : (isQuiz
                                                    ? (_isDark ? const Color(0xFF2A1B3D) : Colors.purple.shade50)
                                                    : (_isDark ? const Color(0xFF16253D) : Colors.blue.shade50)),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isPdf
                                                ? "DOKUMEN PDF"
                                                : (isQuiz ? "KUIS" : "VIDEO MATERI"),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: isPdf
                                                  ? (_isDark ? Colors.orange.shade400 : Colors.orange.shade800)
                                                  : (isQuiz
                                                      ? (_isDark ? Colors.purple.shade300 : Colors.purple.shade800)
                                                      : (_isDark ? const Color(0xFF60A5FA) : Colors.blue.shade800)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item['duration'] ?? '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _textGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['title'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isLocked
                                            ? (_isDark ? Colors.grey.shade600 : Colors.grey.shade400)
                                            : _textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Tombol Aksi
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _primaryBlue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Buka",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showPdfViewerSheet(int index, Map<String, dynamic> item) {
    final pdfUrl = (item['pdfPath'] ?? '').toString();
    final title = item['title'] ?? 'Dokumen Panduan PDF';

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
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Dokumen Teknis Resmi VBAT Ponsel",
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
                  // Content Preview / Reader
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // PDF Preview Banner
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
                              Row(
                                children: [
                                  const Icon(Icons.verified_user_rounded, color: Colors.blue, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "STANDAR OPERASIONAL & SKEMATIK VBAT",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "Modul: $title",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Panduan teknis ini berisi petunjuk keselamatan kerja meja servis teknisi, pengukuran nilai resistansi & hambatan jalur daya, serta diagram skematik terstandarisasi industri reparasi ponsel Indonesia.",
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Poin Penting: Selalu gunakan antistatis wrist-strap dan grounding mat saat melakukan pengukuran tegangan tinggi di sekitar modul IC daya.",
                                        style: TextStyle(fontSize: 12, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Schematic & Measurement Points
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
                                "Tabel Titik Uji & Parameter:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildParamRow("Tegangan VBAT Normal", "3.7V - 4.2V DC"),
                              _buildParamRow("Resistansi Jalur VDD_MAIN", "> 10 kΩ (Kondisi Normal)"),
                              _buildParamRow("Batas Suhu Blower IC", "350°C - 380°C (Maks 15 dtk)"),
                              _buildParamRow("Tekanan Udara Blower", "Level 3 - 4 (Medium Flow)"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final target = pdfUrl.isNotEmpty && !pdfUrl.contains('vbat.id')
                                      ? pdfUrl
                                      : 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
                                  final uri = Uri.parse(target);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Dokumen telah ditampilkan pada penampil bawaan.")),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                label: const Text("Unduh / File Luar"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(sheetCtx);
                                  if (index == _completedStep) {
                                    setState(() {
                                      _completedStep++;
                                      _updateOverallProgress();
                                    });
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text("Materi PDF selesai dibaca! Progres tersimpan."),
                                        ],
                                      ),
                                      backgroundColor: Color(0xFF10B981),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_rounded, size: 18),
                                label: const Text("Tandai Selesai"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B4F9B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
          },
        );
      },
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

