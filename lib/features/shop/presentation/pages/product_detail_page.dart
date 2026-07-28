import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);

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
      "link": "https://shopee.co.id/Braderparts-Baterai-Battery-Batre-BL-58BX-for-Infinix-Hot-9-Play-Hot-10-Play-Hot-10S-Hot-11-Play-Hot-12-Play-i.57356590.22913463095"
    },
    {
      "type": "product",
      "name": "LCD iPhone 11 Pro Max OLED Original Quality",
      "price": "Rp1.250.000",
      "rating": "4.8",
      "sold": "850",
      "image": "assets/images/product_lcd.png",
      "link": "https://shopee.co.id/brader_parts?categoryId=100013&entryPoint=ShopByPDP&itemId=22913463095"
    },
    {
      "type": "product",
      "name": "Obeng Set Magnetik 24 in 1 Presisi S2 Steel",
      "price": "Rp45.000",
      "rating": "4.8",
      "sold": "3.2RB",
      "image": "assets/images/product_battery.png",
      "link": "https://shopee.co.id/brader_parts"
    },
    {
      "type": "product",
      "name": "Flux Amtech NC-559-ASM Original 10cc",
      "price": "Rp85.000",
      "rating": "4.9",
      "sold": "4.5RB",
      "image": "assets/images/product_battery.png",
      "link": "https://shopee.co.id/brader_parts"
    },
    {
      "type": "product",
      "name": "Blower Quick 857D Hot Air Gun Digital",
      "price": "Rp850.000",
      "rating": "4.9",
      "sold": "190",
      "image": "assets/images/product_lcd.png",
      "link": "https://shopee.co.id/brader_parts"
    }
  ];

  final List<Map<String, dynamic>> _partnerLogoTemplates = [
    {"name": "BraderParts", "color": Colors.white, "badge": Colors.blue, "icon": Icons.build_circle_rounded},
    {"name": "TITAN Tools", "color": Colors.white, "badge": Colors.blue, "icon": Icons.shield_rounded},
    {"name": "BT-ACC Battery", "color": Colors.white, "badge": Colors.amber, "icon": Icons.battery_charging_full_rounded},
  ];

  // Resolve current product details
  String get _productName => widget.productData?["name"] ?? "LCD iPhone 11 Pro Max OLED Kualitas Original";
  String get _productPrice => widget.productData?["price"] ?? "Rp1.250.000";
  String get _productImage => widget.productData?["image"] ?? "assets/images/product_lcd.png";
  String get _productLink => widget.productData?["link"] ?? "https://shopee.co.id/Braderparts-Baterai-Battery-Batre-BL-58BX-for-Infinix-Hot-9-Play-Hot-10-Play-Hot-10S-Hot-11-Play-Hot-12-Play-i.57356590.22913463095?extraParams=%7B%22display_model_id%22%3A350188294975%2C%22model_selection_logic%22%3A3%7D&sp_atk=f8d0ca69-2d93-4324-b982-5cd7d983550e&xptdk=f8d0ca69-2d93-4324-b982-5cd7d983550e";
  String get _productRating => widget.productData?["rating"] ?? "4.8";
  String get _productSold => widget.productData?["sold"] ?? "800+";
  String get _productDescription {
    if (widget.productData?["description"] != null) {
      return widget.productData!["description"];
    }
    // Generate description dynamically based on the product name
    final nameLower = _productName.toLowerCase();
    if (nameLower.contains("baterai") || nameLower.contains("battery") || nameLower.contains("batre")) {
      return "Spesifikasi Produk:\n• Kualitas: Original Equipment Manufacturer (OEM)\n• Kapasitas: Standar pabrik (tahan lama)\n• Proteksi: Double IC Protection (mencegah overcharge)\n• Garansi: Resmi distributor 12 bulan";
    } else if (nameLower.contains("obeng") || nameLower.contains("flux") || nameLower.contains("blower") || nameLower.contains("solder") || nameLower.contains("pinset")) {
      return "Spesifikasi Produk:\n• Kualitas: Premium Industrial Grade\n• Material: Material Presisi Tinggi & Ergonomis\n• Kegunaan: Pembongkaran presisi motherboard & chip IC HP\n• Keandalan: Tahan panas tinggi & anti-statis ESD";
    }
    return "Spesifikasi Produk:\n• Kualitas: OLED Original Quality\n• Kompatibilitas: Layar sentuh presisi\n• Resolusi: Standar performa tinggi\n• True Tone: Support (bisa ditransfer)";
  }

  @override
  void initState() {
    super.initState();
    // Check if this product is wishlisted
    _isWishlisted = WishlistHelper.items.any((x) => x["name"] == _productName);

    // Initial recommendations
    _generateRecommendations(count: 4);

    // Scroll listener for infinite scroll recommendations
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        _loadMoreRecommendations();
      }
    });
  }

  @override
  void dispose() {
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
        var template = _recommendationTemplates[random.nextInt(_recommendationTemplates.length)];
        _recommendations.add(Map<String, dynamic>.from(template));
      } else if (typeChoice == 8) {
        // 8: sliding_banner (10%)
        _recommendations.add({"type": "sliding_banner"});
      } else {
        // 9: partner_card (10%)
        var partner = _partnerLogoTemplates[random.nextInt(_partnerLogoTemplates.length)];
        _recommendations.add({
          "type": "partner_card",
          "partner": partner,
        });
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

  void _showMarketplacePurchaseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "Pilih Marketplace Pembelian",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001944),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Kami tidak melayani penjualan langsung di platform ini. Anda akan dialihkan ke toko resmi kami.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMarketplaceOption(
                      context,
                      label: "Beli di Shopee",
                      color: const Color(0xFFEE4D2D), // Shopee Orange
                      logoAsset: "assets/images/shopee_logo.png",
                      onTap: () {
                        Navigator.pop(context);
                        _showRedirectOverlay(
                          context,
                          "Shopee",
                          _productLink,
                        );
                      },
                    ),
                    _buildMarketplaceOption(
                      context,
                      label: "Beli di Tokopedia",
                      color: const Color(0xFF03AC0E), // Tokopedia Green
                      logoAsset: "assets/images/tokopedia_logo.png",
                      onTap: () {
                        Navigator.pop(context);
                        _showRedirectOverlay(
                          context,
                          "Tokopedia",
                          "https://shopee.co.id/brader_parts?categoryId=100013&entryPoint=ShopByPDP&itemId=22913463095",
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketplaceOption(
    BuildContext context, {
    required String label,
    required Color color,
    required String logoAsset,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Image.asset(
              logoAsset,
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.storefront_rounded, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedirectOverlay(BuildContext context, String platform, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Mengalihkan ke $platform... ($url)"),
                backgroundColor: platform == "Shopee" ? const Color(0xFFEE4D2D) : const Color(0xFF03AC0E),
              ),
            );
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      platform == "Shopee" ? const Color(0xFFEE4D2D) : const Color(0xFF03AC0E),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Menghubungkan ke $platform",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001944),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Mohon tunggu, Anda sedang dialihkan...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              gradient: LinearGradient(colors: [Color(0xFFFD761A), Colors.deepOrange]),
            ),
            child: const Center(
              child: Text(
                "SPECIAL PROMO - DISKON 30%",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
              gradient: LinearGradient(colors: [Color(0xFF1B4F9B), Colors.blue]),
            ),
            child: const Center(
              child: Text(
                "BRADERPARTS OFFICIAL PARTNER",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
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
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        item["image"],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.handyman_rounded, color: Colors.grey, size: 36),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primaryBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "PRODUK",
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
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
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
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
          color: Colors.white,
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
                _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isWishlisted ? Colors.red : _textGray,
                size: 26,
              ),
              onPressed: () {
                setState(() {
                  _isWishlisted = !_isWishlisted;
                  if (_isWishlisted) {
                    if (!WishlistHelper.items.any((x) => x["name"] == _productName)) {
                      WishlistHelper.items.add({
                        "name": _productName,
                        "price": _productPrice,
                        "image": _productImage,
                        "link": _productLink,
                      });
                    }
                  } else {
                    WishlistHelper.items.removeWhere((x) => x["name"] == _productName);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isWishlisted
                          ? "Produk berhasil ditambahkan ke Wishlist!"
                          : "Produk dihapus dari Wishlist.",
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showMarketplacePurchaseSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orangeSale,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Beli Langsung di Marketplace",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
            backgroundColor: _primaryBlue,
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
                  _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isWishlisted ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isWishlisted = !_isWishlisted;
                    if (_isWishlisted) {
                      if (!WishlistHelper.items.any((x) => x["name"] == _productName)) {
                        WishlistHelper.items.add({
                          "name": _productName,
                          "price": _productPrice,
                          "image": _productImage,
                          "link": _productLink,
                        });
                      }
                    } else {
                      WishlistHelper.items.removeWhere((x) => x["name"] == _productName);
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isWishlisted
                            ? "Produk berhasil ditambahkan ke Wishlist!"
                            : "Produk dihapus dari Wishlist.",
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          // --- 2. Image Gallery ---
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              color: Colors.white,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: 3,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.grey.shade100,
                        padding: const EdgeInsets.all(24),
                        child: Image.asset(
                          _productImage,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.handyman_rounded, size: 80, color: Colors.grey),
                          ),
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
                            color: _currentImageIndex == index ? _primaryBlue : Colors.grey.shade300,
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
              color: Colors.white,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "STOK TERBATAS",
                          style: TextStyle(
                            color: Colors.green.shade700,
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
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        _productRating,
                        style: TextStyle(fontWeight: FontWeight.bold, color: _textDark),
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
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _bgLight,
                    child: Icon(Icons.storefront_rounded, color: _primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "BraderParts Official",
                              style: TextStyle(fontWeight: FontWeight.bold, color: _textDark),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, color: Colors.green, size: 16),
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
                    onPressed: () => _showMarketplacePurchaseSheet(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      "Ikuti",
                      style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 5. Deskripsi & Detail ---
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
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

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
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
      int end = (i + groupSize < _recommendations.length) ? i + groupSize : _recommendations.length;
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
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = sublist[index];
                if (item["type"] == "sliding_banner") {
                  return const SlidingBannerCardWidget();
                } else if (item["type"] == "partner_card") {
                  return PartnerLogoCardWidget(partner: item["partner"]);
                } else {
                  return _buildGridCard(context, item);
                }
              },
              childCount: sublist.length,
            ),
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
