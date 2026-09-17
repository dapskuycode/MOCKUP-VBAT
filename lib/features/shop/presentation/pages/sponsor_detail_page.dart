import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';

class SponsorDetailPage extends StatefulWidget {
  final Map<String, dynamic>? sponsorData;

  const SponsorDetailPage({super.key, this.sponsorData});

  @override
  State<SponsorDetailPage> createState() => _SponsorDetailPageState();
}

class _SponsorDetailPageState extends State<SponsorDetailPage> {
  late Map<String, dynamic> _sponsor;
  late List<Map<String, dynamic>> _allProducts;
  List<Map<String, dynamic>> _filteredProducts = [];
  String _selectedCategory = "Semua";
  final TextEditingController _searchController = TextEditingController();

  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _orangeSale = const Color(0xFFFD761A);
  final Color _bgLight = const Color(0xFFF8FAFC);
  final Color _textDark = const Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _sponsor = widget.sponsorData ?? _getDefaultSponsor();
    _initProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getDefaultSponsor() {
    return {
      "name": "BraderParts Indonesia",
      "short_name": "BraderParts",
      "tier": "PLATINUM",
      "tier_label": "PLATINUM SPONSOR",
      "color": const Color(0xFF6C5CE7),
      "verified": true,
      "logo": "assets/images/logo_braderparts.png",
      "description":
          "Official Distributor suku cadang LCD OLED/Incell, fleksibel, baterai, dan komponen smartphone original bergaransi resmi se-Indonesia. Kualitas teruji untuk teknisi profesional.",
      "website_url": "https://shopee.co.id/brader_parts",
      "products": [
        {
          "name": "LCD Samsung Galaxy A51 Super AMOLED Frame Ori",
          "price": 750000,
          "category": "LCD & Layar",
          "image": "assets/images/product_lcd.png",
          "rating": "4.9",
          "sold": "320+",
          "link": "https://shopee.co.id/brader_parts",
        },
        {
          "name": "Baterai Infinix Hot 9/10/11 Play BL-58BX Original",
          "price": 145000,
          "category": "Baterai",
          "image": "assets/images/product_battery.png",
          "rating": "4.9",
          "sold": "580+",
          "link": "https://shopee.co.id/brader_parts",
        },
        {
          "name": "LCD iPhone 11 Pro Max Original Quality",
          "price": 1250000,
          "category": "LCD & Layar",
          "image": "assets/images/product_lcd.png",
          "rating": "5.0",
          "sold": "190+",
          "link": "https://shopee.co.id/brader_parts",
        },
        {
          "name": "Travel Charger Fast Charging 20W Type-C 10 Pcs",
          "price": 35000,
          "category": "Aksesoris",
          "image": "assets/images/product_1.png",
          "rating": "4.8",
          "sold": "410+",
          "link": "https://shopee.co.id/brader_parts",
        },
      ],
    };
  }

  void _initProducts() {
    final List prods = (_sponsor["products"] as List?) ?? [];
    _allProducts = prods.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    _filteredProducts = List.from(_allProducts);
  }

