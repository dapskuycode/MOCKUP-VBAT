import 'package:flutter/material.dart';

class SlideTiga extends StatelessWidget {
  const SlideTiga({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/onboarding3.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "Bergabung dengan Komunitas Teknisi",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D2B5E),
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Diskusi kasus kerusakan, berbagi tips, dan bangun jaringan profesional di forum teknisi terbesar.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF434751),
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}
