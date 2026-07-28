import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'slide_satu.dart';
import 'slide_dua.dart';
import 'slide_tiga.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Color _primaryContainer = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skip() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header "Lewati"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: _currentPage == 2
                    ? const SizedBox(height: 48) // Jaga spasi saat hidden
                    : TextButton(
                        onPressed: _skip,
                        child: const Text(
                          "Lewati",
                          style: TextStyle(
                            color: Color(0xFF434751),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ),

            // PageView Area
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: const [SlideSatu(), SlideDua(), SlideTiga()],
              ),
            ),

            // Indikator dan Kontrol Bawah
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => _buildDot(index)),
                  ),
                  const SizedBox(height: 24),

                  // Animasi Perubahan Tombol
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentPage == 2
                        ? _buildFinalControls()
                        : _buildNextControl(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive ? _primaryContainer : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Tombol "Lanjut" (Tampil di Slide 1 & 2)
  Widget _buildNextControl() {
    return Align(
      alignment: Alignment.centerRight,
      key: const ValueKey('nextBtn'),
      child: ElevatedButton(
        onPressed: _goToNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 2,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Lanjut",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  // 3 Tombol Akhir (Tampil di Slide 3)
  Widget _buildFinalControls() {
    return Column(
      key: const ValueKey('finalControls'),
      children: [
        // Tombol 1: Daftar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              "Daftar Sekarang",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tombol 2: Masuk
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/login'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _primaryContainer, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Sudah Punya Akun? Masuk",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _primaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tombol 3: Lanjutkan sebagai tamu
        TextButton(
          onPressed: () => context.go('/main'),
          child: const Text(
            "Lanjutkan sebagai tamu",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF434751), // on-surface-variant
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
