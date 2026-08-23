import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({super.key});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);
  final Color _orangeCTA = const Color(0xFFF97316);
  final Color _greenSuccess = const Color(0xFF22C55E);

  int _selectedTabIndex = 0;
  
  // State untuk dummy unlock sequential (0: awal, 1: vid1 selesai, 2: vid2 selesai, 3: vid3 selesai, 4: kuis selesai)
  int _completedStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      // --- Sticky Bottom Action Bar (Subscription CTA) ---
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Akses Penuh",
                    style: TextStyle(fontSize: 12, color: _textGray),
                  ),
                  Text(
                    "Mastering iPhone 13",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => context.push('/video-player', extra: {'title': 'Mastering iPhone 13 Screen Repair'}),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orangeCTA,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
              label: const Text(
                "Mulai Belajar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- 1. Top App Bar ---
          SliverAppBar(
            backgroundColor: _primaryBlue,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              "Detail Kursus",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // --- 2. Hero Video Thumbnail ---
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.8,
                      child: Container(
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/video-player', extra: {'title': 'Mastering iPhone 13 Screen Repair'}),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _primaryBlue.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "LCD Replacement",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.schedule_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "4h 20m",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 3. Info Kursus Utama ---
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mastering iPhone 13 Screen Repair",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.push('/learning-dashboard'),
                        icon: const Icon(Icons.dashboard_rounded, size: 16),
                        label: const Text("Dashboard", style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue.withOpacity(0.1),
                          foregroundColor: _primaryBlue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/certificate'),
                        icon: const Icon(Icons.emoji_events_rounded, size: 16),
                        label: const Text("Sertifikat", style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.withOpacity(0.1),
                          foregroundColor: Colors.amber.shade800,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFFF1F5F9),
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Budi Teknisi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _textDark,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Senior Instructor",
                                style: TextStyle(
                                  color: _textGray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _orangeCTA.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _orangeCTA.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          "MEMBER ONLY",
                          style: TextStyle(
                            color: _orangeCTA,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Dummy button to simulate progress
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_completedStep < 5) _completedStep++;
                              else _completedStep = 0;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                          ),
                          child: Text(_completedStep < 5 ? "Simulate: Selesaikan Materi (${_completedStep}/5)" : "Reset Progress"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "4.8",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        " (120)",
                        style: TextStyle(color: _textGray, fontSize: 12),
                      ),
                      _buildDotDivider(),
                      Icon(Icons.group_rounded, color: _textGray, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "1.2k Siswa",
                        style: TextStyle(color: _textGray, fontSize: 13),
                      ),
                      _buildDotDivider(),
                      Icon(
                        Icons.play_circle_outline_rounded,
                        color: _textGray,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "15 Video",
                        style: TextStyle(color: _textGray, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- 4. Tabs (Sticky) ---
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 50.0,
              maxHeight: 50.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTabItem("Materi", 0),
                    _buildTabItem("Ulasan", 1),
                    _buildTabItem("Tentang", 2),
                  ],
                ),
              ),
            ),
          ),

          // --- 5. Daftar Materi (Curriculum) ---
          if (_selectedTabIndex == 0)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Modul 1: Persiapan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCurriculumItem(
                    context,
                    "Pengenalan Alat & K3",
                    "12:45",
                    isLocked: false,
                    isCompleted: _completedStep >= 1,
                  ),
                  _buildCurriculumItem(
                    context,
                    "Teardown iPhone 13",
                    "24:10",
                    isLocked: _completedStep < 1,
                    isCompleted: _completedStep >= 2,
                  ),
                  _buildCurriculumItem(
                    context,
                    "Pemisahan LCD dari Bezel",
                    "18:30",
                    isLocked: _completedStep < 2,
                    isCompleted: _completedStep >= 3,
                  ),
 
                  const SizedBox(height: 24),
                  Text(
                    "Evaluasi",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuizItem(
                    context, 
                    "Kuis Evaluasi Modul 1", 
                    isLocked: _completedStep < 3,
                    isCompleted: _completedStep >= 4,
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    "Modul 2: Pemasangan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCurriculumItem(
                    context,
                    "Pemasangan True Tone",
                    "15:20",
                    isLocked: _completedStep < 4,
                    isCompleted: _completedStep >= 5,
                  ),
                ],
              ),
            ),
          ),

          // --- 6. Kursus Terkait ---
          SliverToBoxAdapter(
            child: Container(
              color: _bgLight,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Kursus Terkait",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildRelatedCourseCard(
                          "Advanced Battery Replacement",
                          "Baterai",
                          "4.6",
                        ),
                        _buildRelatedCourseCard(
                          "Dasar Microsoldering & Reballing IC",
                          "Microsoldering",
                          "4.9",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDotDivider() {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? _primaryBlue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? _primaryBlue : _textGray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizItem(BuildContext context, String title, {required bool isLocked, required bool isCompleted}) {
    return GestureDetector(
      onTap: () {
        if (!isLocked) {
           context.push('/quiz');
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selesaikan video sebelumnya terlebih dahulu!")));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade100 : (isCompleted ? _greenSuccess.withOpacity(0.1) : Colors.orange.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isLocked ? Colors.grey.shade300 : (isCompleted ? _greenSuccess.withOpacity(0.3) : Colors.orange.shade200)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey.shade300 : (isCompleted ? _greenSuccess.withOpacity(0.2) : Colors.orange.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked ? Icons.lock_rounded : (isCompleted ? Icons.check_circle_rounded : Icons.assignment_rounded), 
                color: isLocked ? Colors.grey.shade600 : (isCompleted ? _greenSuccess : Colors.orange.shade700), 
                size: 20
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey.shade500 : (isCompleted ? _greenSuccess : Colors.orange.shade900),
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isLocked ? Colors.grey.shade400 : (isCompleted ? _greenSuccess : Colors.orange.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculumItem(
    BuildContext context,
    String title,
    String duration, {
    required bool isLocked,
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          context.push('/video-player', extra: {'title': title});
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Materi ini masih terkunci. Selesaikan materi sebelumnya!")));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade50 : (isCompleted ? _greenSuccess.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isLocked ? Colors.grey.shade200 : (isCompleted ? _greenSuccess.withOpacity(0.2) : Colors.grey.shade300)),
        ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.grey.shade300
                  : (isCompleted ? _greenSuccess.withOpacity(0.2) : _primaryBlue.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isLocked ? Icons.lock_rounded : (isCompleted ? Icons.check_circle_rounded : Icons.play_arrow_rounded),
              color: isLocked ? Colors.grey.shade600 : (isCompleted ? _greenSuccess : _primaryBlue),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isLocked ? _textGray : _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(fontSize: 12, color: _textGray),
                ),
              ],
            ),
          ),
        ],
      ),
    ),);
  }

  Widget _buildRelatedCourseCard(String title, String category, String rating) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.image, color: Colors.grey)),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Akses Member",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _orangeCTA,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(fontSize: 12, color: _textGray),
                        ),
                      ],
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
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
