import 'package:flutter/material.dart';

/// Komponen dasar Shimmer Effect yang menghasilkan animasi sapuan cahaya
/// berulang (shimmer sweep) secara halus tanpa membutuhkan library eksternal.
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double slidePercent = _controller.value;
            final double left = -bounds.width + (slidePercent * bounds.width * 2);

            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: left / bounds.width),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Kotak Skeleton berbentuk persegi/rounded
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.margin,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
    );
  }
}

/// Skeleton Lingkaran (untuk Avatar atau Logo Sponsor)
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({
    super.key,
    required this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      shape: BoxShape.circle,
      margin: margin,
    );
  }
}

/// Skeleton Baris Teks
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonText({
    super.key,
    this.width = double.infinity,
    this.height = 12.0,
    this.borderRadius = 4.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
      margin: margin,
    );
  }
}

// ============================================================================
// TEMPLATE SKELETON KHUSUS FITUR VBAT PONSEL
// ============================================================================

/// 1. Skeleton untuk Banner Hero Slider Beranda
class HeroBannerSkeleton extends StatelessWidget {
  final double marginHorizontal;

  const HeroBannerSkeleton({
    super.key,
    this.marginHorizontal = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: marginHorizontal, vertical: 8),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const SkeletonCircle(size: 28),
                    const SizedBox(width: 8),
                    SkeletonBox(width: 90, height: 16, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: 10),
                SkeletonBox(width: MediaQuery.of(context).size.width * 0.6, height: 18, borderRadius: 4),
                const SizedBox(height: 6),
                SkeletonBox(width: MediaQuery.of(context).size.width * 0.4, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 2. Skeleton untuk Banner Horizontal Sponsor
class HorizontalBannerSkeleton extends StatelessWidget {
  final double aspectRatio;
  final EdgeInsetsGeometry margin;

  const HorizontalBannerSkeleton({
    super.key,
    this.aspectRatio = 2.7,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        margin: margin,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: SkeletonBox(
            borderRadius: 12,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

/// 3. Skeleton Kartu Produk (Product Card) Grid Katalog
class ProductCardSkeleton extends StatelessWidget {
  final double width;

  const ProductCardSkeleton({
    super.key,
    this.width = 160.0,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gambar Produk
            AspectRatio(
              aspectRatio: 1,
              child: SkeletonBox(
                borderRadius: 8,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 10),
            // Kategori / Brand Tag
            SkeletonBox(width: 50, height: 10, borderRadius: 3),
            const SizedBox(height: 6),
            // Nama Produk (2 baris)
            SkeletonBox(width: double.infinity, height: 12, borderRadius: 3),
            const SizedBox(height: 4),
            SkeletonBox(width: width * 0.7, height: 12, borderRadius: 3),
            const SizedBox(height: 8),
            // Harga
            SkeletonBox(width: 80, height: 14, borderRadius: 4),
            const SizedBox(height: 6),
            // Rating & Terjual
            Row(
              children: [
                SkeletonBox(width: 35, height: 10, borderRadius: 2),
                const SizedBox(width: 6),
                SkeletonBox(width: 45, height: 10, borderRadius: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 4. Skeleton untuk Daftar Best Deals / Flash Sale Horizontal
class BestDealsSkeletonList extends StatelessWidget {
  final int itemCount;

  const BestDealsSkeletonList({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => const ProductCardSkeleton(width: 155),
      ),
    );
  }
}

/// 5. Skeleton Lingkaran Mitra Brand / Partner Resmi
class BrandPartnerSkeletonList extends StatelessWidget {
  final int itemCount;

  const BrandPartnerSkeletonList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SizedBox(
        height: 85,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (_, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SkeletonCircle(size: 56),
                const SizedBox(height: 8),
                SkeletonBox(width: 48, height: 10, borderRadius: 3),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 6. Skeleton Daftar Kursus / Modul Belajar
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            SkeletonBox(width: 90, height: 75, borderRadius: 10),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 60, height: 10, borderRadius: 3),
                  const SizedBox(height: 6),
                  SkeletonBox(width: double.infinity, height: 14, borderRadius: 4),
                  const SizedBox(height: 6),
                  SkeletonBox(width: 120, height: 12, borderRadius: 3),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SkeletonBox(width: 50, height: 10, borderRadius: 3),
                      const SizedBox(width: 10),
                      SkeletonBox(width: 40, height: 10, borderRadius: 3),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 7. Skeleton Kotak Masuk Notifikasi
class NotificationItemSkeleton extends StatelessWidget {
  const NotificationItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonCircle(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 130, height: 12, borderRadius: 3),
                      SkeletonBox(width: 45, height: 10, borderRadius: 3),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 11, borderRadius: 3),
                  const SizedBox(height: 4),
                  SkeletonBox(width: 180, height: 11, borderRadius: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