  void _applyFilter(String query, String category) {
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final matchesQuery = query.isEmpty ||
            (p["name"] ?? "").toString().toLowerCase().contains(query.toLowerCase());
        final matchesCat = category == "Semua" || (p["category"] ?? "") == category;
        return matchesQuery && matchesCat;
      }).toList();
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatRupiah(num value) {
    final str = value.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return "Rp${buffer.toString()}";
  }

  Widget _buildProductThumbnail(String? image, String name) {
    final raw = (image ?? "").trim();
    String fallbackAsset = "assets/images/product_1.png";
    final n = name.toLowerCase();
    if (n.contains("lcd") || n.contains("layar") || n.contains("screen") || n.contains("oled")) {
      fallbackAsset = "assets/images/product_lcd.png";
    } else if (n.contains("baterai") || n.contains("battery") || n.contains("batre")) {
      fallbackAsset = "assets/images/product_battery.png";
    }

    if (raw.startsWith("http://") || raw.startsWith("https://")) {
      return Image.network(
        raw,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
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
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.inventory_2_outlined,
            color: Colors.grey,
            size: 36,
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
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        fallbackAsset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.inventory_2_outlined,
          color: Colors.grey,
          size: 36,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color brandColor = (_sponsor["color"] as Color?) ?? _primaryBlue;
    final String tier = (_sponsor["tier"] ?? "PARTNER").toString().toUpperCase();
    final String tierLabel = (_sponsor["tier_label"] ?? "$tier SPONSOR").toString();
    final String sponsorName = (_sponsor["name"] ?? "Mitra Sponsor").toString();
    final String sponsorDesc = (_sponsor["description"] ?? "").toString();
    final String websiteUrl = (_sponsor["website_url"] ?? "https://shopee.co.id").toString();
    final String logo = (_sponsor["logo"] ?? "assets/images/logo_braderparts.png").toString();

    // Extract categories
    final categories = <String>["Semua"];
    for (var p in _allProducts) {
      final cat = (p["category"] ?? "").toString();
      if (cat.isNotEmpty && !categories.contains(cat)) {
        categories.add(cat);
      }
    }

    return Scaffold(
      backgroundColor: _bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Sleek SliverAppBar with Brand Identity
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: brandColor,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Tautan toko $sponsorName berhasil disalin!"),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.open_in_browser_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () => _launchUrl(websiteUrl),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      brandColor,
                      brandColor.withValues(alpha: 0.75),
                      const Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background decorative circles
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 24,
                      child: Row(
                        children: [
                          // Large Avatar
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: ClipOval(
                              child: logo.startsWith('http')
                                  ? Image.network(
                                      logo,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.store, color: brandColor, size: 36),
                                    )
                                  : Image.asset(
                                      logo,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.store, color: brandColor, size: 36),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    sponsorName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified_rounded, color: Colors.lightBlueAccent, size: 18),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  tierLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Info & Metrics Card
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Highlights Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(Icons.star_rounded, "4.9", "Rating Mitra", Colors.amber),
                      _buildDivider(),
                      _buildMetricItem(
                        Icons.inventory_2_outlined,
                        "${_allProducts.length}",
                        "Produk Resmi",
                        brandColor,
                      ),
                      _buildDivider(),
                      _buildMetricItem(
                        Icons.security_rounded,
                        "100%",
                        "Garansi Ori",
                        const Color(0xFF03AC0E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Button Row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(websiteUrl),
                          icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                          label: const Text(
                            "Kunjungi Toko di Shopee",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEE4D2D), // Shopee Orange
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _launchUrl(websiteUrl),
                        icon: const Icon(Icons.public, size: 16),
                        label: const Text(
                          "Website",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor.withValues(alpha: 0.1),
                          foregroundColor: brandColor,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: brandColor.withValues(alpha: 0.3)),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // 3. Tentang Sponsor (Detail Lengkap)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: brandColor),
                      const SizedBox(width: 8),
                      const Text(
                        "Tentang Mitra Resmi",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    sponsorDesc.isNotEmpty
                        ? sponsorDesc
                        : "Mitra resmi terpercaya penyedia perlengkapan dan suku cadang smartphone original bergaransi resmi.",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Keunggulan Badges
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _bgLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureChip(Icons.verified_user_outlined, "Mitra Terverifikasi"),
                        _buildFeatureChip(Icons.local_shipping_outlined, "Pengiriman Cepat"),
                        _buildFeatureChip(Icons.published_with_changes_rounded, "Garansi Retur"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // 4. Header Katalog Produk + Search & Filter
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.storefront_rounded, size: 18, color: brandColor),
                          const SizedBox(width: 8),
                          Text(
                            "Produk ${_sponsor['short_name'] ?? sponsorName}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${_filteredProducts.length} Produk",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: brandColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => _applyFilter(val, _selectedCategory),
                    decoration: InputDecoration(
                      hintText: "Cari produk di toko ini...",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilter("", _selectedCategory);
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: _bgLight,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: brandColor),
                      ),
                    ),
                  ),
                  if (categories.length > 1) ...[
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: categories.map((cat) {
                          final isSel = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                color: isSel ? Colors.white : Colors.grey.shade700,
                              ),
                              selected: isSel,
                              selectedColor: brandColor,
                              backgroundColor: _bgLight,
                              checkmarkColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSel ? brandColor : Colors.grey.shade300,
                                ),
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                                _applyFilter(_searchController.text, cat);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 5. Grid Produk
          _filteredProducts.isEmpty
              ? SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          "Produk tidak ditemukan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Coba gunakan kata kunci pencarian yang lain.",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = _filteredProducts[index];
                        final String pTitle = (product["name"] ?? "Produk").toString();
                        final num priceNum = product["price"] ?? 0;
                        final String pPrice = _formatRupiah(priceNum);
                        final String pRating = (product["rating"] ?? "4.9").toString();
                        final String pSold = (product["sold"] ?? "100+").toString();
                        final String pCategory = (product["category"] ?? "Sparepart").toString();
                        final String pLink = (product["link"] ?? websiteUrl).toString();
                        final String? pImage = product["image"];
                        final bool isFav = WishlistHelper.isWishlisted(pTitle);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              context.push('/product-detail', extra: {
                                "name": pTitle,
                                "price": pPrice,
                                "price_raw": priceNum,
                                "image": pImage,
                                "category": pCategory,
                                "rating": pRating,
                                "sold": pSold,
                                "partner": sponsorName,
                                "link": pLink,
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail Container with Category & Wishlist Button
                                Stack(
                                  children: [
                                    Container(
                                      height: 125,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: _buildProductThumbnail(pImage, pTitle),
                                    ),
                                    // Category Pill
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: brandColor.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          pCategory,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Wishlist Toggle Button
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          WishlistHelper.toggleWishlist(context, {
                                            "name": pTitle,
                                            "price": pPrice,
                                            "image": pImage ?? "assets/images/product_lcd.png",
                                            "link": pLink,
                                          });
                                          setState(() {});
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.1),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            color: isFav ? Colors.red : Colors.grey.shade600,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pTitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _textDark,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        pPrice,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _orangeSale,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                          const SizedBox(width: 3),
                                          Text(
                                            pRating,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "• $pSold",
                                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Tombol Beli Cepat
                                      SizedBox(
                                        width: double.infinity,
                                        height: 28,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            WishlistHelper.showMarketplaceSheet(context, pTitle, pLink);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: brandColor,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.zero,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            "Beli",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _filteredProducts.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _primaryBlue),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
