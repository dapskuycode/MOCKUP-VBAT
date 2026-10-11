import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';
import 'package:vbat_ponsel/core/widgets/video_preview_widget.dart';
import 'package:vbat_ponsel/core/widgets/skeleton_loading.dart';
import 'package:vbat_ponsel/core/widgets/sponsor_tier_badge.dart';
import 'package:vbat_ponsel/core/utils/sponsor_tier_store.dart';

class HorizontalSponsorSlider extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final EdgeInsetsGeometry margin;
  final double aspectRatio;
  final double borderRadius;
  final bool isLoading;

  const HorizontalSponsorSlider({
    super.key,
    required this.banners,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.aspectRatio = 2.7, // Standar rasio horizontal slider beranda (ala Tokopedia)
    this.borderRadius = 12.0,
    this.isLoading = false,
  });

  @override
  State<HorizontalSponsorSlider> createState() =>
      _HorizontalSponsorSliderState();
}

class _HorizontalSponsorSliderState extends State<HorizontalSponsorSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(covariant HorizontalSponsorSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners != widget.banners ||
        oldWidget.banners.length != widget.banners.length) {
      setState(() {
        _currentIndex = 0;
      });
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || !_pageController.hasClients) return;
        final nextIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
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

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.banners.isEmpty) {
      return HorizontalBannerSkeleton(
        aspectRatio: widget.aspectRatio,
        margin: widget.margin,
      );
    }
    if (widget.banners.isEmpty) return const SizedBox.shrink();
    final items = widget.banners;

    return Container(
      margin: widget.margin,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, sIndex) {
                    final banner = items[sIndex];
                    final String tier = (banner['tier'] ?? 'PARTNER').toString().toUpperCase();

                    final String imgPath = (banner['image'] ?? banner['media_path'] ?? '').toString();
                    final String mediaType = (banner['media_type'] ?? 'image').toString();
                    final bool isVideo = mediaType == 'video' ||
                        imgPath.endsWith('.mp4') ||
                        imgPath.endsWith('.webm') ||
                        imgPath.endsWith('.mov');

                    Widget mediaWidget;
                    if (isVideo) {
                      mediaWidget = VideoPreviewWidget(
                        videoUrl: imgPath,
                        fallbackImage: 'assets/images/banner_braderparts.png',
                      );
                    } else if (imgPath.startsWith('http')) {
                      mediaWidget = Image.network(
                        imgPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1B4F9B), Color(0xFF0D284F)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 36),
                          ),
                        ),
                      );
                    } else {
                      mediaWidget = Image.asset(
                        imgPath.isNotEmpty ? imgPath : 'assets/images/banner_braderparts.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1B4F9B), Color(0xFF0D284F)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 36),
                          ),
                        ),
                      );
                    }

                    final String targetUrl = (banner['link'] ?? banner['target_url'] ?? 'https://shopee.co.id').toString();
                    final String sponsorName = (banner['sponsor'] ?? banner['sponsor_name'] ?? 'Sponsor Vbat').toString();
                    final String title = (banner['title'] ?? '').toString();

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        WishlistHelper.showMarketplaceSheet(
                          context,
                          "$sponsorName: $title",
                          targetUrl,
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          mediaWidget,

                          // Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.5),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),

                          // Tier Badge at Top Left (APP-02)
                          Positioned(
                            top: 10,
                            left: 12,
                            child: SponsorTierBadge(
                              rawTier: tier,
                              isSolid: true,
                              fontSize: 10,
                              iconSize: 12,
                              // Ikon dan warna dari server bila Admin sudah
                              // mengunggahnya (halaman ini tidak perlu diubah).
                              iconSource: SponsorTierStore.iconFor(tier),
                            ),
                          ),

                          // Slide Counter at Top Right
                          Positioned(
                            top: 10,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${sIndex + 1}/${items.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Title and Sponsor name at Bottom Left
                          Positioned(
                            bottom: 10,
                            left: 12,
                            right: 105,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  sponsorName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Button "Kunjungi" at Bottom Right
                          Positioned(
                            bottom: 10,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    "Kunjungi",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B4F9B),
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    size: 11,
                                    color: Color(0xFF1B4F9B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Slide dots indicator at bottom center if multiple
                if (items.length > 1)
                  Positioned(
                    bottom: 3,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(items.length, (idx) {
                        final bool isActive = idx == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: isActive ? 12 : 4,
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
