import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseSyllabusPage extends StatelessWidget {
  final String category;

  const CourseSyllabusPage({super.key, required this.category});

  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk silabus berdasarkan kategori
    List<Map<String, dynamic>> modules = [
      {
        "title": "Modul 1: Pengenalan Alat & K3",
        "desc": "Mempelajari alat servis dasar, multimeter, dan keselamatan kerja.",
        "icon": Icons.build_circle_rounded,
        "count": "5 Materi",
      },
      {
        "title": "Modul 2: Teardown & Perakitan",
        "desc": "Cara bongkar pasang perangkat dengan aman tanpa merusak fleksibel.",
        "icon": Icons.phone_android_rounded,
        "count": "8 Materi",
      },
      {
        "title": "Modul 3: Penanganan Baterai & Layar",
        "desc": "Teknik penggantian baterai dan LCD/OLED beserta kalibrasinya.",
        "icon": Icons.battery_charging_full_rounded,
        "count": "6 Materi",
      },
      {
        "title": "Modul 4: Dasar Microsoldering",
        "desc": "Pengenalan mikroskop, solder, blower, dan teknik dasar angkat IC.",
        "icon": Icons.memory_rounded,
        "count": "10 Materi",
      },
      {
        "title": "Modul 5: Analisis Skema & Jalur",
        "desc": "Membaca schematic diagram, layout, dan nilai hambatan dalam (Diode Mode).",
        "icon": Icons.schema_rounded,
        "count": "7 Materi",
      },
    ];

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              "Silabus Materi",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final mod = modules[index];
          return _buildModuleCard(
            context,
            title: mod["title"],
            description: mod["desc"],
            itemCount: mod["count"],
            icon: mod["icon"],
          );
        },
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String description,
    required String itemCount,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/course-detail', extra: {'module': title, 'category': category});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: _primaryBlue, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF001944),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.play_circle_outline_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          itemCount,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFD761A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Mulai",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}
