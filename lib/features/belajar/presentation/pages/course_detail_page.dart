import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseDetailPage extends StatefulWidget {
  final String module;
  final String category;

  const CourseDetailPage({super.key, required this.module, required this.category});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _greenSuccess = const Color(0xFF22C55E);

  // State untuk melacak video mana yang sudah selesai ditonton
  // 0: Belum ada yang selesai (Hanya item index 0 yang bisa dibuka)
  int _completedStep = 0;

  final List<Map<String, dynamic>> _playlist = [
    {"type": "video", "title": "1. Pengenalan Alat Dasar", "duration": "12:45"},
    {"type": "video", "title": "2. Standar Keselamatan (K3)", "duration": "08:20"},
    {"type": "video", "title": "3. Penggunaan Multimeter", "duration": "15:30"},
    {"type": "quiz", "title": "Kuis: Alat & Keselamatan"},
    {"type": "video", "title": "4. Memahami Skema Dasar", "duration": "20:15"},
    {"type": "video", "title": "5. Praktek Pembacaan Skema", "duration": "18:40"},
    {"type": "quiz", "title": "Kuis: Evaluasi Akhir Modul"},
  ];

  void _handleItemTap(int index, Map<String, dynamic> item) async {
    bool isLocked = index > _completedStep;
    
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Terkunci! Selesaikan materi sebelumnya terlebih dahulu."),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (item['type'] == 'video') {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        final result = await context.push<bool>('/video-player', extra: {
          'title': item['title'],
          'playlist': _playlist,
          'currentIndex': index,
        });
        if (result == true && index == _completedStep) {
          setState(() {
            _completedStep++;
          });
        }
      }
    } else if (item['type'] == 'quiz') {
      final result = await context.push<bool>('/quiz');
      if (result == true && index == _completedStep) {
        setState(() {
          _completedStep++;
        });
        
        if (_completedStep >= _playlist.length) {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Selamat!"),
              content: const Text("Anda telah menyelesaikan seluruh materi pada modul ini."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop(); // Kembali ke silabus
                  },
                  child: const Text("Tutup"),
                )
              ],
            )
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              widget.category,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              widget.module,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_rounded, color: Colors.white70),
            tooltip: 'Dev Mode: Buka Semua Materi',
            onPressed: () {
              setState(() {
                _completedStep = _playlist.length;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Dev Mode: Semua materi telah dibuka."),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Progress
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress Belajar",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      "${(_completedStep / _playlist.length * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _playlist.isEmpty ? 0 : _completedStep / _playlist.length,
                  backgroundColor: Colors.grey.shade200,
                  color: _primaryBlue,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: _playlist.length,
              itemBuilder: (context, index) {
                final item = _playlist[index];
                final isLocked = index > _completedStep;
                final isCompleted = index < _completedStep;
                final isCurrent = index == _completedStep;

                if (item['type'] == 'quiz') {
                  return _buildQuizItem(index, item['title'], isLocked: isLocked, isCompleted: isCompleted, isCurrent: isCurrent);
                } else {
                  return _buildVideoItem(index, item['title'], item['duration'], isLocked: isLocked, isCompleted: isCompleted, isCurrent: isCurrent);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(int index, String title, String duration, {required bool isLocked, required bool isCompleted, required bool isCurrent}) {
    return GestureDetector(
      onTap: () => _handleItemTap(index, _playlist[index]),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade50 : (isCompleted ? _greenSuccess.withValues(alpha: 0.03) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrent 
              ? _primaryBlue 
              : (isLocked ? Colors.grey.shade200 : (isCompleted ? _greenSuccess.withValues(alpha: 0.3) : Colors.grey.shade200)),
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: [
            if (!isLocked)
              BoxShadow(
                color: isCurrent ? _primaryBlue.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      "https://img.youtube.com/vi/drcMv73jEGE/mqdefault.jpg",
                      width: 100,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                    if (isLocked || isCompleted)
                      Container(
                        width: 100,
                        height: 64,
                        color: isLocked ? Colors.white.withValues(alpha: 0.7) : _greenSuccess.withValues(alpha: 0.5),
                      ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.grey.shade400
                            : (isCompleted ? _greenSuccess : _primaryBlue),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(
                        isLocked ? Icons.lock_rounded : (isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey.shade400 : _textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isLocked ? "Selesaikan materi sebelumnya" : (isCompleted ? "Selesai ditonton" : "Siap ditonton"),
                      style: TextStyle(
                        fontSize: 13,
                        color: isLocked ? Colors.grey.shade400 : (isCompleted ? _greenSuccess : Colors.black54),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: isLocked ? Colors.grey.shade400 : Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLocked ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFD761A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Tonton",
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

  Widget _buildQuizItem(int index, String title, {required bool isLocked, required bool isCompleted, required bool isCurrent}) {
    return GestureDetector(
      onTap: () => _handleItemTap(index, _playlist[index]),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade50 : (isCompleted ? _greenSuccess.withValues(alpha: 0.03) : Colors.orange.shade50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrent 
              ? Colors.orange.shade500 
              : (isLocked ? Colors.grey.shade200 : (isCompleted ? _greenSuccess.withValues(alpha: 0.3) : Colors.orange.shade200)),
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: [
            if (!isLocked)
              BoxShadow(
                color: isCurrent ? Colors.orange.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      "https://img.freepik.com/free-vector/quiz-word-concept_23-2147844150.jpg",
                      width: 100,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                    if (isLocked || isCompleted)
                      Container(
                        width: 100,
                        height: 64,
                        color: isLocked ? Colors.white.withValues(alpha: 0.7) : _greenSuccess.withValues(alpha: 0.5),
                      ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.grey.shade400
                            : (isCompleted ? _greenSuccess : Colors.orange),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(
                        isLocked ? Icons.lock_rounded : (isCompleted ? Icons.check_rounded : Icons.assignment_rounded),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey.shade400 : (isCompleted ? _greenSuccess : Colors.orange.shade900),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isLocked ? "Syarat untuk lanjut" : (isCompleted ? "Lulus kuis" : "Evaluasi pemahaman Anda"),
                      style: TextStyle(
                        fontSize: 13,
                        color: isLocked ? Colors.grey.shade400 : (isCompleted ? _greenSuccess : Colors.orange.shade800),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.timer_rounded, size: 14, color: isLocked ? Colors.grey.shade400 : Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          "Mandatori",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLocked ? Colors.grey.shade400 : Colors.orange.shade800,
                          ),
                        ),
                        const Spacer(),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Mulai Kuis",
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
