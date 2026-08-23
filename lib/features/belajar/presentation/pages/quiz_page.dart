import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum QuestionType { multipleChoice, shortAnswer, caseStudy }

class Question {
  final String questionText;
  final QuestionType type;
  
  // Pilihan Ganda
  final List<String>? options;
  final int? correctIndex;

  // Jawaban Singkat & Studi Kasus
  final List<String>? keywords;
  final String? placeholder;

  Question({
    required this.questionText,
    required this.type,
    this.options,
    this.correctIndex,
    this.keywords,
    this.placeholder,
  });
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);

  int _currentIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 600; // 10 menit
  bool _isFinished = false;

  final TextEditingController _textAnswerController = TextEditingController();

  final List<Question> _questions = [
    Question(
      questionText: "Langkah paling tepat sebelum memisahkan layar (LCD/OLED) dari bingkai (bezel) pada ponsel modern adalah?",
      type: QuestionType.multipleChoice,
      options: [
        "A. Membersihkan konektor dengan alkohol",
        "B. Mengganti layar secara paksa tanpa pemanas",
        "C. Memanaskan layar dengan separator suhu 80°C",
        "D. Menekan layar dengan obeng"
      ],
      correctIndex: 2,
    ),
    Question(
      questionText: "Alat yang berfungsi mengukur tegangan, arus, dan hambatan pada komponen motherboard adalah?",
      type: QuestionType.multipleChoice,
      options: [
        "A. Solder uap (Blower)",
        "B. Multimeter",
        "C. Osiloskop",
        "D. Pinset presisi"
      ],
      correctIndex: 1,
    ),
    Question(
      questionText: "Standar Keselamatan (K3) mewajibkan penggunaan gelang anti-statis. Apa fungsinya?",
      type: QuestionType.multipleChoice,
      options: [
        "A. Melindungi tangan dari panas solder",
        "B. Mencegah kerusakan IC akibat listrik statis dari tubuh",
        "C. Meningkatkan penerimaan sinyal WiFi saat servis",
        "D. Mencegah tersengat listrik tegangan tinggi"
      ],
      correctIndex: 1,
    ),
    Question(
      questionText: "Jika ponsel mati total dan terdeteksi korsleting pada jalur VPH_PWR, langkah analisis awal adalah?",
      type: QuestionType.multipleChoice,
      options: [
        "A. Langsung mengganti IC Power",
        "B. Mengangkat CPU dan RAM",
        "C. Melakukan injeksi tegangan (MBR) untuk mencari komponen panas",
        "D. Mereset pabrik perangkat (Hard Reset)"
      ],
      correctIndex: 2,
    ),
    Question(
      questionText: "Suhu ideal solder uap (blower) saat mengangkat IC eMMC agar tidak merusak komponen sekitarnya biasanya berkisar antara?",
      type: QuestionType.multipleChoice,
      options: [
        "A. 150°C - 200°C",
        "B. 330°C - 380°C",
        "C. 450°C - 500°C",
        "D. 100°C - 150°C"
      ],
      correctIndex: 1,
    ),
    Question(
      questionText: "Apa kepanjangan dari K3 dalam konteks pekerjaan teknisi?",
      type: QuestionType.multipleChoice,
      options: [
        "A. Keselamatan, Kesehatan, dan Kesejahteraan",
        "B. Keamanan, Keselamatan, dan Ketelitian Kerja",
        "C. Keselamatan dan Kesehatan Kerja",
        "D. Kebersihan, Keamanan, dan Kerapian"
      ],
      correctIndex: 2,
    ),
    Question(
      questionText: "Sebutkan nama cairan pelarut fluks dan sisa kotoran sisa solder yang paling umum digunakan teknisi ponsel saat membersihkan motherboard!",
      type: QuestionType.shortAnswer,
      placeholder: "Masukkan nama cairan (misal: Alkohol, Tiner, IPA)...",
      keywords: ["alkohol", "tiner", "ipa", "thinner", "isopropyl"],
    ),
    Question(
      questionText: "Alat pemanas utama yang digunakan untuk melelehkan timah pada kaki komponen IC saat melakukan pencabutan (desoldering) atau reballing adalah?",
      type: QuestionType.shortAnswer,
      placeholder: "Masukkan nama alat (misal: Solder, Blower)...",
      keywords: ["blower", "solder uap", "hot air", "hotair"],
    ),
    Question(
      questionText: "[Studi Kasus] Sebuah ponsel mengalami korsleting kecil (leakage/arus bocor) setelah terkena air, sehingga baterai cepat habis. Jelaskan langkah pembersihan awal menggunakan cairan pembersih dan alat bantu pengering sebelum melakukan pengukuran multimeter!",
      type: QuestionType.caseStudy,
      placeholder: "Jelaskan langkah-langkah pembersihan secara lengkap...",
      keywords: ["sikat", "alkohol", "tiner", "ipa", "keringkan", "blower", "bersihkan"],
    ),
    Question(
      questionText: "[Studi Kasus] Sebuah HP masuk dengan keluhan layar pecah setelah terjatuh, namun mesin masih bergetar saat dinyalakan. Jelaskan langkah-langkah pembongkaran casing belakang dan pelepasan soket baterai yang aman sesuai prosedur keselamatan K3!",
      type: QuestionType.caseStudy,
      placeholder: "Jelaskan urutan pembongkaran dan penanganan soket baterai...",
      keywords: ["pemanas", "soket", "baterai", "lepas", "plastik", "backdoor", "casing"],
    ),
  ];

  late List<dynamic> _userAnswers;
  late List<bool> _isDoubtful;

  @override
  void initState() {
    super.initState();
    _userAnswers = List.filled(_questions.length, null);
    _isDoubtful = List.filled(_questions.length, false);
    _startTimer();
    _updateTextController();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textAnswerController.dispose();
    super.dispose();
  }

  void _updateTextController() {
    final currentQ = _questions[_currentIndex];
    if (currentQ.type == QuestionType.shortAnswer || currentQ.type == QuestionType.caseStudy) {
      _textAnswerController.text = (_userAnswers[_currentIndex] as String?) ?? '';
    }
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _saveCurrentTextAnswer() {
    final currentQ = _questions[_currentIndex];
    if (currentQ.type == QuestionType.shortAnswer || currentQ.type == QuestionType.caseStudy) {
      final val = _textAnswerController.text.trim();
      _userAnswers[_currentIndex] = val.isEmpty ? null : val;
    }
  }

  void _nextQuestion() {
    _saveCurrentTextAnswer();
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _updateTextController();
    } else {
      _submitQuiz();
    }
  }

  void _prevQuestion() {
    _saveCurrentTextAnswer();
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _updateTextController();
    }
  }

  void _submitQuiz() {
    _saveCurrentTextAnswer();
    if (_isFinished) return;
    
    setState(() {
      _isFinished = true;
    });
    _timer?.cancel();

    int score = 0;
    List<Map<String, dynamic>> resultsSummary = [];

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final ans = _userAnswers[i];
      bool isCorrect = false;

      if (q.type == QuestionType.multipleChoice) {
        isCorrect = ans == q.correctIndex;
      } else if (q.type == QuestionType.shortAnswer) {
        if (ans != null && ans is String) {
          final cleanAns = ans.toLowerCase();
          isCorrect = q.keywords!.any((keyword) => cleanAns.contains(keyword));
        }
      } else if (q.type == QuestionType.caseStudy) {
        if (ans != null && ans is String) {
          final cleanAns = ans.toLowerCase();
          // Evaluasi teks menggunakan mekanisme pencocokan kata kunci (keyword matching).
          // Untuk studi kasus, setidaknya 2 keyword harus cocok agar dinilai benar
          int matches = q.keywords!.where((keyword) => cleanAns.contains(keyword)).length;
          isCorrect = matches >= 2;
        }
      }

      if (isCorrect) {
        score++;
      }

      resultsSummary.add({
        "question": q.questionText,
        "type": q.type.name,
        "isCorrect": isCorrect,
        "userAnswer": ans,
      });
    }

    bool isPassed = score >= 7; // Minimal 70% lulus

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isPassed ? Colors.green : Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                isPassed ? "Kuis Lulus!" : "Kuis Gagal",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Skor Anda: ${(score / _questions.length * 100).toInt()}",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: isPassed ? Colors.green : Colors.red
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Cocok: $score / 10 Soal",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Divider(height: 24),
              Text(
                isPassed 
                  ? "Selamat! Anda berhak melanjutkan ke materi berikutnya." 
                  : "Anda harus mendapatkan skor minimal 70 untuk lulus. Silakan ulangi materi dan coba lagi.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    if (isPassed) {
                      context.pop(true);
                    } else {
                      context.pop(false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: isPassed ? Colors.green : Colors.red),
                  child: Text(isPassed ? "Selesai" : "Tutup"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Question currentQ = _questions[_currentIndex];

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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _remainingSeconds < 60 ? Colors.red.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined, 
                      size: 16, 
                      color: _remainingSeconds < 60 ? Colors.red.shade700 : Colors.orange.shade800
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _remainingSeconds < 60 ? Colors.red.shade700 : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grid Nomor Pertanyaan
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    bool isAnswered = _userAnswers[index] != null;
                    bool isDoubtful = _isDoubtful[index];
                    bool isCurrent = _currentIndex == index;

                    Color bgColor = Colors.white;
                    Color borderColor = Colors.grey.shade300;
                    Color textColor = Colors.black87;

                    if (isDoubtful) {
                      bgColor = Colors.orange;
                      borderColor = Colors.orange;
                      textColor = Colors.white;
                    } else if (isAnswered) {
                      bgColor = _primaryBlue;
                      borderColor = _primaryBlue;
                      textColor = Colors.white;
                    }

                    return GestureDetector(
                      onTap: () {
                        _saveCurrentTextAnswer();
                        setState(() { _currentIndex = index; });
                        _updateTextController();
                      },
                      child: Container(
                        width: 48,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent ? Colors.black87 : borderColor,
                            width: isCurrent ? 2.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                currentQ.questionText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001944),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              
              // RENDER QUESTION BASE ON TYPE
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (currentQ.type == QuestionType.multipleChoice) {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: currentQ.options!.length,
                        itemBuilder: (context, index) {
                          bool isSelected = _userAnswers[_currentIndex] == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _userAnswers[_currentIndex] = index;
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
                                      currentQ.options![index],
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
                        },
                      );
                    } else {
                      // Short Answer or Case Study
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentQ.type == QuestionType.shortAnswer ? "Jenis: JAWABAN SINGKAT" : "Jenis: STUDI KASUS",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _textAnswerController,
                              maxLines: currentQ.type == QuestionType.caseStudy ? 6 : 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: _primaryBlue, width: 2),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                hintText: currentQ.placeholder,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              onChanged: (val) {
                                // Save locally
                                _userAnswers[_currentIndex] = val.trim().isEmpty ? null : val.trim();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _isDoubtful[_currentIndex],
                    onChanged: (val) {
                      setState(() {
                        _isDoubtful[_currentIndex] = val ?? false;
                      });
                    },
                    activeColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  const Text(
                    "Ragu-ragu",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    "Dijawab: ${_userAnswers.where((e) => e != null).length}/${_questions.length}",
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_currentIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevQuestion,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: _primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "SEBELUMNYA",
                          style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (_currentIndex > 0) const SizedBox(width: 16),
                  
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentIndex == _questions.length - 1) {
                          if (_userAnswers.contains(null)) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Peringatan"),
                                content: const Text("Masih ada pertanyaan yang belum dijawab. Yakin ingin mengumpulkan?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _submitQuiz();
                                    }, 
                                    child: const Text("Kumpulkan")
                                  ),
                                ],
                              )
                            );
                          } else {
                            _submitQuiz();
                          }
                        } else {
                          _nextQuestion();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentIndex == _questions.length - 1 ? "KUMPULKAN" : "SELANJUTNYA",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
