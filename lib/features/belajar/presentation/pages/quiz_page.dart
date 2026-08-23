import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);

  int? _selectedAnswerIndex;
  bool _hasSubmitted = false;

  final List<String> _options = [
    "A. Membersihkan konektor dengan alkohol",
    "B. Mengganti layar secara paksa tanpa pemanas",
    "C. Memanaskan layar dengan separator suhu 80°C",
    "D. Menekan layar dengan obeng"
  ];

  final int _correctIndex = 2; // Jawaban benar C

  void _submitAnswer() {
    if (_selectedAnswerIndex == null) return;
    
    setState(() {
      _hasSubmitted = true;
    });

    if (_selectedAnswerIndex == _correctIndex) {
      // Benar
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text("Jawaban Benar!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Luar biasa. Anda telah memahami materi ini.", textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    context.pop(true); // Kembali ke course detail dengan status success
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Lanjutkan Materi"),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Salah
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_rounded, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text("Jawaban Salah!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Tinjau kembali materi video sebelum menjawab kuis ini.", textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _hasSubmitted = false;
                      _selectedAnswerIndex = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Coba Lagi"),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87),
          onPressed: () => context.pop(false),
        ),
        title: const Text(
          "Kuis Evaluasi",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, size: 14, color: Colors.orange.shade800),
                    const SizedBox(width: 4),
                    Text(
                      "Wajib diselesaikan",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Pertanyaan 1 dari 1",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 8),
              const Text(
                "Langkah paling tepat sebelum memisahkan layar (LCD/OLED) dari bingkai (bezel) pada ponsel modern adalah?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001944),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              
              // Options
              ...List.generate(_options.length, (index) {
                bool isSelected = _selectedAnswerIndex == index;
                
                return GestureDetector(
                  onTap: _hasSubmitted ? null : () {
                    setState(() {
                      _selectedAnswerIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? _primaryBlue.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? _primaryBlue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? _primaryBlue : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected 
                            ? Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(color: _primaryBlue, shape: BoxShape.circle))) 
                            : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _options[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? _primaryBlue : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _selectedAnswerIndex == null ? null : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "SUBMIT JAWABAN",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
