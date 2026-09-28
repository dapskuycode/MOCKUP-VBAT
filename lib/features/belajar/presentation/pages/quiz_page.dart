import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';

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

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade300;

  int _currentIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 600; // 10 menit
  bool _isFinished = false;

  final TextEditingController _textAnswerController = TextEditingController();

  final List<Question> _questions = [
    Question(
      questionText:
          "Langkah paling tepat sebelum memisahkan layar (LCD/OLED) dari bingkai (bezel) pada ponsel modern adalah?",
      type: QuestionType.multipleChoice,
      options: [
        "A. Membersihkan konektor dengan alkohol",
        "B. Mengganti layar secara paksa tanpa pemanas",
        "C. Memanaskan layar dengan separator suhu 80°C",
        "D. Menekan layar dengan obeng",
      ],
      correctIndex: 2,
    ),
    Question(
      questionText:
          "Alat yang berfungsi mengukur tegangan, arus, dan hambatan pada komponen motherboard adalah?",
      type: QuestionType.multipleChoice,
      options: [
        "A. Solder uap (Blower)",
        "B. Multimeter",
        "C. Osiloskop",
        "D. Pinset presisi",
      ],
      correctIndex: 1,
    ),
    Question(
      questionText:
          "Standar Keselamatan (K3) mewajibkan penggunaan gelang anti-statis. Apa fungsinya?",
      type: QuestionType.multipleChoice,
      options: [
        "A. Melindungi tangan dari panas solder",
        "B. Mencegah kerusakan IC akibat listrik statis dari tubuh",
        "C. Meningkatkan penerimaan sinyal WiFi saat servis",
        "D. Mencegah tersengat listrik tegangan tinggi",
      ],
      correctIndex: 1,
    ),
    Question(
      questionText:
          "Jika ponsel mati total dan terdeteksi korsleting pada jalur VPH_PWR, langkah analisis awal adalah?",
      type: QuestionType.multipleChoice,
      options: [
        "A. Langsung mengganti IC Power",
        "B. Mengangkat CPU dan RAM",
        "C. Melakukan injeksi tegangan (MBR) untuk mencari komponen panas",
        "D. Mereset pabrik perangkat (Hard Reset)",
      ],
      correctIndex: 2,
    ),
    Question(
      questionText:
          "Suhu ideal solder uap (blower) saat mengangkat IC eMMC agar tidak merusak komponen sekitarnya biasanya berkisar antara?",
      type: QuestionType.multipleChoice,
      options: [
        "A. 150°C - 200°C",
        "B. 330°C - 380°C",
        "C. 450°C - 500°C",
        "D. 100°C - 150°C",
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
        "D. Kebersihan, Keamanan, dan Kerapian",
      ],
      correctIndex: 2,
    ),
    Question(
      questionText:
          "Sebutkan nama cairan pelarut fluks dan sisa kotoran sisa solder yang paling umum digunakan teknisi ponsel saat membersihkan motherboard!",
      type: QuestionType.shortAnswer,
      placeholder: "Masukkan nama cairan (misal: Alkohol, Tiner, IPA)...",
      keywords: ["alkohol", "tiner", "ipa", "thinner", "isopropyl"],
    ),
    Question(
      questionText:
          "Alat pemanas utama yang digunakan untuk melelehkan timah pada kaki komponen IC saat melakukan pencabutan (desoldering) atau reballing adalah?",
      type: QuestionType.shortAnswer,
      placeholder: "Masukkan nama alat (misal: Solder, Blower)...",
      keywords: ["blower", "solder uap", "hot air", "hotair"],
    ),
    Question(
      questionText:
          "[Studi Kasus] Sebuah ponsel mengalami korsleting kecil (leakage/arus bocor) setelah terkena air, sehingga baterai cepat habis. Jelaskan langkah pembersihan awal menggunakan cairan pembersih dan alat bantu pengering sebelum melakukan pengukuran multimeter!",
      type: QuestionType.caseStudy,
      placeholder: "Jelaskan langkah-langkah pembersihan secara lengkap...",
      keywords: [
        "sikat",
        "alkohol",
        "tiner",
        "ipa",
        "keringkan",
        "blower",
        "bersihkan",
      ],
    ),
    Question(
      questionText:
          "[Studi Kasus] Sebuah HP masuk dengan keluhan layar pecah setelah terjatuh, namun mesin masih bergetar saat dinyalakan. Jelaskan langkah-langkah pembongkaran casing belakang dan pelepasan soket baterai yang aman sesuai prosedur keselamatan K3!",
      type: QuestionType.caseStudy,
      placeholder:
          "Jelaskan urutan pembongkaran dan penanganan soket baterai...",
      keywords: [
        "pemanas",
        "soket",
        "baterai",
        "lepas",
        "plastik",
        "backdoor",
        "casing",
      ],
    ),
  ];

  late List<dynamic> _userAnswers;
  late List<bool> _isDoubtful;

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    _userAnswers = List.filled(_questions.length, null);
    _isDoubtful = List.filled(_questions.length, false);
    _startTimer();
    _updateTextController();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
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
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    _timer?.cancel();
    _textAnswerController.dispose();
    super.dispose();
  }

  void _updateTextController() {
    final currentQ = _questions[_currentIndex];
    if (currentQ.type == QuestionType.shortAnswer ||
        currentQ.type == QuestionType.caseStudy) {
      _textAnswerController.text =
          (_userAnswers[_currentIndex] as String?) ?? '';
    }
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _saveCurrentTextAnswer() {
    final currentQ = _questions[_currentIndex];
    if (currentQ.type == QuestionType.shortAnswer ||
        currentQ.type == QuestionType.caseStudy) {
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
          int matches = q.keywords!
              .where((keyword) => cleanAns.contains(keyword))
              .length;
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
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _borderColor),
        ),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Skor Anda: ${(score / _questions.length * 100).toInt()}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isPassed ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Cocok: $score / 10 Soal",
                style: TextStyle(fontSize: 14, color: _textGray),
              ),
              Divider(height: 24, color: _borderColor),
              Text(
                isPassed
                    ? "Selamat! Anda berhak melanjutkan ke materi berikutnya."
                    : "Anda harus mendapatkan skor minimal 70 untuk lulus. Silakan ulangi materi dan coba lagi.",
                textAlign: TextAlign.center,
                style: TextStyle(color: _textDark),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPassed ? Colors.green : Colors.red,
                  ),
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
        backgroundColor: _cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: _textDark),
          onPressed: () => context.pop(false),
        ),
        title: Text(
          "Kuis Evaluasi",
          style: TextStyle(
            color: _textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _remainingSeconds < 60
                      ? (_isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50)
                      : (_isDark ? Colors.orange.shade900.withValues(alpha: 0.3) : Colors.orange.shade50),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: _remainingSeconds < 60
                          ? (_isDark ? Colors.red.shade300 : Colors.red.shade700)
                          : (_isDark ? Colors.orange.shade300 : Colors.orange.shade800),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _remainingSeconds < 60
                            ? (_isDark ? Colors.red.shade300 : Colors.red.shade700)
                            : (_isDark ? Colors.orange.shade300 : Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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

                    Color bgColor = _cardColor;
                    Color borderColor = _borderColor;
                    Color textColor = _textDark;

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
                        setState(() {
                          _currentIndex = index;
                        });
                        _updateTextController();
                      },
                      child: Container(
                        width: 48,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent ? (_isDark ? const Color(0xFF60A5FA) : Colors.black87) : borderColor,
                            width: isCurrent ? 2.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
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
                          bool isSelected =
                              _userAnswers[_currentIndex] == index;
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
                                color: isSelected
                                    ? (_isDark
                                        ? const Color(0xFF60A5FA).withValues(alpha: 0.15)
                                        : _primaryBlue.withValues(alpha: 0.05))
                                    : _cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? (_isDark ? const Color(0xFF60A5FA) : _primaryBlue)
                                      : _borderColor,
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
                                        color: isSelected
                                            ? (_isDark ? const Color(0xFF60A5FA) : _primaryBlue)
                                            : _borderColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      currentQ.options![index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? (_isDark ? const Color(0xFF60A5FA) : _primaryBlue)
                                            : _textDark,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _isDark
                                    ? const Color(0xFF60A5FA).withValues(alpha: 0.15)
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentQ.type == QuestionType.shortAnswer
                                    ? "Jenis: JAWABAN SINGKAT"
                                    : "Jenis: STUDI KASUS",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _isDark ? const Color(0xFF60A5FA) : Colors.blue.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _textAnswerController,
                              style: TextStyle(color: _textDark),
                              maxLines: currentQ.type == QuestionType.caseStudy
                                  ? 6
                                  : 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _borderColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _borderColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                                    width: 2,
                                  ),
                                ),
                                fillColor: _cardColor,
                                filled: true,
                                hintText: currentQ.placeholder,
                                hintStyle: TextStyle(color: _textGray),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              onChanged: (val) {
                                // Save locally
                                _userAnswers[_currentIndex] = val.trim().isEmpty
                                    ? null
                                    : val.trim();
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text(
                    "Ragu-ragu",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Dijawab: ${_userAnswers.where((e) => e != null).length}/${_questions.length}",
                    style: TextStyle(color: _textGray, fontSize: 13),
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
                          side: BorderSide(
                            color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "SEBELUMNYA",
                          style: TextStyle(
                            color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
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
                                backgroundColor: _cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: _borderColor),
                                ),
                                title: Text(
                                  "Peringatan",
                                  style: TextStyle(color: _textDark, fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                  "Masih ada pertanyaan yang belum dijawab. Yakin ingin mengumpulkan?",
                                  style: TextStyle(color: _textDark),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(
                                      "Batal",
                                      style: TextStyle(color: _textGray),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _submitQuiz();
                                    },
                                    child: Text(
                                      "Kumpulkan",
                                      style: TextStyle(
                                        color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                        _currentIndex == _questions.length - 1
                            ? "KUMPULKAN"
                            : "SELANJUTNYA",
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
