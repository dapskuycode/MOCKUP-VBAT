import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/features/home/presentation/pages/home_header_sliver.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);
  final Color _orangeSale = const Color(0xFFFD761A);

  final ScrollController _scrollController = ScrollController();
  int _itemCount = 8;
  bool _isLoadingMore = false;

  // --- State untuk kategori yang dipilih ---
  String _selectedCategory = "Semua";

  // Flash sale timer
  late Timer _flashSaleTimer;
  Duration _flashSaleTime = const Duration(hours: 2, minutes: 48, seconds: 15);

  final List<Map<String, String>> _dummyProducts = [
    {"name": "Obeng Set Presisi 24 in 1 Magnetik", "price": "Rp45.000", "rating": "4.8", "sold": "1.2RB", "category": "Tools"},
    {"name": "LCD iPhone 11 Pro Max OLED Ori", "price": "Rp1.250.000", "rating": "4.9", "sold": "530", "category": "LCD"},
    {"name": "Baterai Samsung S20 Ultra Original", "price": "Rp249.000", "rating": "4.7", "sold": "840", "category": "Baterai"},
    {"name": "Solder Listrik T12 Digital Auto Sleep", "price": "Rp389.000", "rating": "4.9", "sold": "310", "category": "Tools"},
    {"name": "Flux Amtech NC-559-ASM Original 10cc", "price": "Rp85.000", "rating": "4.8", "sold": "3.5RB", "category": "Tools"},
    {"name": "Kaca Magnifier Microscope LED 40X", "price": "Rp125.000", "rating": "4.6", "sold": "412", "category": "Tools"},
    {"name": "Kawat Jumper Tembaga 0.02mm Presisi", "price": "Rp18.000", "rating": "4.7", "sold": "980", "category": "Aksesoris"},
    {"name": "Blower Quick 857D Hot Air Gun Digital", "price": "Rp850.000", "rating": "4.9", "sold": "180", "category": "Tools"},
    {"name": "Pinset Titanium Presisi Anti-Magnetik", "price": "Rp65.000", "rating": "4.8", "sold": "620", "category": "Tools"},
    {"name": "Lem LCD Touchscreen T-7000 Hitam 50ml", "price": "Rp25.000", "rating": "4.7", "sold": "2.1RB", "category": "LCD"},
    {"name": "Alat Pemisah Touchscreen LCD CP-300", "price": "Rp480.000", "rating": "4.9", "sold": "95", "category": "LCD"},
    {"name": "Baterai iPhone X 2716mAh Original", "price": "Rp185.000", "rating": "4.8", "sold": "1.5RB", "category": "Baterai"},
    {"name": "Konektor Charger Samsung A50 Original", "price": "Rp35.000", "rating": "4.7", "sold": "2.8RB", "category": "Konektor"},
    {"name": "Konektor Charger iPhone 8 Plus Ori", "price": "Rp55.000", "rating": "4.8", "sold": "1.1RB", "category": "Konektor"},
    {"name": "Casing Belakang Samsung S21 Ultra", "price": "Rp95.000", "rating": "4.6", "sold": "350", "category": "Aksesoris"},
    {"name": "Screen Protector Tempered Glass Universal", "price": "Rp12.000", "rating": "4.5", "sold": "5.2RB", "category": "Aksesoris"},
  ];

  // Mapping kategori
  final Map<String, String> _categoryMap = {
    "Semua": "Semua",
    "LCD & Layar": "LCD",
    "Baterai": "Baterai",
    "Konektor\nCharging": "Konektor",
    "Tools & Alat": "Tools",
    "Aksesoris": "Aksesoris",
  };

  List<Map<String, String>> get _filteredProducts {
    if (_selectedCategory == "Semua") return _dummyProducts;
    return _dummyProducts.where((p) => p["category"] == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });

    _flashSaleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_flashSaleTime.inSeconds > 0) {
          _flashSaleTime = Duration(seconds: _flashSaleTime.inSeconds - 1);
        }
      });
    });
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _itemCount += 6;
        _isLoadingMore = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _flashSaleTimer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filteredProducts;
    final effectiveItemCount = _itemCount.clamp(0, filteredProducts.isNotEmpty ? filteredProducts.length * 3 : 12);

    return Scaffold(
      backgroundColor: _bgLight,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- 1. Header ---
          const HomeHeaderSliver(),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // --- 2. Quick Filter Row ---
          SliverToBoxAdapter(
            child: SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildQuickFilter(Icons.build_rounded, _primaryBlue, "Semua Alat", "200+ produk", categoryKey: "Semua"),
                  const SizedBox(width: 8),
                  _buildQuickFilter(Icons.bolt_rounded, Colors.red, "Flash Sale", "Diskon hari ini", isHot: true, categoryKey: "Semua"),
                  const SizedBox(width: 8),
                  _buildQuickFilter(Icons.local_shipping_rounded, Colors.green, "Gratis Ongkir", "Min. belanja 50rb", categoryKey: "Semua"),
                ],
              ),
            ),
          ),

          // --- 3. Kategori Icon Grid ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryIcon(Icons.phone_iphone_rounded, "LCD & Layar"),
                  _buildCategoryIcon(Icons.battery_charging_full_rounded, "Baterai"),
                  _buildCategoryIcon(Icons.electrical_services_rounded, "Konektor\nCharging"),
                  _buildCategoryIcon(Icons.handyman_rounded, "Tools & Alat"),
                  _buildCategoryIcon(Icons.headphones_rounded, "Aksesoris"),
                ],
              ),
            ),
          ),

          // --- 4. Brand & Partner Resmi (Auto-Sliding Cards) ---
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Brand & Partner Resmi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryBlue)),
                ),
                const SizedBox(height: 12),
                const SizedBox(
                  height: 220,
                  child: _AutoSlidingBrandCards(),
                ),
                // Banner memanjang di bawah brand cards
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/banner_braderparts.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [_primaryBlue, Colors.blue.shade900]),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_rounded, color: Colors.white.withValues(alpha: 0.8), size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                "BRADERPARTS - OFFICIAL PARTNER RESMI",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- 5. Flash Sale (Harmonisasi dengan Beranda) ---
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _orangeSale,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "FLASH SALE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Text(
                          _formatDuration(_flashSaleTime),
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            "Lihat Semua",
                            style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Icon(Icons.chevron_right_rounded, color: _primaryBlue, size: 16),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 170,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildFlashSaleCard(
                          "Infinix Hot 10 Play Battery",
                          "Rp145.000",
                          "Rp220.000",
                          "35%",
                          "assets/images/product_battery.png",
                        ),
                        const SizedBox(width: 12),
                        _buildFlashSaleCard(
                          "LCD iPhone 11 Pro Max OLED",
                          "Rp1.250.000",
                          "Rp1.850.000",
                          "32%",
                          "assets/images/product_lcd.png",
                        ),
                        const SizedBox(width: 12),
                        _buildFlashSaleCard(
                          "Obeng Set Presisi 24 in 1 Magnet",
                          "Rp45.000",
                          "Rp80.000",
                          "44%",
                          "assets/images/product_battery.png",
                        ),
                        const SizedBox(width: 12),
                        _buildFlashSaleCard(
                          "Flux Amtech NC-559-ASM 10cc",
                          "Rp85.000",
                          "Rp130.000",
                          "34%",
                          "assets/images/product_battery.png",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 6. Rekomendasi Header ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Text("Rekomendasi Untukmu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
                  if (_selectedCategory != "Semua") ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCategory,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primaryBlue),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _selectedCategory = "Semua"),
                            child: Icon(Icons.close_rounded, size: 14, color: _primaryBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // --- 7. Grid Rekomendasi with sponsor banners ---
          ..._buildRecommendationSlivers(filteredProducts, effectiveItemCount),

          // Skeleton loading placeholder (2 kolom, 4 card shimmer)
          if (_isLoadingMore)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const _ShimmerProductCard(),
                  childCount: 4,
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

  // --- Build Recommendation Slivers with sparse sponsor banners ---
  List<Widget> _buildRecommendationSlivers(List<Map<String, String>> products, int totalCount) {
    List<Widget> slivers = [];
    int groupSize = 6;
    int groupIndex = 0;
    int i = 0;

    while (i < totalCount) {
      int end = (i + groupSize < totalCount) ? i + groupSize : totalCount;
      int count = end - i;

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final productIndex = (i + index) % products.length;
              final product = products[productIndex];
              final name = product["name"]!;
              final isLcd = name.toLowerCase().contains("lcd") || name.toLowerCase().contains("layar") || name.toLowerCase().contains("lem");
              final mappedProduct = {
                "name": name,
                "price": product["price"]!,
                "rating": product["rating"]!,
                "sold": product["sold"]!,
                "image": isLcd ? "assets/images/product_lcd.png" : "assets/images/product_battery.png",
                "link": isLcd
                    ? "https://shopee.co.id/brader_parts?categoryId=100013&entryPoint=ShopByPDP&itemId=22913463095"
                    : "https://shopee.co.id/Braderparts-Baterai-Battery-Batre-BL-58BX-for-Infinix-Hot-9-Play-Hot-10-Play-Hot-10S-Hot-11-Play-Hot-12-Play-i.57356590.22913463095",
              };
              return _buildProductCard(
                context,
                mappedProduct,
                isPromoXtra: (i + index) % 5 == 0,
              );
            }, childCount: count),
          ),
        ),
      );

      // Sisipkan sponsor banner setiap 2 grup (moderat)
      if (end < totalCount && groupIndex % 2 == 1) {
        slivers.add(SliverToBoxAdapter(child: _buildSponsorBanner(groupIndex)));
      }

      groupIndex++;
      i = end;
    }
    return slivers;
  }

  // --- Sponsor Banner (moderate, between groups) ---
  Widget _buildSponsorBanner(int index) {
    final bool isPromo = index % 4 == 1;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          isPromo ? 'assets/images/banner_promo_diskon.png' : 'assets/images/banner_braderparts.png',
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPromo ? [_orangeSale, Colors.deepOrange] : [_primaryBlue, Colors.blue.shade900],
              ),
            ),
            child: Center(
              child: Text(
                isPromo ? "⚡ PROMO SPESIAL HARI INI - HEMAT 30%" : "🏪 BRADERPARTS OFFICIAL STORE",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Flash Sale Card (sama persis dengan Beranda) ---
  Widget _buildFlashSaleCard(
    String name,
    String price,
    String originalPrice,
    String discount,
    String assetImage,
  ) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/product-detail',
          extra: {
            "name": name,
            "price": price,
            "image": assetImage,
            "rating": "4.9",
            "sold": "250+",
            "link": "https://shopee.co.id/Braderparts-Baterai-Battery-Batre-BL-58BX-for-Infinix-Hot-9-Play-Hot-10-Play-Hot-10S-Hot-11-Play-Hot-12-Play-i.57356590.22913463095?extraParams=%7B%22display_model_id%22%3A350188294975%2C%22model_selection_logic%22%3A3%7D&sp_atk=f8d0ca69-2d93-4324-b982-5cd7d983550e&xptdk=f8d0ca69-2d93-4324-b982-5cd7d983550e",
          },
        );
      },
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        assetImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.phone_android_rounded, color: Colors.grey, size: 36),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        discount,
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    originalPrice,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade400,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _orangeSale),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Quick Filter with active state ---
  Widget _buildQuickFilter(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle, {
    bool isHot = false,
    required String categoryKey,
  }) {
    final bool isActive = _selectedCategory == (_categoryMap[categoryKey] ?? categoryKey);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = _categoryMap[categoryKey] ?? categoryKey;
        });
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? _primaryBlue.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? _primaryBlue : Colors.grey.shade200,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isActive ? _primaryBlue : _textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 9, color: _textGray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isHot)
              Positioned(
                top: -12,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "HOT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Category Icon with active highlight ---
  Widget _buildCategoryIcon(IconData icon, String label) {
    final String mappedKey = _categoryMap[label] ?? label;
    final bool isActive = _selectedCategory == mappedKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedCategory == mappedKey) {
            _selectedCategory = "Semua"; // Toggle off
          } else {
            _selectedCategory = mappedKey;
          }
        });
      },
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isActive ? _primaryBlue.withValues(alpha: 0.12) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? _primaryBlue : Colors.grey.shade200,
                  width: isActive ? 2.5 : 1,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: _primaryBlue.withValues(alpha: 0.15), blurRadius: 8, spreadRadius: 1)]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
              ),
              child: Icon(icon, color: _primaryBlue, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? _primaryBlue : _textDark,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Map<String, dynamic> product, {
    required bool isPromoXtra,
  }) {
    final String title = product["name"]!;
    final String price = product["price"]!;
    final String rating = product["rating"]!;
    final String sold = product["sold"]!;
    final String image = product["image"]!;

    // Location & shipping tags
    final List<String> locations = ["Jakarta Selatan", "Bandung", "Surabaya", "Tangerang", "Bekasi"];
    final String location = locations[title.length % locations.length];
    final bool hasFreeShipping = (title.length % 3 == 0);
    final bool hasCOD = (title.length % 4 == 0);

    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.asset(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.image, color: Colors.grey)),
                      ),
                    ),
                  ),
                  // Promo tag
                  if (isPromoXtra)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "PROMO XTRA",
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // Free shipping badge at bottom
                  if (hasFreeShipping)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_shipping_outlined, color: Colors.white, size: 10),
                            SizedBox(width: 3),
                            Text(
                              "Gratis Ongkir",
                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama produk - max 2 baris
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Rating & sold
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: TextStyle(fontSize: 10, color: _textGray),
                        ),
                        Text(
                          " • $sold terjual",
                          style: TextStyle(fontSize: 10, color: _textGray),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Harga - paling menonjol
                    Text(
                      price,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryBlue,
                        fontSize: 14,
                      ),
                    ),
                    // Lokasi & COD
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 10, color: _textGray),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: _textGray),
                            ),
                          ),
                          if (hasCOD) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green, width: 0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Text(
                                "COD",
                                style: TextStyle(fontSize: 7, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Auto-Sliding Brand Partner Cards Widget ---
class _AutoSlidingBrandCards extends StatefulWidget {
  const _AutoSlidingBrandCards();

  @override
  State<_AutoSlidingBrandCards> createState() => _AutoSlidingBrandCardsState();
}

class _AutoSlidingBrandCardsState extends State<_AutoSlidingBrandCards> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _brandPartners = [
    {
      "name": "BraderParts",
      "subtitle": "Sparepart Resmi",
      "icon": Icons.build_circle_rounded,
      "color": const Color(0xFF1B4F9B),
      "verified": true,
      "image": "assets/images/logo_braderparts.png"
    },
    {
      "name": "BT-ACC Battery",
      "subtitle": "Baterai Original",
      "icon": Icons.battery_charging_full_rounded,
      "color": const Color(0xFF03AC0E),
      "verified": true,
      "image": "assets/images/logo_btacc.png"
    },
    {
      "name": "TITAN Tools",
      "subtitle": "Alat Servis Premium",
      "icon": Icons.shield_rounded,
      "color": Colors.orange,
      "verified": true,
      "image": "assets/images/logo_titan.png"
    },
    {
      "name": "Sunshine",
      "subtitle": "Tools & LCD",
      "icon": Icons.wb_sunny_rounded,
      "color": Colors.amber,
      "verified": false,
      "image": "assets/images/logo_sunshine.png"
    },
    {
      "name": "Borneo Schematics",
      "subtitle": "Skema Hardware",
      "icon": Icons.map_rounded,
      "color": Colors.blueGrey,
      "verified": true,
      "image": "assets/images/logo_borneo.png"
    },
    {
      "name": "Pragmafix",
      "subtitle": "Software Tools",
      "icon": Icons.memory_rounded,
      "color": Colors.purple,
      "verified": true,
      "image": "assets/images/logo_pragmafix.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.42, initialPage: 0);
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % _brandPartners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: _brandPartners.length,
      onPageChanged: (index) {
        setState(() => _currentPage = index);
      },
      itemBuilder: (context, index) {
        final brand = _brandPartners[index];
        final bool isActive = _currentPage == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(
            horizontal: 6,
            vertical: isActive ? 4 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? (brand["color"] as Color) : Colors.grey.shade200,
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: (brand["color"] as Color).withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: (brand["color"] as Color).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: brand["image"] != null
                        ? ClipOval(child: Image.asset(brand["image"], fit: BoxFit.cover))
                        : Icon(
                            brand["icon"] as IconData,
                            color: brand["color"] as Color,
                            size: 28,
                          ),
                  ),
                  if (brand["verified"] == true)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                brand["name"] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001944),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                brand["subtitle"] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: (brand["color"] as Color).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Kunjungi",
                  style: TextStyle(
                    color: brand["color"] as Color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Shimmer Skeleton Product Card (Loading Placeholder) ---
class _ShimmerProductCard extends StatefulWidget {
  const _ShimmerProductCard();

  @override
  State<_ShimmerProductCard> createState() => _ShimmerProductCardState();
}

class _ShimmerProductCardState extends State<_ShimmerProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    gradient: LinearGradient(
                      begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
                      end: Alignment(-1.0 + 2.0 * _controller.value + 1.0, 0),
                      colors: [
                        Colors.grey.shade200,
                        Colors.grey.shade100,
                        Colors.grey.shade200,
                      ],
                    ),
                  ),
                ),
              ),
              // Text placeholders
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title line 1
                      _buildShimmerBar(width: double.infinity, height: 10),
                      const SizedBox(height: 6),
                      // Title line 2
                      _buildShimmerBar(width: 100, height: 10),
                      const Spacer(),
                      // Rating line
                      _buildShimmerBar(width: 80, height: 8),
                      const SizedBox(height: 6),
                      // Price line
                      _buildShimmerBar(width: 90, height: 14),
                      const SizedBox(height: 4),
                      // Location line
                      _buildShimmerBar(width: 70, height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
          end: Alignment(-1.0 + 2.0 * _controller.value + 1.0, 0),
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
        ),
      ),
    );
  }
}
