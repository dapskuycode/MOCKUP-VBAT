import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventPromoCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final EdgeInsetsGeometry margin;
  final void Function(Map<String, dynamic> event)? onTap;

  const EventPromoCarousel({
    super.key,
    required this.events,
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 0),
    this.onTap,
  });

  @override
  State<EventPromoCarousel> createState() => _EventPromoCarouselState();
}

class _EventPromoCarouselState extends State<EventPromoCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant EventPromoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events.length != widget.events.length) {
      setState(() {
        _currentIndex = 0;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.events.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
        if (!mounted || !_pageController.hasClients) return;
        final next = (_currentIndex + 1) % widget.events.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleTap(Map<String, dynamic> event) {
    if (widget.onTap != null) {
      widget.onTap!(event);
    } else {
      context.push('/discount-event', extra: event);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) return const SizedBox.shrink();

    // Jika hanya 1 event, tampilkan banner tunggal statis yang rapi
    if (widget.events.length == 1) {
      return Container(
        margin: widget.margin,
        child: _buildBannerItem(widget.events.first),
      );
    }

    // Jika ≥ 2 event, tampilkan Carousel Slider otomatis (EVENT-02)
    return Container(
      margin: widget.margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 70,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.events.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildBannerItem(widget.events[index]);
              },
            ),
          ),
          const SizedBox(height: 6),
          // Dot Indicators (Indikator Titik Aktif)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.events.length,
              (idx) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                height: 4,
                width: _currentIndex == idx ? 16 : 5,
                decoration: BoxDecoration(
                  color: _currentIndex == idx
                      ? const Color(0xFFFD761A)
                      : Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(Map<String, dynamic> event) {
    final String name = event['name'] ?? 'Flash Event VBAT';
    final dynamic rawValue = event['value'];
    final String discountLabel = event['type'] == 'fixed_nominal'
        ? "POTONGAN"
        : "HEMAT ${rawValue != null ? (rawValue is num ? rawValue.round() : rawValue) : '15'}%";
    final String bannerText =
        event['banner_text'] ?? "FLASH EVENT - HEMAT SEMUA PART RESMI";

    return GestureDetector(
      onTap: () => _handleTap(event),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFD761A), Color(0xFFE05300)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFD761A).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          discountLabel,
                          style: const TextStyle(
                            color: Color(0xFFFD761A),
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bannerText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
