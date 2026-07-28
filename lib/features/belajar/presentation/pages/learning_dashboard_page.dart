import 'package:flutter/material.dart';

class LearningDashboardPage extends StatefulWidget {
  const LearningDashboardPage({super.key});

  @override
  State<LearningDashboardPage> createState() => _LearningDashboardPageState();
}

class _LearningDashboardPageState extends State<LearningDashboardPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _deepNavy = const Color(0xFF0D2B5E);
  final Color _ctaOrange = const Color(0xFFF97316);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textGray = const Color(0xFF434751);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Dashboard Belajar",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStreakCard(),
            const SizedBox(height: 16),
            _buildTargetCard(),
            const SizedBox(height: 16),
            _buildBadgesCard(),
            const SizedBox(height: 16),
            _buildMyCoursesCard(),
            const SizedBox(height: 16),
            _buildChartCard(),
            const SizedBox(height: 32), // Padding bottom
          ],
        ),
      ),
    );
  }

  // --- 1. Streak Card ---
  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: _ctaOrange,
                size: 36,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "7 Hari",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _deepNavy,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    "Runtutan Belajar!",
                    style: TextStyle(fontSize: 14, color: _textGray),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStreakDay("Sen", true, false),
              _buildStreakDay("Sel", true, false),
              _buildStreakDay("Rab", true, false),
              _buildStreakDay("Kam", true, false),
              _buildStreakDay("Jum", true, false),
              _buildStreakDay("Sab", true, false),
              _buildStreakDay("Min", true, true), // Hari ini
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDay(String day, bool isDone, bool isToday) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? _primaryBlue : _textGray,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone ? _primaryBlue : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: _primaryBlue.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isDone ? Icons.check_rounded : Icons.circle,
            color: Colors.white,
            size: 16,
          ),
        ),
      ],
    );
  }

  // --- 2. Target Progress Card ---
  Widget _buildTargetCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Target Bulanan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _deepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Anda hampir mencapai target belajar bulan ini. Terus semangat!",
                  style: TextStyle(fontSize: 13, color: _textGray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.65,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: _primaryBlue,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    "65%",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _deepNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Koleksi Badge Card ---
  Widget _buildBadgesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Koleksi Badge",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _deepNavy,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildBadgeItem(
                  Icons.military_tech_rounded,
                  Colors.blue,
                  "Pemula Solder",
                  false,
                ),
                _buildBadgeItem(
                  Icons.verified_rounded,
                  Colors.amber,
                  "Ahli Baterai",
                  false,
                ),
                _buildBadgeItem(
                  Icons.diamond_rounded,
                  Colors.teal,
                  "Teknisi Cepat",
                  false,
                ),
                _buildBadgeItem(
                  Icons.stars_rounded,
                  Colors.purple,
                  "Master Layar",
                  false,
                ),
                _buildBadgeItem(
                  Icons.workspace_premium_outlined,
                  Colors.grey,
                  "Guru Skema",
                  true,
                ),
                _buildBadgeItem(
                  Icons.emoji_events_outlined,
                  Colors.grey,
                  "Dewa Board",
                  true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(
    IconData icon,
    Color color,
    String title,
    bool isLocked,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade50 : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? Colors.transparent : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.shade200
                      : color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isLocked ? Colors.grey.shade500 : color,
                  size: 28,
                ),
              ),
              if (isLocked)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 2),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.grey.shade500 : _deepNavy,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Progress Kursus Card ---
  Widget _buildMyCoursesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kursus Saya",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _deepNavy,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildCourseProgressItem(
            "Micro-Soldering Lanjutan",
            "Modul 4: Reballing IC",
            Icons.memory_rounded,
            Colors.blue,
            0.75,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildCourseProgressItem(
            "Skema iPhone 14",
            "Modul 2: Jalur Audio",
            Icons.developer_board_rounded,
            Colors.indigo,
            0.30,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseProgressItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _deepNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: _textGray),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  color: _primaryBlue,
                  backgroundColor: Colors.grey.shade200,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Lanjutkan",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: _primaryBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Bar Chart Card ---
  Widget _buildChartCard() {
    // Data statis untuk grafik (Senin - Minggu)
    final List<double> chartData = [0.4, 0.6, 0.3, 0.85, 0.5, 0.2, 0.7];
    final List<String> days = ["S", "S", "R", "K", "J", "S", "M"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Waktu Belajar (Menit)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _deepNavy,
            ),
          ),
          const SizedBox(height: 24),

          // Chart Area
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                bool isHighlight =
                    index == 3 || index == 6; // Highlight Kamis & Minggu
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 130 * chartData[index],
                      decoration: BoxDecoration(
                        color: isHighlight
                            ? _primaryBlue
                            : Colors.grey.shade200,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isHighlight
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isHighlight ? _primaryBlue : _textGray,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 24),
          // Total Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total minggu ini:",
                  style: TextStyle(color: _textGray, fontSize: 13),
                ),
                Text(
                  "385 Menit",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _deepNavy,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
