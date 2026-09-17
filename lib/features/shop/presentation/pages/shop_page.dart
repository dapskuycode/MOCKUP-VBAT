import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';
import 'package:vbat_ponsel/core/widgets/horizontal_sponsor_slider.dart';
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

  // Active Discount Event from Web Database (Synced dynamically with Laravel Web)
  Map<String, dynamic>? _activeEvent = {
    "has_active": false,
  };

  final ScrollController _scrollController = ScrollController();
  int _itemCount = 14;
  bool _isLoadingMore = false;

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

  // Dynamic products for Flash Sale & Event Diskon (Synced with Web Backend)
  List<Map<String, dynamic>> _bestDeals = [
    {
      "name": "LCD iPhone 11 Pro Max Original Quality",
      "price": 1250000,
      "discount_price": 1250000,
      "discount_percentage": 0,
      "image": "assets/images/product_lcd.png",
      "partner": "BraderParts",
      "link": "https://shopee.co.id/brader_parts",
    },
    {
      "name": "Baterai Infinix Hot 9/10/11 Play BL-58BX",
      "price": 145000,
      "discount_price": 145000,
      "discount_percentage": 0,
      "image": "assets/images/product_battery.png",
      "partner": "BraderParts",
      "link": "https://shopee.co.id/brader_parts",
    },
    {
      "name": "Obeng Set Magnetik 24 in 1 Presisi S2",
      "price": 45000,
      "discount_price": 45000,
      "discount_percentage": 0,
      "image": "assets/images/product_1.png",
      "partner": "TITAN Tools",
      "link": "https://shopee.co.id/titan_tools",
    },
    {
      "name": "Flux Amtech NC-559-ASM 10cc",
      "price": 85000,
      "discount_price": 85000,
      "discount_percentage": 0,
      "image": "assets/images/product_1.png",
      "partner": "TITAN Tools",
      "link": "https://shopee.co.id/titan_tools",
    },
    {
      "name": "Solder Listrik T12 Digital Auto Sleep",
      "price": 389000,
      "discount_price": 389000,
      "discount_percentage": 0,
      "image": "assets/images/product_1.png",
      "partner": "TITAN Tools",
      "link": "https://shopee.co.id/titan_tools",
    },
    {
      "name": "Blower Quick 857D Hot Air Gun Digital",
      "price": 850000,
      "discount_price": 850000,
      "discount_percentage": 0,
      "image": "assets/images/product_1.png",
      "partner": "TITAN Tools",
      "link": "https://shopee.co.id/titan_tools",
    },
    {
      "name": "Baterai Samsung S20 Ultra Original IC",
      "price": 249000,
      "discount_price": 249000,
      "discount_percentage": 0,
      "image": "assets/images/product_battery.png",
      "partner": "BT-ACC",
      "link": "https://shopee.co.id",
    },
  ];

  // --- State untuk kategori yang dipilih ---
  String _selectedCategory = "Semua";

  // Flash sale timer
  late Timer _flashSaleTimer;
  Duration _flashSaleTime = const Duration(hours: 2, minutes: 48, seconds: 15);


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
    final list = _bestDeals.map((p) {
      final origPrice = _formatRupiah(p['price'] ?? 0);
      final discPrice = _formatRupiah(p['discount_price'] ?? p['price'] ?? 0);
      return {
        "id": (p['id'] ?? 0).toString(),
        "name": (p['name'] ?? '').toString(),
        "price": discPrice,
        "original_price": origPrice,
        "discount": "${p['discount_percentage'] ?? 0}%",
        "rating": (p['rating'] ?? '4.9').toString(),
        "sold": (p['sold'] ?? '250+').toString(),
        "category": (p['category'] ?? 'Tools').toString(),
        "image": (p['image'] ?? 'assets/images/product_1.png').toString(),
        "link": (p['shopee_url'] ?? p['link'] ?? 'https://shopee.co.id/brader_parts').toString(),
        "partner": (p['sponsor'] != null && p['sponsor']['name'] != null ? p['sponsor']['name'] : (p['partner'] ?? 'Mitra VBAT')).toString(),
      };
    }).toList();

    if (_selectedCategory == "Semua") return list;
    return list
        .where((p) => (p["category"] ?? '').toLowerCase().contains(_selectedCategory.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchActiveEvent();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
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

  Future<void> _fetchActiveEvent() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api/v1',
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final res = await dio.get('/shop/events/active');
      if (res.data != null && res.data['has_active_event'] == true) {
        if (mounted) {
          setState(() {
            _activeEvent = {
              "name": res.data['data']['name'],
              "value": res.data['data']['value'],
              "banner_text": res.data['data']['banner_text'],
              "has_active": true,
            };
          });
        }
      } else if (res.data != null && res.data['has_active_event'] == false) {
        if (mounted) {
          setState(() {
            _activeEvent = {"has_active": false};
          });
        }
      }

      // Fetch dynamic products with calculated event discount
      final dealsRes = await dio.get('/shop/best-deals');
      if (dealsRes.data != null && dealsRes.data['data'] != null) {
        final List list = dealsRes.data['data'];
        if (list.isNotEmpty && mounted) {
          setState(() {
            _bestDeals = list.map((item) => Map<String, dynamic>.from(item)).toList();
            if (_bestDeals.length > _itemCount) {
              _itemCount = _bestDeals.length;
            }
          });
        }
      }

      // Fetch dynamic horizontal sponsor banners (Kelipatan 12 produk, 1 - 6 slide)
      final bannerRes = await dio.get('/banners/shop-horizontal');
      if (bannerRes.data != null && bannerRes.data['data'] != null) {
        final List list = bannerRes.data['data'];
        if (mounted) {
          setState(() {
            if (list.isEmpty) {
              _horizontalSponsorBanners = [];
            } else {
              _horizontalSponsorBanners = list.map((item) {
                return {
                  "id": item['id'],
                  "title": item['title'] ?? '',
                  "sponsor": item['sponsor_name'] ?? item['sponsor']?['name'] ?? 'Sponsor',
                  "tier": (item['tier'] ?? item['sponsor']?['tier'] ?? 'PARTNER').toString().toUpperCase(),
                  "image": item['media_path'] ?? 'assets/images/banner_braderparts.png',
                  "media_type": item['media_type'] ?? 'image',
                  "link": item['target_url'] ?? 'https://shopee.co.id',
                };
              }).toList();
            }
          });
        }
      }
    } catch (_) {
      // Offline fallback
    }
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
    final effectiveItemCount = _itemCount.clamp(
      0,
      filteredProducts.isNotEmpty ? filteredProducts.length * 3 : 12,
    );

    return Scaffold(
      backgroundColor: _bgLight,
      body: RefreshIndicator(
        onRefresh: _fetchActiveEvent,
        color: _primaryBlue,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
          // --- 1. Header ---
          const HomeHeaderSliver(),

          // --- 1.1 Promo Event Ticker (Disinkronkan langsung dari DB Web Event) ---
          if (_activeEvent != null && _activeEvent!['has_active'] == true)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFD761A), Color(0xFFE05300)],
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                _activeEvent!['name'] ?? "Flash Event Akhir Pekan",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "HEMAT ${_activeEvent!['value']}%",
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
                            _activeEvent!['banner_text'] ??
                                "FLASH EVENT - HEMAT 15% SEMUA PART RESMI",
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
                      color: Colors.white70,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),

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
                  _buildQuickFilter(
                    Icons.build_rounded,
                    _primaryBlue,
                    "Semua Alat",
                    "200+ produk",
                    isActive: _selectedCategory == "Semua",
                    onTap: () {
                      setState(() {
                        _selectedCategory = "Semua";
                      });
                      _scrollController.animateTo(
                        400,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildQuickFilter(
                    Icons.workspace_premium_rounded,
                    Colors.orange.shade800,
                    "Best Deal",
                    "Diskon terbaik",
                    isHot: true,
                    isActive: false,
                    onTap: () {
                      _scrollController.animateTo(
                        350,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildQuickFilter(
                    Icons.storefront_rounded,
                    Colors.green,
                    "Mitra Resmi",
                    "Produk Terjamin",
                    isActive: false,
                    onTap: () {
                      _scrollController.animateTo(
                        250,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
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
                  _buildCategoryIcon(
                    Icons.battery_charging_full_rounded,
                    "Baterai",
                  ),
                  _buildCategoryIcon(
                    Icons.electrical_services_rounded,
                    "Konektor\nCharging",
                  ),
                  _buildCategoryIcon(Icons.handyman_rounded, "Tools & Alat"),
                  _buildCategoryIcon(Icons.headphones_rounded, "Aksesoris"),
                ],
              ),
            ),
          ),

          // --- 4. Brand & Partner Resmi (Urut Tingkat Tertinggi, Deskripsi & Semua Produk) ---
          const SliverToBoxAdapter(
            child: _BrandPartnerShowcase(),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_orangeSale, const Color(0xFFFF9800)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: _orangeSale.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "BEST DEAL",
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
                      if (_activeEvent != null && _activeEvent!['has_active'] == true) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
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
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            "Lihat Semua",
                            style: TextStyle(
                              color: _primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: _primaryBlue,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _bestDeals.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        final item = _bestDeals[idx];
                        final origPrice = _formatRupiah(item['price'] ?? 0);
                        final discPrice = _formatRupiah(item['discount_price'] ?? item['price'] ?? 0);
                        final discPercent = "${item['discount_percentage'] ?? 15}%";
                        return _buildFlashSaleCard(
                          item['name'] ?? '',
                          discPrice,
                          origPrice,
                          discPercent,
                          item['image'] ?? 'assets/images/product_battery.png',
                        );
                      },
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
                  Text(
                    "Rekomendasi Untukmu",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  if (_selectedCategory != "Semua") ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCategory,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = "Semua"),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: _primaryBlue,
                            ),
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
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      ),
    );
  }

  // --- Build Recommendation Slivers with sparse sponsor banners ---
  List<Widget> _buildRecommendationSlivers(
    List<Map<String, String>> products,
    int totalCount,
  ) {
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
              final int? promoDiscount = (_activeEvent != null && _activeEvent!['has_active'] == true)
                  ? (_activeEvent!['value'] as num?)?.toInt()
                  : null;
              return _buildProductCard(
                context,
                product,
                promoDiscount: promoDiscount,
              );
            }, childCount: count),
          ),
        ),
      );

      // Sisipkan sponsor banner setiap 2 grup (kelipatan 12 produk)
      if (end < totalCount && groupIndex % 2 == 1 && _horizontalSponsorBanners.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: _buildSponsorBanner(groupIndex)));
      }

      groupIndex++;
      i = end;
    }
    return slivers;
  }

  // Backlog 2.2: Dynamic horizontal sponsor banners (1 - 6 slides)
  List<Map<String, dynamic>> _horizontalSponsorBanners = [
    {
      "title": "Diskon Akbar BraderParts 30%",
      "sponsor": "BraderParts Indonesia",
      "tier": "PLATINUM",
      "image": "assets/images/banner_braderparts.png",
      "link": "https://shopee.co.id/brader_parts",
    },
    {
      "title": "TITAN Tools: Peralatan Presisi Teknisi",
      "sponsor": "TITAN Tools Official",
      "tier": "GOLD",
      "image": "assets/images/banner_promo_diskon.png",
      "link": "https://tokopedia.com",
    },
  ];

  // --- Sponsor Banner Carousel (disisipkan setiap 12 card produk - rasio sama persis dengan Beranda) ---
  Widget _buildSponsorBanner(int groupIndex) {
    return HorizontalSponsorSlider(
      banners: _horizontalSponsorBanners,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      aspectRatio: 2.7, // Disesuaikan persis dengan ukuran horizontal slider di Beranda
      borderRadius: 12,
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
            "link":
                "https://shopee.co.id/Braderparts-Baterai-Battery-Batre-BL-58BX-for-Infinix-Hot-9-Play-Hot-10-Play-Hot-10S-Hot-11-Play-Hot-12-Play-i.57356590.22913463095?extraParams=%7B%22display_model_id%22%3A350188294975%2C%22model_selection_logic%22%3A3%7D&sp_atk=f8d0ca69-2d93-4324-b982-5cd7d983550e&xptdk=f8d0ca69-2d93-4324-b982-5cd7d983550e",
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: assetImage.startsWith('http')
                          ? Image.network(
                              assetImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.phone_android_rounded,
                                      color: Colors.grey,
                                      size: 36,
                                    ),
                                  ),
                            )
                          : Image.asset(
                              assetImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.phone_android_rounded,
                                      color: Colors.grey,
                                      size: 36,
                                    ),
                                  ),
                            ),
                    ),
                  ),
                  if (discount != "0%" && discount != "0")
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          discount,
                          style: const TextStyle(
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  if (discount != "0%" && discount != "0") ...[
                    const SizedBox(height: 2),
                    Text(
                      originalPrice,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade400,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _orangeSale,
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

  // --- Quick Filter with active state ---
  Widget _buildQuickFilter(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle, {
    bool isHot = false,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
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
                color: isActive
                    ? _primaryBlue.withValues(alpha: 0.12)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? _primaryBlue : Colors.grey.shade200,
                  width: isActive ? 2.5 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: 0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                        ),
                      ],
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
    int? promoDiscount,
  }) {
    final bool isPromoXtra = promoDiscount != null && promoDiscount > 0;
    final String title = product["name"]!;
    final String price = product["price"]!;
    final String rating = product["rating"]!;
    final String sold = product["sold"]!;
    final String image = product["image"]!;

    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: product),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200, // placeholder background
        ),
        clipBehavior: Clip.antiAlias, // ensure image respects border radius
        child: Stack(
          children: [
            // 1. Background Image Full Card
            Positioned.fill(
              child: image.startsWith('http')
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.image, color: Colors.grey)),
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.image, color: Colors.grey)),
                    ),
            ),
            // 2. Gradient Overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // 3. Badges at top & Wishlist Toggle (Backlog 2.3 & 2.4)
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "PRODUK",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isPromoXtra) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _orangeSale,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "HEMAT $promoDiscount%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Wishlist Toggle Heart Button (Backlog 2.3)
                  GestureDetector(
                    onTap: () {
                      WishlistHelper.toggleWishlist(context, {
                        "name": title,
                        "price": price,
                        "image": image,
                        "link": product["link"] ?? "https://shopee.co.id/brader_parts",
                      });
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        WishlistHelper.isWishlisted(title)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: WishlistHelper.isWishlisted(title)
                            ? Colors.red
                            : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 4. Info Area at bottom
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Store/Brand Name (using a generic yellow store title for now as mockup)
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_rounded,
                        color: Colors.amber,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "TITAN Tools", // Mocked store name
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Product Name
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Rating & Sold
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$rating • $sold terjual",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Price with Strike-through on Active Event (Backlog 2.4)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPromoXtra) ...[
                        const SizedBox(width: 6),
                          Text(
                            "Rp${((int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 100000) / (1.0 - (promoDiscount / 100.0))).round()}"
                                .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.'),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.white70,
                          ),
                        ),
                      ],
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

