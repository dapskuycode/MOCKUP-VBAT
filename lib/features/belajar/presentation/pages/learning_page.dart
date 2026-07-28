import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/features/home/presentation/pages/home_header_sliver.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/widgets/video_preview_widget.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);
  final Color _greenSuccess = const Color(0xFF22C55E);

  String _selectedBrand = "Semua";
  String _selectedCategory = "Semua";

  final ScrollController _scrollController = ScrollController();
  int _displayedCount = 4;
  bool _isLoadingMore = false;

  final List<Map<String, String>> _brands = [
    {"name": "Semua", "logo": ""},
    {"name": "Apple", "logo": "apple_logo.png"},
    {"name": "Samsung", "logo": "brand_samsung.png"},
    {"name": "Oppo", "logo": "brand_oppo.png"},
    {"name": "Xiaomi", "logo": "brand_xiaomi.png"},
    {"name": "Vivo", "logo": "brand_vivo.png"},
    {"name": "Asus", "logo": "brand_asus.png"},
  ];

  final List<Map<String, dynamic>> _allCourses = [
    {
      "title": "Mastering iPhone 13 LCD Replacement & TrueTone",
      "instructor": "Budi VBat",
      "views": "12K",
      "duration": "45:00",
      "progress": 0.65,
      "brand": "Apple",
      "category": "LCD Replacement",
      "isLocked": false,
      "image": "assets/images/course_soldering.png"
    },
    {
      "title": "Advanced iPhone Motherboard Micro-soldering",
      "instructor": "Master Chen",
      "views": "8.5K",
      "duration": "1:20:00",
      "progress": 0.0,
      "brand": "Apple",
      "category": "Motherboard",
      "isLocked": false,
      "badge": "PREMIUM",
      "badgeColor": const Color(0xFFFD761A),
      "image": "assets/images/course_soldering.png"
    },
    {
      "title": "Infinix Hot 10 Play Battery Replacement & Diagnostics",
      "instructor": "Tim VBat",
      "views": "5.3K",
      "duration": "18:00",
      "progress": 0.0,
      "brand": "Infinix",
      "category": "Battery",
      "isLocked": false,
      "badge": "GRATIS",
      "image": "assets/images/course_soldering.png"
    },
    {
      "title": "Samsung Galaxy S23 Ultra Camera Module Repair",
      "instructor": "Ahli Kamera",
      "views": "2.4K",
      "duration": "35:00",
      "progress": 0.0,
      "brand": "Samsung",
      "category": "Motherboard",
      "isLocked": true,
      "image": "assets/images/course_soldering.png"
    },
    {
      "title": "Oppo Reno 8 Charging Port Soldering & Care",
      "instructor": "Agus Solder",
      "views": "7.1K",
      "duration": "22:00",
      "progress": 0.1,
      "brand": "Oppo",
      "category": "Charging Port",
      "isLocked": false,
      "image": "assets/images/course_soldering.png"
    },
    {
      "title": "Xiaomi Redmi Note 12 Ghost Touch Touchscreen Fix",
      "instructor": "Dedy LCD",
      "views": "9.8K",
      "duration": "30:00",
      "progress": 0.0,
      "brand": "Xiaomi",
      "category": "LCD Replacement",
      "isLocked": false,
      "image": "assets/images/course_soldering.png"
    },
    {
      "title": "Vivo Y21 Screen Glass Replacement Guide",
      "instructor": "Rian Fix",
      "views": "4.2K",
      "duration": "25:00",
      "progress": 0.0,
      "brand": "Vivo",
      "category": "LCD Replacement",
      "isLocked": false,
      "image": "assets/images/course_soldering.png"
    },
    {
      "title": "Asus ROG Phone 6 Cooling Trigger Hardware Fix",
      "instructor": "Gamer Tech",
      "views": "3.8K",
      "duration": "40:00",
      "progress": 0.0,
      "brand": "Asus",
      "category": "Motherboard",
      "isLocked": true,
      "badge": "PREMIUM",
      "image": "assets/images/course_soldering.png"
    }
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _displayedCount += 3;
        _isLoadingMore = false;
      });
    });
  }

  List<Map<String, dynamic>> get _filteredCourses {
    return _allCourses.where((course) {
      final matchBrand = _selectedBrand == "Semua" || course["brand"] == _selectedBrand;
      final matchCategory = _selectedCategory == "Semua" || course["category"] == _selectedCategory;
      return matchBrand && matchCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCourses;
    final itemsToShow = filtered.take(_displayedCount).toList();

    return Scaffold(
      backgroundColor: _bgLight,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- 1. Header ---
          const HomeHeaderSliver(),

          // --- 3. Brand Selector (Pindahan dari BrandPage) ---
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    "PILIH BRAND HP",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _primaryBlue,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _brands.length,
                    itemBuilder: (context, index) {
                      final brand = _brands[index];
                      final isSelected = _selectedBrand == brand["name"];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBrand = brand["name"]!;
                            _displayedCount = 4; // Reset count
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Column(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: isSelected ? _primaryBlue : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? _primaryBlue : Colors.grey.shade200,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isSelected ? 0.15 : 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: brand["name"] == "Semua"
                                      ? Icon(
                                          Icons.all_inclusive_rounded,
                                          color: isSelected ? Colors.white : _primaryBlue,
                                          size: 24,
                                        )
                                      : Image.asset(
                                          'assets/images/${brand["logo"]}',
                                          width: 32,
                                          height: 32,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.phone_android_rounded,
                                            color: isSelected ? Colors.white : Colors.grey.shade600,
                                            size: 24,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                brand["name"]!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? _primaryBlue : _textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // --- 4. Jalur Belajar (Learning Path) ---
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _primaryBlue.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "JALUR BELAJAR ${_selectedBrand.toUpperCase()}",
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPathStep("Pemula", isCompleted: true),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: _primaryBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      _buildPathStep(
                        "Menengah",
                        isCurrent: true,
                        stepNumber: "2",
                      ),
                      Expanded(child: _buildDashedLine()),
                      _buildPathStep("Mahir", isLocked: true, stepNumber: "3"),
                      Expanded(child: _buildDashedLine()),
                      _buildPathStep(
                        "Expert",
                        isLocked: true,
                        icon: Icons.military_tech_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- 5. Kategori Filter (Scroll Horizontal) ---
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCategoryChip("Semua"),
                  _buildCategoryChip("LCD Replacement"),
                  _buildCategoryChip("Battery"),
                  _buildCategoryChip("Charging Port"),
                  _buildCategoryChip("Motherboard"),
                ],
              ),
            ),
          ),

          // --- 6. Daftar Kursus (Dynamic dengan Infinite Scroll) ---
          itemsToShow.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            "Belum ada kursus untuk filter ini",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = itemsToShow[index];
                        return _buildCourseCard(
                          title: course["title"],
                          instructor: course["instructor"],
                          views: course["views"],
                          duration: course["duration"],
                          badge: course["badge"],
                          badgeColor: course["badgeColor"],
                          isLocked: course["isLocked"],
                          image: course["image"],
                          progress: course["progress"] ?? 0.0,
                          statusWidget: course["isLocked"]
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "MEMBER ONLY",
                                    style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : (course["progress"] != null && course["progress"] > 0
                                  ? Text(
                                      "${(course['progress'] * 100).toInt()}% SELESAI",
                                      style: TextStyle(color: _primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _greenSuccess.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _greenSuccess.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        "GRATIS",
                                        style: TextStyle(color: _greenSuccess, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    )),
                        );
                      },
                      childCount: itemsToShow.length,
                    ),
                  ),
                ),

          // Loading indicator
          if (_isLoadingMore && filtered.length > _displayedCount)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
                    ),
                  ),
                ),
              ),
            ),

          // --- 7. Sponsor Banner ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primaryBlue.withValues(alpha: 0.9),
                      _primaryBlue.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "SPONSOR",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Kursus didukung oleh BraderParts",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ), // Safe area bottom nav
        ],
      ),
    );
  }



  Widget _buildPathStep(
    String label, {
    bool isCompleted = false,
    bool isCurrent = false,
    bool isLocked = false,
    String? stepNumber,
    IconData? icon,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? _primaryBlue
                : (isCurrent ? Colors.white : Colors.grey.shade200),
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: _primaryBlue, width: 2)
                : null,
            boxShadow: isCompleted || isCurrent
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : (icon != null
                      ? Icon(icon, color: Colors.grey.shade500, size: 16)
                      : Text(
                          stepNumber ?? "",
                          style: TextStyle(
                            color: isCurrent
                                ? _primaryBlue
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCompleted || isCurrent
                ? _primaryBlue
                : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.shade400),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
            _displayedCount = 4; // Reset
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? _primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : _textGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String instructor,
    required String views,
    required String duration,
    required Widget statusWidget,
    String? badge,
    Color? badgeColor,
    IconData? badgeIcon,
    double progress = 0.0,
    bool isLocked = false,
    String? image,
  }) {
    return GestureDetector(
      onTap: () {
        if (!SessionManager.isLoggedIn.value) {
          context.push('/login');
        } else if (badge == "PREMIUM") {
          context.push('/subscription');
        } else {
          context.push('/course-detail');
        }
      },
      child: Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Left Side
            SizedBox(
              width: 120,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24),
                      ),
                      child: VideoPreviewWidget(
                        videoUrl: "assets/videos/VIDEO-2026-07-26-21-31-11.mp4",
                        fallbackImage: image ?? "",
                      ),
                    ),
                  ),
                  if (isLocked)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(24),
                        ),
                      ),
                    ),
                  if (badge != null)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor ?? Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            if (badgeIcon != null)
                              Icon(badgeIcon, color: Colors.white, size: 10),
                            if (badgeIcon != null) const SizedBox(width: 2),
                            Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (duration.isNotEmpty)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (progress > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: progress,
                        color: _primaryBlue,
                        backgroundColor: Colors.grey.shade300,
                        minHeight: 4,
                      ),
                    ),
                ],
              ),
            ),

            // Detail Right Side
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 12,
                              color: _textGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              instructor,
                              style: TextStyle(fontSize: 10, color: _textGray),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (views.isNotEmpty && views != "-")
                          Row(
                            children: [
                              Icon(
                                Icons.visibility_rounded,
                                size: 12,
                                color: _textGray,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                views,
                                style: TextStyle(fontSize: 10, color: _textGray),
                              ),
                            ],
                          )
                        else
                          const SizedBox(),
                        statusWidget,
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
