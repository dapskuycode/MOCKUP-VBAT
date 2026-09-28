import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/analytics_tracker.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';
import 'package:vbat_ponsel/features/home/presentation/pages/home_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic>? productData;
  const ProductDetailPage({super.key, this.productData});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _orangeSale = const Color(0xFFFD761A);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  int _currentImageIndex = 0;
  bool _isWishlisted = false;

  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _recommendations = [];
  bool _isLoadingMore = false;

  // Recommendations template data
  final List<Map<String, dynamic>> _recommendationTemplates = [
    {
      "type": "product",
      "name": "Baterai Infinix Hot 10 Play BL-58BX Original",
      "price": "Rp145.000",
      "rating": "4.9",
      "sold": "1.5RB",
      "image": "assets/images/product_battery.png",
      "link":
          "https://shopee.co.id/Braderparts-Baterai-Battery-Batre-BL-58BX-for-Infinix-Hot-9-Play-Hot-10-Play-Hot-10S-Hot-11-Play-Hot-12-Play-i.57356590.22913463095",
    },
    {
      "type": "product",
      "name": "LCD iPhone 11 Pro Max OLED Original Quality",
      "price": "Rp1.250.000",
      "rating": "4.8",
      "sold": "850",
      "image": "assets/images/product_lcd.png",
      "link":
          "https://shopee.co.id/brader_parts?categoryId=100013&entryPoint=ShopByPDP&itemId=22913463095",
    },
    {
      "type": "product",
      "name": "Obeng Set Magnetik 24 in 1 Presisi S2 Steel",
      "price": "Rp45.000",
      "rating": "4.8",
      "sold": "3.2RB",
      "image": "assets/images/product_battery.png",
      "link": "https://shopee.co.id/brader_parts",
    },
    {
      "type": "product",
      "name": "Flux Amtech NC-559-ASM Original 10cc",
      "price": "Rp85.000",
      "rating": "4.9",
      "sold": "4.5RB",
      "image": "assets/images/product_battery.png",
      "link": "https://shopee.co.id/brader_parts",
    },
    {
      "type": "product",
      "name": "Blower Quick 857D Hot Air Gun Digital",
      "price": "Rp850.000",
      "rating": "4.9",
      "sold": "190",
      "image": "assets/images/product_lcd.png",
      "link": "https://shopee.co.id/brader_parts",
    },
  ];

  final List<Map<String, dynamic>> _partnerLogoTemplates = [
    {
      "name": "BraderParts",
      "color": Colors.white,
      "badge": Colors.blue,
      "icon": Icons.build_circle_rounded,
    },
    {
      "name": "TITAN Tools",
      "color": Colors.white,
      "badge": Colors.blue,
      "icon": Icons.shield_rounded,
    },
    {
      "name": "BT-ACC Battery",
      "color": Colors.white,
      "badge": Colors.amber,
      "icon": Icons.battery_charging_full_rounded,
    },
  ];

  // Resolve current product details
  String get _productName =>
      widget.productData?["name"] ??
      "LCD iPhone 11 Pro Max OLED Kualitas Original";
  String get _productPrice => widget.productData?["price"] ?? "Rp1.250.000";
  String get _productImage {
    final img = widget.productData?["image"] ??
        widget.productData?["image_path"];
    if (img != null && img.toString().trim().isNotEmpty) {
      return img.toString().trim();
    }
    return "assets/images/product_lcd.png";
  }

  String get _productLink {
    final raw = widget.productData?["link"] ??
        widget.productData?["shopee_url"] ??
        widget.productData?["tokopedia_url"];
    if (raw != null && raw.toString().trim().isNotEmpty) {
      return raw.toString().trim();
    }
    return "https://shopee.co.id/brader_parts";
  }

  bool get _isTokopedia => _productLink.toLowerCase().contains("tokopedia");
  String get _marketplaceName => _isTokopedia ? "Tokopedia" : "Shopee";
  Color get _marketplaceColor =>
      _isTokopedia ? const Color(0xFF03AC0E) : const Color(0xFFEE4D2D);

  String get _productRating => widget.productData?["rating"] ?? "4.8";
  String get _productSold => widget.productData?["sold"] ?? "800+";
  String get _productDescription {
    if (widget.productData?["description"] != null) {
      return widget.productData!["description"];
    }
    // Generate description dynamically based on the product name
    final nameLower = _productName.toLowerCase();
    if (nameLower.contains("baterai") ||
        nameLower.contains("battery") ||
        nameLower.contains("batre")) {
      return "Spesifikasi Produk:\n• Kualitas: Original Equipment Manufacturer (OEM)\n• Kapasitas: Standar pabrik (tahan lama)\n• Proteksi: Double IC Protection (mencegah overcharge)\n• Garansi: Resmi distributor 12 bulan";
    } else if (nameLower.contains("obeng") ||
        nameLower.contains("flux") ||
        nameLower.contains("blower") ||
        nameLower.contains("solder") ||
        nameLower.contains("pinset")) {
      return "Spesifikasi Produk:\n• Kualitas: Premium Industrial Grade\n• Material: Material Presisi Tinggi & Ergonomis\n• Kegunaan: Pembongkaran presisi motherboard & chip IC HP\n• Keandalan: Tahan panas tinggi & anti-statis ESD";
    }
    return "Spesifikasi Produk:\n• Kualitas: OLED Original Quality\n• Kompatibilitas: Layar sentuh presisi\n• Resolusi: Standar performa tinggi\n• True Tone: Support (bisa ditransfer)";
  }

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    // Check if this product is wishlisted
    _isWishlisted = WishlistHelper.items.any((x) => x["name"] == _productName);

    // Initial recommendations
    _generateRecommendations(count: 4);

    // Track product click/interaction to backend
    final productId = widget.productData?['id'] is int
        ? widget.productData!['id'] as int
        : null;
    AnalyticsTracker.trackProductClick(
      productId: productId,
      productName: _productName,
    );

    // Scroll listener for infinite scroll recommendations
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        _loadMoreRecommendations();
      }
    });
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _generateRecommendations({required int count}) {
    final Random random = Random();
    for (int i = 0; i < count; i++) {
      // 80% produk, 10% banner, 10% partner
      int typeChoice = random.nextInt(10);
      if (typeChoice <= 7) {
        // 0-7: produk (80%)
        var template =
            _recommendationTemplates[random.nextInt(
              _recommendationTemplates.length,
            )];
        _recommendations.add(Map<String, dynamic>.from(template));
      } else if (typeChoice == 8) {
        // 8: sliding_banner (10%)
        _recommendations.add({"type": "sliding_banner"});
      } else {
        // 9: partner_card (10%)
        var partner =
            _partnerLogoTemplates[random.nextInt(_partnerLogoTemplates.length)];
        _recommendations.add({"type": "partner_card", "partner": partner});
      }
    }
  }

  void _loadMoreRecommendations() {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _generateRecommendations(count: 4);
        _isLoadingMore = false;
      });
    });
  }

  Future<void> _handleDirectMarketplacePurchase(BuildContext context) async {
    final url = _productLink;
    final platform = _marketplaceName;

    // Track analytics event to backend
    final productId = widget.productData?['id'] is int
        ? widget.productData!['id'] as int
        : 1;
    AnalyticsTracker.trackMarketplaceOutbound(
      productId: productId,
      productName: _productName,
      url: url,
      platform: platform,
    );

    if (url.isEmpty || !url.startsWith("http")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link marketplace belum dikonfigurasi untuk produk ini."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Membuka $platform...",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: _marketplaceColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tidak dapat membuka tautan marketplace"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildProductImage(
    String image, {
    BoxFit fit = BoxFit.contain,
    double? iconSize = 80,
  }) {
    final raw = image.trim();
    final n = _productName.toLowerCase();
    String fallbackAsset = "assets/images/product_1.png";
    if (n.contains("lcd") ||
        n.contains("layar") ||
        n.contains("screen") ||
        n.contains("oled")) {
      fallbackAsset = "assets/images/product_lcd.png";
    } else if (n.contains("baterai") ||
        n.contains("battery") ||
        n.contains("batre") ||
        n.contains("bl-58bx")) {
      fallbackAsset = "assets/images/product_battery.png";
    }

    if (raw.startsWith("http://") || raw.startsWith("https://")) {
      return Image.network(
        raw,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Image.asset(
          fallbackAsset,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.inventory_2_outlined,
              size: iconSize,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      );
    }

    String assetPath = raw;
    if (assetPath.isEmpty ||
        assetPath.contains("brand_apple") ||
        assetPath.contains("brand_infinix")) {
      assetPath = fallbackAsset;
    }

    return Image.asset(
      assetPath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        fallbackAsset,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.inventory_2_outlined,
            size: iconSize,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBannerWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/banner_promo_diskon.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFD761A), Colors.deepOrange],
              ),
            ),
            child: const Center(
              child: Text(
                "SPECIAL PROMO - DISKON 30%",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerBannerWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/banner_braderparts.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B4F9B), Colors.blue],
              ),
            ),
            child: const Center(
              child: Text(
                "BRADERPARTS OFFICIAL PARTNER",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        context.push('/product-detail', extra: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: _isDark ? ThemeManager.darkBg : Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: _buildProductImage(
                        item["image"] ?? "",
                        fit: BoxFit.cover,
                        iconSize: 36,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "PRODUK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["name"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 12,
                      ),
                      Text(
                        " ${item['rating']} • ${item['sold']} terjual",
                        style: TextStyle(fontSize: 10, color: _textGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item["price"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _orangeSale,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: _cardColor,
          border: _isDark ? Border(top: BorderSide(color: _borderColor)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isWishlisted
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isWishlisted ? Colors.red : _textGray,
                size: 26,
              ),
              onPressed: () {
                final isAdded = WishlistHelper.toggleWishlist(context, {
                  "name": _productName,
                  "price": _productPrice,
                  "image": _productImage,
                  "link": _productLink,
                });
                setState(() {
                  _isWishlisted = isAdded;
                });
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleDirectMarketplacePurchase(context),
                icon: Icon(
                  _isTokopedia
                      ? Icons.storefront_outlined
                      : Icons.shopping_bag_outlined,
                  size: 18,
                ),
                label: Text(
                  "Beli Langsung di $_marketplaceName",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _marketplaceColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- 1. Top App Bar ---
          SliverAppBar(
            backgroundColor: _isDark ? ThemeManager.darkCard : _primaryBlue,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Detail Produk",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  _isWishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isWishlisted ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  final isAdded = WishlistHelper.toggleWishlist(context, {
                    "name": _productName,
                    "price": _productPrice,
                    "image": _productImage,
                    "link": _productLink,
                  });
                  setState(() {
                    _isWishlisted = isAdded;
                  });
                },
              ),
            ],
          ),

          // --- 2. Image Gallery ---
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              color: _cardColor,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: 3,
                    onPageChanged: (index) =>
                        setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return Container(
                        color: _isDark ? ThemeManager.darkBg : Colors.grey.shade100,
                        padding: const EdgeInsets.all(24),
                        child: _buildProductImage(
                          _productImage,
                          fit: BoxFit.contain,
                          iconSize: 80,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index
                                ? (_isDark ? const Color(0xFF60A5FA) : _primaryBlue)
                                : (_isDark ? const Color(0xFF2D3748) : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 3. Info Produk Utama ---
          SliverToBoxAdapter(
            child: Container(
              color: _cardColor,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _productName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        _productPrice,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _orangeSale,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isDark
                              ? Colors.green.shade900.withValues(alpha: 0.3)
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "STOK TERBATAS",
                          style: TextStyle(
                            color: _isDark ? Colors.green.shade300 : Colors.green.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _productRating,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        " ($_productSold terjual)",
                        style: TextStyle(color: _textGray, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- 4. Info Toko / Seller ---
          SliverToBoxAdapter(
            child: Container(
              color: _cardColor,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _isDark ? ThemeManager.darkBg : _bgLight,
                    child: Icon(
                      Icons.storefront_rounded,
                      color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.productData?["partner"] ?? "BraderParts Official",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _textDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: Colors.green,
                              size: 16,
                            ),
                          ],
                        ),
                        Text(
                          "Aktif 5 menit lalu",
                          style: TextStyle(fontSize: 12, color: _textGray),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      final partner = widget.productData?["partner"] ?? "Mitra Resmi";
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Berhasil mengikuti $partner!"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Ikuti",
                      style: TextStyle(
                        color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 5. Deskripsi & Detail ---
          SliverToBoxAdapter(
            child: Container(
              color: _cardColor,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Deskripsi Produk",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _textDark,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: _textGray),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _productDescription,
                    style: TextStyle(color: _textGray, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          // --- 6. Infinite Recommendations Header ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                "Rekomendasi Lainnya",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ),
          ),

          // --- 7. Recommendations List / Alternating Slivers ---
          ..._buildRecommendationsSlivers(context),

          // Loading indicator at bottom
          if (_isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
                    ),
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  List<Widget> _buildRecommendationsSlivers(BuildContext context) {
    List<Widget> slivers = [];
    int i = 0;
    int groupSize = 6; // Kelompok lebih besar agar banner tidak terlalu sering
    int groupIndex = 0;
    while (i < _recommendations.length) {
      int end = (i + groupSize < _recommendations.length)
          ? i + groupSize
          : _recommendations.length;
      List<Map<String, dynamic>> sublist = _recommendations.sublist(i, end);

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.66,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = sublist[index];
              if (item["type"] == "sliding_banner") {
                return const SlidingBannerCardWidget();
              } else if (item["type"] == "partner_card") {
                return PartnerLogoCardWidget(partner: item["partner"]);
              } else {
                return _buildGridCard(context, item);
              }
            }, childCount: sublist.length),
          ),
        ),
      );

      // Selipkan banner hanya setiap 2 grup (lebih jarang)
      if (end < _recommendations.length && groupIndex % 2 == 1) {
        if (groupIndex % 4 == 1) {
          slivers.add(SliverToBoxAdapter(child: _buildPromoBannerWidget()));
        } else {
          slivers.add(SliverToBoxAdapter(child: _buildPartnerBannerWidget()));
        }
      }
      groupIndex++;
      i = end;
    }
    return slivers;
  }
}
