import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/features/home/presentation/pages/home_header_sliver.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);

  // Dummy states
  bool _hasPaid = false;
  bool _allMateriCompleted = false;

  void _handleCardTap(String category) async {
    if (!_hasPaid) {
      // Buka Pricelist Page
      final result = await context.push<bool>('/pricelist');
      if (result == true) {
        setState(() {
          _hasPaid = true;
        });
      }
      return;
    }

    if (category == 'Hardware Solution') {
      if (!_allMateriCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Akses terkunci. Anda harus menyelesaikan seluruh materi video & kuis terlebih dahulu."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Masuk ke Hardware Solution Page
      context.push('/hardware-solution');
      return;
    }

    if (category == 'Paket Bundling') {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Akses Paket Bundling",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001944),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Pilih kategori kelas yang ingin Anda pelajari saat ini:",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.android_rounded, color: Color(0xFF3DDC84)),
                  title: const Text("Kelas Android", style: TextStyle(fontWeight: FontWeight.bold)),
                  tileColor: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/course-syllabus', extra: {'category': 'Kelas Android'});
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.apple_rounded, color: Color(0xFF555555)),
                  title: const Text("Kelas iPhone", style: TextStyle(fontWeight: FontWeight.bold)),
                  tileColor: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/course-syllabus', extra: {'category': 'Kelas iPhone'});
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        }
      );
      return;
    }

    // Masuk ke Syllabus Page (Topik)
    context.push('/course-syllabus', extra: {'category': category});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header (Bawaan Home)
          const HomeHeaderSliver(),

          // Dev Tools (Dummy Unlocker)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_hasPaid)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _allMateriCompleted = !_allMateriCompleted;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_allMateriCompleted 
                              ? "Semua materi diselesaikan. HS Terbuka!" 
                              : "Progress di-reset. HS Terkunci."),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _allMateriCompleted ? Colors.green : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        elevation: 0,
                      ),
                      icon: Icon(_allMateriCompleted ? Icons.lock_open_rounded : Icons.lock_rounded, size: 14),
                      label: Text(
                        "Dev: Lulus Semua Materi", 
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _hasPaid = !_hasPaid;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasPaid ? _primaryBlue : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      elevation: 0,
                    ),
                    icon: Icon(_hasPaid ? Icons.payment_rounded : Icons.money_off_rounded, size: 14),
                    label: Text(
                      "Dev: Status Paid", 
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Teks Judul
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PILIH PROGRAM BELAJAR",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _primaryBlue,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tentukan fokus keahlianmu dan mulai pelajari ilmu servis HP dari dasar hingga mahir.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid Menu
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate([
                _buildMainCard(
                  title: "Kelas Android",
                  subtitle: "Materi perbaikan spesifik smartphone Android.",
                  icon: Icons.android_rounded,
                  color: const Color(0xFF3DDC84),
                ),
                _buildMainCard(
                  title: "Kelas iPhone",
                  subtitle: "Materi perbaikan mendalam untuk Apple iPhone.",
                  icon: Icons.apple_rounded,
                  color: const Color(0xFF555555),
                ),
                _buildMainCard(
                  title: "Paket Bundling",
                  subtitle: "Akses super lengkap Android & iPhone sekaligus.",
                  icon: Icons.workspace_premium_rounded,
                  color: const Color(0xFFFD761A),
                ),
                _buildMainCard(
                  title: "Hardware Solution",
                  subtitle: "Dokumen rahasia (Skema, Diode, Board Layout).",
                  icon: Icons.memory_rounded,
                  color: _primaryBlue,
                  isLocked: _hasPaid && !_allMateriCompleted,
                ),
              ]),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: () => _handleCardTap(title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const Spacer(),
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
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.lock_rounded, color: Colors.grey, size: 28),
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
