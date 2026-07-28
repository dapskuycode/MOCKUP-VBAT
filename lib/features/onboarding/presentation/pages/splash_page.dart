import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _percentage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    // 25ms per percent will take 2.5 seconds to reach 100%
    _timer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (!mounted) return;
      setState(() {
        if (_percentage < 100) {
          _percentage += 1;
        } else {
          _timer?.cancel();
          context.go('/onboarding');
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/vbat_logo_shadow.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4F9B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.build_rounded,
                  color: Color(0xFF1B4F9B),
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Loading... $_percentage%",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 160,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: 160 * (_percentage / 100),
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4F9B),
                    borderRadius: BorderRadius.circular(2),
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
