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
  final Color _textDark = const Color(0xFF001944);
  
  int _currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: _primaryBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Kuis & Evaluasi",
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / 3,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pertanyaan ${_currentQuestionIndex + 1} dari 3",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            if (_currentQuestionIndex == 0) _buildMultipleChoice(),
            if (_currentQuestionIndex == 1) _buildShortAnswer(),
            if (_currentQuestionIndex == 2) _buildCaseStudy(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            if (_currentQuestionIndex < 2) {
              setState(() {
                _currentQuestionIndex++;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Kuis Selesai! Mengembalikan hasil..."))
              );
              Future.delayed(const Duration(seconds: 1), () => context.pop());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _currentQuestionIndex == 2 ? "Selesaikan Kuis" : "Selanjutnya",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Apa fungsi utama dari jalur VCC_MAIN pada mesin iPhone?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark, height: 1.4),
        ),
        const SizedBox(height: 24),
        _buildRadioOption("Mengatur tegangan layar LCD"),
        _buildRadioOption("Mendistribusikan tegangan utama baterai ke seluruh komponen"),
        _buildRadioOption("Sebagai jalur komunikasi data USB"),
        _buildRadioOption("Hanya digunakan untuk modul kamera"),
      ],
    );
  }

  Widget _buildRadioOption(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: RadioListTile(
        value: text,
        groupValue: null,
        onChanged: (val) {},
        title: Text(text, style: const TextStyle(fontSize: 14)),
        activeColor: _primaryBlue,
      ),
    );
  }

  Widget _buildShortAnswer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sebutkan satu komponen ic yang paling sering mengalami short saat tegangan VCC_MAIN bermasalah (Jawaban Singkat).",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark, height: 1.4),
        ),
        const SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            hintText: "Ketik jawaban Anda di sini...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCaseStudy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Studi Kasus: Sebuah iPhone 13 mati total. Saat diukur, tegangan pada VCC_MAIN menunjukkan angka 0 Volt. Langkah apa yang pertama kali harus Anda lakukan untuk melacak short pada board?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark, height: 1.4),
        ),
        const SizedBox(height: 24),
        TextField(
          maxLines: 6,
          decoration: InputDecoration(
            hintText: "Uraikan langkah analisis dan perbaikan Anda secara detail...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
