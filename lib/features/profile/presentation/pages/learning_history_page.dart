import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';

class LearningHistoryPage extends StatefulWidget {
  const LearningHistoryPage({super.key});

  @override
  State<LearningHistoryPage> createState() => _LearningHistoryPageState();
}

class _LearningHistoryPageState extends State<LearningHistoryPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _orangeCTA = const Color(0xFFF78B00);

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
          "Riwayat Belajar",
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildHistoryCard(
            context,
            title: "Pengenalan Dasar Komponen iPhone",
            date: "Selesai pada 12 Okt 2023",
            progress: 1.0,
            imageUrl:
                "https://images.unsplash.com/photo-1512054502232-10a0a035d672?q=80&w=200&auto=format&fit=crop",
          ),
          const SizedBox(height: 16),
          _buildHistoryCard(
            context,
            title: "Teknik Jumper Jalur Putus",
            date: "Terakhir dilihat 15 Nov 2023",
            progress: 0.75,
            imageUrl:
                "https://images.unsplash.com/photo-1597740985671-2a8a3b80502e?q=80&w=200&auto=format&fit=crop",
          ),
          const SizedBox(height: 16),
          _buildHistoryCard(
            context,
            title: "Reballing IC Power Android",
            date: "Selesai pada 02 Jan 2024",
            progress: 1.0,
            imageUrl:
                "https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?q=80&w=200&auto=format&fit=crop",
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required String title,
    required String date,
    required double progress,
    required String imageUrl,
  }) {
    bool isCompleted = progress >= 1.0;

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Melanjutkan video materi...")),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: _isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      child: Icon(Icons.broken_image_rounded, color: _textGray),
                    ),
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: TextStyle(fontSize: 11, color: _textGray),
                    ),
                    const SizedBox(height: 12),

                    // Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: _isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.grey.shade200,
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : _orangeCTA,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : _orangeCTA,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
