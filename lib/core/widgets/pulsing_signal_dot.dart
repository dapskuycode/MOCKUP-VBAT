import 'package:flutter/material.dart';

/// Titik kuning dengan efek memancar seperti "sinyal" / radar beacon
class PulsingSignalDot extends StatefulWidget {
  final double size;
  final Color dotColor;
  final Color pulseColor;

  const PulsingSignalDot({
    super.key,
    this.size = 9.0,
    this.dotColor = const Color(0xFFFBBF24), // Amber / Kuning menyala
    this.pulseColor = const Color(0xFFF59E0B),
  });

  @override
  State<PulsingSignalDot> createState() => _PulsingSignalDotState();
}

class _PulsingSignalDotState extends State<PulsingSignalDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 2.8,
          height: widget.size * 2.8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gelombang sinyal luar 2
              Transform.scale(
                scale: 1.0 + (_controller.value * 1.6),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.pulseColor.withValues(
                      alpha: (1.0 - _controller.value) * 0.45,
                    ),
                  ),
                ),
              ),
              // Gelombang sinyal luar 1
              Transform.scale(
                scale: 1.0 + (_controller.value * 0.9),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.pulseColor.withValues(
                      alpha: (1.0 - _controller.value) * 0.7,
                    ),
                  ),
                ),
              ),
              // Titik inti kuning bercahaya
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.dotColor,
                  border: Border.all(color: Colors.white, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: widget.pulseColor.withValues(alpha: 0.8),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