// --- Brand & Partner Resmi Showcase (Urut Tingkat Tertinggi, Deskripsi & Semua Produk) ---
class _BrandPartnerShowcase extends StatefulWidget {
  const _BrandPartnerShowcase();

  @override
  State<_BrandPartnerShowcase> createState() => _BrandPartnerShowcaseState();
}

class _BrandPartnerShowcaseState extends State<_BrandPartnerShowcase> {
  int _selectedBrandIndex = 0;

  // Data Brand & Partner Resmi diurutkan dari tingkat tertinggi (Platinum -> Gold -> Silver -> Partner)
  List<Map<String, dynamic>> _partners = [
    {
      "name": "BraderParts Indonesia",
      "short_name": "BraderParts",
      "tier": "PLATINUM",
      "tier_label": "PLATINUM SPONSOR",
      "tier_rank": 1,
      "color": const Color(0xFF6C5CE7), // Luxury Platinum Royal Indigo
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
    },
    {
      "name": "TITAN Tools Official",
      "short_name": "TITAN Tools",
      "tier": "GOLD",
      "tier_label": "GOLD SPONSOR",
      "tier_rank": 2,
      "color": const Color(0xFFFD761A), // Vibrant Gold/Amber
      "verified": true,
      "logo": "assets/images/logo_titan.png",
      "description":
          "Spesialis peralatan teknisi handphone presisi tinggi: solder digital cerdas T12, blower hot air gun Quick, mikroskop optik stereo RF4, dan perkakas standar industri servis modern.",
      "website_url": "https://shopee.co.id/titan_tools",
      "products": [
        {
          "name": "Solder Listrik T12 Digital Auto Sleep",
          "price": 389000,
          "category": "Tools & Alat",
          "image": "assets/images/product_1.png",
          "rating": "4.9",
          "sold": "270+",
          "link": "https://shopee.co.id/titan_tools",
        },
        {
          "name": "Blower Quick 857D Hot Air Gun Digital",
          "price": 850000,
          "category": "Tools & Alat",
          "image": "assets/images/product_1.png",
          "rating": "4.9",
          "sold": "180+",
          "link": "https://shopee.co.id/titan_tools",
        },
        {
          "name": "Obeng Set Magnetik 24 in 1 Presisi S2 Steel",
          "price": 45000,
          "category": "Tools & Alat",
          "image": "assets/images/product_1.png",
          "rating": "4.8",
          "sold": "850+",
          "link": "https://shopee.co.id/titan_tools",
        },
        {
          "name": "Flux Amtech NC-559-ASM Original 10cc",
          "price": 85000,
          "category": "Tools & Alat",
          "image": "assets/images/product_1.png",
          "rating": "4.9",
          "sold": "620+",
          "link": "https://shopee.co.id/titan_tools",
        },
        {
          "name": "Mikroskop Stereo Trinokuler RF4 7-50X HD",
          "price": 2850000,
          "category": "Tools & Alat",
          "image": "assets/images/product_1.png",
          "rating": "5.0",
          "sold": "95+",
          "link": "https://shopee.co.id/titan_tools",
        },
        {
          "name": "Lem LCD Touchscreen T-7000 Hitam 50ml",
          "price": 25000,
          "category": "Tools & Alat",
          "image": "assets/images/product_1.png",
          "rating": "4.9",
          "sold": "1200+",
          "link": "https://shopee.co.id/titan_tools",
        },
      ],
    },
    {
      "name": "BT-ACC Battery Super",
      "short_name": "BT-ACC Battery",
      "tier": "GOLD",
      "tier_label": "GOLD SPONSOR",
      "tier_rank": 2,
      "color": const Color(0xFF03AC0E), // Emerald Gold
      "verified": true,
      "logo": "assets/images/logo_btacc.png",
      "description":
          "Pusat baterai smartphone original double IC protection dengan kapasitas murni, tidak cepat kembung, awet seharian, dan bergaransi retur langsung tanpa ribet.",
      "website_url": "https://shopee.co.id",
      "products": [
        {
          "name": "Baterai Samsung S20 Ultra Original IC Pure",
          "price": 249000,
          "category": "Baterai",
          "image": "assets/images/product_battery.png",
          "rating": "4.9",
          "sold": "310+",
          "link": "https://shopee.co.id",
        },
        {
          "name": "Baterai iPhone 11 High Capacity 3500mAh",
          "price": 210000,
          "category": "Baterai",
          "image": "assets/images/product_battery.png",
          "rating": "4.8",
          "sold": "240+",
          "link": "https://shopee.co.id",
        },
        {
          "name": "Baterai Xiaomi Redmi Note 10 Pro BN53 Ori",
          "price": 185000,
          "category": "Baterai",
          "image": "assets/images/product_battery.png",
          "rating": "4.9",
          "sold": "190+",
          "link": "https://shopee.co.id",
        },
      ],
    },
    {
      "name": "Sunshine Tools",
      "short_name": "Sunshine",
      "tier": "SILVER",
      "tier_label": "SILVER SPONSOR",
      "tier_rank": 3,
      "color": const Color(0xFF718096), // Silver Slate
      "verified": true,
      "logo": "assets/images/logo_sunshine.png",
      "description":
          "Brand global terpercaya untuk mesin pemisah LCD rotari 360, power supply cerdas, lampu UV lem jumper cepat, dan perlengkapan servis ponsel berkualitas tinggi.",
      "website_url": "https://shopee.co.id",
      "products": [
        {
          "name": "Mesin Pemisah LCD Separator Sunshine S-918F Plus",
          "price": 890000,
          "category": "Tools & Alat",
          "image": "assets/images/product_1.png",
          "rating": "4.9",
          "sold": "140+",
          "link": "https://shopee.co.id",
        },
        {
          "name": "Sunshine Mini Intelligent UV Curing Lamp SS-014",
          "price": 95000,
          "category": "Tools & Alat",
          "image": "assets/images/product_1.png",
          "rating": "4.8",
          "sold": "380+",
          "link": "https://shopee.co.id",
        },
      ],
    },
    {
      "name": "Borneo Schematics",
      "short_name": "Borneo Schematics",
      "tier": "SILVER",
      "tier_label": "SILVER SPONSOR",
      "tier_rank": 3,
      "color": const Color(0xFF4A5568), // Silver Blue
      "verified": true,
      "logo": "assets/images/logo_borneo.png",
      "description":
          "Platform skematik hardware, panduan jalur PCB smartphone, bitmap layout, dan pengukuran tegangan paling lengkap di dunia untuk teknisi pemula hingga mahir.",
      "website_url": "https://borneoschematics.com",
      "products": [
        {
          "name": "Aktivasi Borneo Schematics 1 Tahun (Single User)",
          "price": 650000,
          "category": "Software Tools",
          "image": "assets/images/logo_borneo.png",
          "rating": "5.0",
          "sold": "720+",
          "link": "https://borneoschematics.com",
        },
        {
          "name": "Aktivasi Borneo Schematics 6 Bulan",
          "price": 390000,
          "category": "Software Tools",
          "image": "assets/images/logo_borneo.png",
          "rating": "4.9",
          "sold": "450+",
          "link": "https://borneoschematics.com",
        },
      ],
    },
    {
      "name": "Pragmafix Software",
      "short_name": "Pragmafix",
      "tier": "PARTNER",
      "tier_label": "OFFICIAL PARTNER",
      "tier_rank": 4,
      "color": const Color(0xFF3182CE), // Partner Blue
      "verified": true,
      "logo": "assets/images/logo_pragmafix.png",
      "description":
          "Solusi software diagnosa, skematik multi-fungsi, dan analisa kerusakan hardware smartphone dengan cepat, praktis, dan petunjuk visual langkah demi langkah.",
      "website_url": "https://pragmafix.com",
      "products": [
        {
          "name": "Aktivasi Lisensi Pragmafix 1 Tahun (2 PC Login)",
          "price": 550000,
          "category": "Software Tools",
          "image": "assets/images/logo_pragmafix.png",
          "rating": "4.8",
          "sold": "310+",
          "link": "https://pragmafix.com",
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchPartnersFromApi();
  }

  Future<void> _fetchPartnersFromApi() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api/v1',
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      final res = await dio.get('/sponsors/partners');
      if (res.data != null && res.data['data'] != null) {
        final List list = res.data['data'];
        if (list.isNotEmpty && mounted) {
          setState(() {
            _partners = list.map((item) {
              final tier = (item['tier'] ?? 'PARTNER').toString().toUpperCase();
              Color color = const Color(0xFF3182CE);
              if (tier == 'PLATINUM') color = const Color(0xFF6C5CE7);
              if (tier == 'GOLD') color = const Color(0xFFFD761A);
              if (tier == 'SILVER') color = const Color(0xFF718096);

              final List prods = (item['products'] as List?) ?? [];
              return {
                "name": item['name'] ?? '',
                "short_name": (item['name'] ?? '').toString().split(' ').first,
                "tier": tier,
                "tier_label": item['tier_label'] ?? '$tier SPONSOR',
                "color": color,
                "verified": true,
                "logo": item['logo'] ?? 'assets/images/logo_braderparts.png',
                "description": item['description'] ?? '',
                "website_url": item['website_url'] ?? 'https://shopee.co.id',
                "products": prods.map((p) {
                  return {
                    "name": p['name'] ?? '',
                    "price": p['price'] ?? 0,
                    "category": p['category'] ?? 'Sparepart',
                    "image": p['image'] ?? 'assets/images/product_1.png',
                    "rating": (p['rating'] ?? '4.9').toString(),
                    "sold": (p['sold'] ?? '150+').toString(),
                    "link": p['link'] ?? 'https://shopee.co.id',
                  };
                }).toList(),
              };
            }).toList();
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_partners.isEmpty) return const SizedBox.shrink();

    final selected = _partners[_selectedBrandIndex.clamp(0, _partners.length - 1)];
    final Color brandColor = (selected["color"] as Color?) ?? const Color(0xFF1B4F9B);
    final String tier = (selected["tier"] ?? "PARTNER").toString();
    final List products = (selected["products"] as List?) ?? [];

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Judul & Status Urutan Tingkat Tertinggi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: const Color(0xFF1B4F9B),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Brand & Partner Resmi",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF001944),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Urutan mitra sponsor dari tingkat tertinggi ke terendah",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4F9B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "OFFICIAL",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F9B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Horizontal Selector Cards (Urutan Tingkat Tertinggi: Platinum -> Gold -> Silver -> Partner)
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: _partners.length,
              itemBuilder: (context, index) {
                final p = _partners[index];
                final bool isSelected = _selectedBrandIndex == index;
                final Color pColor = (p["color"] as Color?) ?? const Color(0xFF1B4F9B);
                final String pTier = (p["tier"] ?? "PARTNER").toString();

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBrandIndex = index;
                    });
                  },
                  onDoubleTap: () {
                    context.push('/sponsor-detail', extra: p);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 104,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? pColor.withValues(alpha: 0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? pColor : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: pColor.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 3,
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Lingkaran
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: isSelected ? pColor : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: (p["logo"] != null && (p["logo"] as String).startsWith('http'))
                                    ? Image.network(
                                        p["logo"],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(Icons.store, size: 20, color: pColor),
                                      )
                                    : Image.asset(
                                        p["logo"] ?? 'assets/images/logo_braderparts.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(Icons.store, size: 20, color: pColor),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.2),
                                ),
                                child: const Icon(Icons.check, size: 7, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p["short_name"] ?? p["name"] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? const Color(0xFF001944) : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Badge Tingkat/Tier
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: pColor.withValues(alpha: isSelected ? 0.9 : 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pTier,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : pColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // 3. Compact Banner Toko Sponsor (Klik "Kunjungi Toko" untuk membuka Halaman Tersendiri)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.push('/sponsor-detail', extra: selected);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      brandColor.withValues(alpha: 0.08),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandColor.withValues(alpha: 0.3), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: brandColor.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Logo Lingkaran
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: brandColor.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: ClipOval(
                        child: (selected["logo"] != null && (selected["logo"] as String).startsWith('http'))
                            ? Image.network(
                                selected["logo"],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.store, color: brandColor),
                              )
                            : Image.asset(
                                selected["logo"] ?? 'assets/images/logo_braderparts.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.store, color: brandColor),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  selected["name"] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF001944),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.verified_rounded, size: 15, color: brandColor),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: brandColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: brandColor.withValues(alpha: 0.25)),
                                ),
                                child: Text(
                                  (selected["tier_label"] ?? "$tier SPONSOR").toString(),
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: brandColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "• ${products.length} Produk Resmi",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Kunjungi Toko -> Membuka Halaman Baru
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/sponsor-detail', extra: selected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.storefront_rounded, size: 14),
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Kunjungi Toko",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
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
