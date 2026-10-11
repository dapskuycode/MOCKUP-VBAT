import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';
import 'package:vbat_ponsel/core/widgets/horizontal_sponsor_slider.dart';
import 'package:vbat_ponsel/core/widgets/event_promo_carousel.dart';
import 'package:vbat_ponsel/core/widgets/sponsor_tier_badge.dart';
import 'package:vbat_ponsel/features/home/presentation/pages/home_header_sliver.dart';
import 'package:vbat_ponsel/features/shop/data/repositories/feed_repository.dart';
import 'package:vbat_ponsel/core/utils/sponsor_tier_store.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _orangeSale = const Color(0xFFFD761A);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  // Active Discount Event from Web Database (Synced dynamically with Laravel Web)
  Map<String, dynamic>? _activeEvent = {
    "has_active": false,
  };
  List<Map<String, dynamic>> _activeEvents = [];

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  String? _nextShopCursor;
  bool _hasMoreShopItems = true;

  // Products currently displayed in the randomized infinite scroll grid
  final List<Map<String, String>> _displayedProducts = [];

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

  // Dynamic all store products for main catalog
  List<Map<String, dynamic>> _catalogProducts = [];

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

  List<Map<String, String>> get _availableFilteredProducts {
    final sourceList = _catalogProducts.isNotEmpty ? _catalogProducts : _bestDeals;
    final list = sourceList.map((p) {
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

  // Acak & tambahkan sejumlah produk ke grid yang sedang tampil
  void _appendRandomBatch(int count) {
    final candidates = _availableFilteredProducts;
    if (candidates.isEmpty) return;
    final random = Random();
    // Shuffled pool untuk variasi acak natural tanpa duplikasi beruntun
    final pool = List<Map<String, String>>.from(candidates)..shuffle(random);
    for (int i = 0; i < count; i++) {
      _displayedProducts.add(Map<String, String>.from(pool[i % pool.length]));
    }
  }

  // Reset dan muat ulang produk acak awal (misal saat buka halaman atau ganti kategori)
  void _resetAndPopulateDisplayedProducts() {
    _displayedProducts.clear();
    _appendRandomBatch(14);
  }

  void _selectCategory(String cat) {
    setState(() {
      _selectedCategory = cat;
      _resetAndPopulateDisplayedProducts();
    });
  }

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    _resetAndPopulateDisplayedProducts();
    _fetchActiveEvent();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 400) {
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

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchActiveEvent() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final res = await dio.get('/shop/events/active');
      if (res.data != null && res.data['has_active_event'] == true) {
        final List rawEvents = res.data['events'] ?? (res.data['data'] != null ? [res.data['data']] : []);
        final parsedEvents = rawEvents.map((e) => Map<String, dynamic>.from(e)).toList();
        if (mounted) {
          setState(() {
            _activeEvents = parsedEvents;
            if (parsedEvents.isNotEmpty) {
              _activeEvent = {
                "id": parsedEvents.first['id'],
                "name": parsedEvents.first['name'],
                "value": parsedEvents.first['value'],
                "banner_text": parsedEvents.first['banner_text'],
                "has_active": true,
              };
            }
          });
        }
      } else if (res.data != null && res.data['has_active_event'] == false) {
        if (mounted) {
          setState(() {
            _activeEvents = [];
            _activeEvent = {"has_active": false};
          });
        }
      }

      // Fetch dynamic products with calculated event discount (Best Deals)
      final dealsRes = await dio.get('/shop/best-deals');
      if (dealsRes.data != null && dealsRes.data['data'] != null) {
        final List list = dealsRes.data['data'];
        if (list.isNotEmpty && mounted) {
          setState(() {
            _bestDeals = list.map((item) => Map<String, dynamic>.from(item)).toList();
          });
        }
      }

      // Fetch all store products for main catalog
      try {
        final prodsRes = await dio.get('/shop/products');
        if (prodsRes.data != null && prodsRes.data['data'] != null) {
          final List list = prodsRes.data['data'];
          if (list.isNotEmpty && mounted) {
            setState(() {
              _catalogProducts = list.map((item) => Map<String, dynamic>.from(item)).toList();
              _resetAndPopulateDisplayedProducts();
            });
          }
        }
      } catch (_) {}

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

    // Initial Shop Feed from FeedRepository
    try {
      final initialFeed = await FeedRepository.getShopFeed(perPage: 12);
      if (mounted && initialFeed.items.isNotEmpty) {
        setState(() {
          _nextShopCursor = initialFeed.nextCursor;
          _hasMoreShopItems = initialFeed.hasMore;
          
          final existingNames = _catalogProducts.map((p) => p['name']).toSet();
          for (final item in initialFeed.items) {
            if (!existingNames.contains(item['name'])) {
              _catalogProducts.add(item);
              existingNames.add(item['name']);
            }
          }
          _resetAndPopulateDisplayedProducts();
        });
      }
    } catch (_) {}
  }

  void _loadMore() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    // Cek feed berikutnya dari backend jika cursor masih tersedia
    if (_hasMoreShopItems && _nextShopCursor != null) {
      try {
        final feedRes = await FeedRepository.getShopFeed(
          cursor: _nextShopCursor,
          perPage: 8,
        );

        if (mounted) {
          _nextShopCursor = feedRes.nextCursor;
          _hasMoreShopItems = feedRes.hasMore;

          final existingNames = _catalogProducts.map((p) => p['name']).toSet();
          for (final item in feedRes.items) {
            if (!existingNames.contains(item['name'])) {
              _catalogProducts.add(item);
              existingNames.add(item['name']);
            }
          }
        }
      } catch (_) {}
    }

    // Delay shimmer loading halus 600ms, lalu suntikkan 8 produk acak baru (Infinity Scroll)
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _appendRandomBatch(8);
      _isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
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
    if (_displayedProducts.isEmpty && _availableFilteredProducts.isNotEmpty) {
      _resetAndPopulateDisplayedProducts();
    }

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

          // --- 1.1 Promo Event Ticker & Carousel (Disinkronkan langsung dari DB Web Event - EVENT-02) ---
          if (_activeEvents.isNotEmpty)
            SliverToBoxAdapter(
              child: EventPromoCarousel(
                events: _activeEvents,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                      _selectCategory("Semua");
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
                      context.push('/best-deals');
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
              color: _cardColor,
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
                      InkWell(
                        onTap: () {
                          context.push('/best-deals');
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                        ),
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
                            onTap: () => _selectCategory("Semua"),
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

          // --- 7. Grid Rekomendasi with sponsor banners (Acak & Infinity Scroll) ---
          ..._buildRecommendationSlivers(_displayedProducts),

          // Empty state jika kategori terpilih belum memiliki produk
          if (_displayedProducts.isEmpty && !_isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: _textGray.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        "Belum ada produk untuk kategori ini",
                        style: TextStyle(color: _textGray, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),

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
  ) {
    List<Widget> slivers = [];
    int groupSize = 6;
    int groupIndex = 0;
    int i = 0;
    int totalCount = products.length;

    while (i < totalCount) {
      final int startIndex = i;
      final int end = (startIndex + groupSize < totalCount) ? startIndex + groupSize : totalCount;
      final int count = end - startIndex;

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
              final productIndex = (startIndex + index) % products.length;
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
          color: _isDark ? const Color(0xFF243042) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
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
                      color: _isDark ? const Color(0xFF1E2430) : Colors.grey.shade50,
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
          color: isActive 
              ? _primaryBlue.withValues(alpha: 0.15) 
              : (_isDark ? const Color(0xFF243042) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? _primaryBlue : _borderColor,
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
                          color: isActive ? (_isDark ? const Color(0xFF60A5FA) : _primaryBlue) : _textDark,
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
        if (_selectedCategory == mappedKey) {
          _selectCategory("Semua"); // Toggle off
        } else {
          _selectCategory(mappedKey);
        }
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
                    ? _primaryBlue.withValues(alpha: 0.2)
                    : (_isDark ? const Color(0xFF243042) : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? (_isDark ? const Color(0xFF60A5FA) : _primaryBlue) : _borderColor,
                  width: isActive ? 2.5 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: 0.2),
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
              child: Icon(
                icon, 
                color: isActive 
                    ? (_isDark ? const Color(0xFF60A5FA) : _primaryBlue) 
                    : (_isDark ? const Color(0xFF90CDF4) : _primaryBlue), 
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? (_isDark ? const Color(0xFF60A5FA) : _primaryBlue) : _textDark,
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

  bool get _isDark => ThemeManager.isDark(context);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : Colors.grey.shade600;

  /// Daftar mitra. Selalu diisi dari API /sponsors/partners.
  ///
  /// CW-09: tidak ada lagi daftar mitra, produk, harga, atau tautan contoh
  /// yang dipatok di kode. Bila API tidak mengembalikan data, bagian ini tidak
  /// ditampilkan sama sekali sehingga aplikasi tidak pernah menayangkan mitra
  /// yang tidak ada.
  List<Map<String, dynamic>> _partners = [];

  final ScrollController _partnerScrollController = ScrollController();
  Timer? _partnerAutoSlideTimer;

  /// UI-02: menggeser daftar mitra otomatis agar tidak terkesan statis.
  /// Berhenti saat pengguna sedang menggeser, lalu lanjut lagi setelahnya.
  void _startPartnerAutoSlide() {
    _partnerAutoSlideTimer?.cancel();
    if (_partners.length < 2) return;
    _partnerAutoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_partnerScrollController.hasClients) return;
      final max = _partnerScrollController.position.maxScrollExtent;
      if (max <= 0) return;
      final current = _partnerScrollController.offset;
      final next = current + 108;
      _partnerScrollController.animateTo(
        next > max ? 0 : next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    // Berhenti otomatis saat pengguna menggeser, lalu lanjut lagi.
    _partnerScrollController.addListener(() {
      if (_partnerAutoSlideTimer != null) {
        _startPartnerAutoSlide();
      }
    });
    _fetchPartnersFromApi();
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    _partnerAutoSlideTimer?.cancel();
    _partnerScrollController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchPartnersFromApi() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
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
              // Warna tier dibaca dari server bila dikirim; kalau tidak,
              // memakai warna cadangan aplikasi (WR-01: warna hanya untuk
              // badge/label, bukan latar halaman).
              if (item['tier_color'] != null &&
                  item['tier_color'].toString().startsWith('#')) {
                try {
                  color = Color(
                    int.parse(
                      item['tier_color'].toString().replaceFirst('#', '0xFF'),
                    ),
                  );
                } catch (_) {}
              }

              final List prods = (item['products'] as List?) ?? [];
              return {
                "id": item['id'],
                "name": item['name'] ?? '',
                "short_name": item['short_name'] ??
                    (item['name'] ?? '').toString().split(' ').first,
                "tier": tier,
                "tier_label": item['tier_label'] ?? tier,
                "color": color,
                "verified": item['verified'] ?? true,
                // CW-09: tidak ada jalur logo contoh. Bila kosong, UI
                // menampilkan ikon toko sebagai gantinya.
                "logo": item['logo'] ?? '',
                "description": item['description'] ?? '',
                // WM-01: website & marketplace dipisah, masing-masing boleh
                // kosong dan tidak akan ditampilkan bila kosong.
                "website_url": item['website_url'] ?? '',
                "marketplace_url": item['marketplace_url'] ?? '',
                "whatsapp": item['whatsapp'],
                "products": prods.map((p) {
                  return {
                    "id": p['id'],
                    "name": p['name'] ?? '',
                    "price": p['price'] ?? 0,
                    "category": p['category'] ?? 'Sparepart',
                    "image": p['image'] ?? '',
                    "rating": (p['rating'] ?? '').toString(),
                    "sold": (p['sold'] ?? '').toString(),
                    "link": p['link'] ?? '',
                  };
                }).toList(),
              };
            }).toList();
          });
          // Mulai geser otomatis setelah data tersedia.
          _startPartnerAutoSlide();
        }
      }
    } catch (_) {
      // CW-09: gagal memuat berarti bagian mitra tidak ditampilkan,
      // bukan menampilkan data contoh.
      if (mounted && _partners.isEmpty) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_partners.isEmpty) return const SizedBox.shrink();

    final selected = _partners[_selectedBrandIndex.clamp(0, _partners.length - 1)];
    final Color brandColor = (selected["color"] as Color?) ?? const Color(0xFF1B4F9B);
    final String tier = (selected["tier"] ?? "PARTNER").toString();
    final List products = (selected["products"] as List?) ?? [];

    return Container(
      color: _cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Judul
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: const Color(0xFF1B4F9B),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      // CW-01: judul baru, tanpa teks penjelas internal.
                      "BRAND PILIHAN UNTUKMU",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                        letterSpacing: 0.3,
                      ),
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

          // 2. Horizontal Selector Cards — UI-02: bergeser otomatis.
          SizedBox(
            height: 110,
            child: ListView.builder(
              controller: _partnerScrollController,
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
                      color: isSelected 
                          ? pColor.withValues(alpha: 0.15) 
                          : (_isDark ? const Color(0xFF243042) : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? pColor : _borderColor,
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
                                color: _isDark ? const Color(0xFF1E2430) : Colors.white,
                                border: Border.all(
                                  color: isSelected ? pColor : (_isDark ? _borderColor : Colors.grey.shade300),
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
                            color: isSelected 
                                ? (_isDark ? Colors.white : const Color(0xFF001944)) 
                                : (_isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Badge Tingkat/Tier Ringkas & Ber-ikon (APP-02)
                        SponsorTierBadge(
                          rawTier: pTier,
                          fontSize: 8,
                          iconSize: 10,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          iconSource: SponsorTierStore.iconFor(pTier),
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
                      brandColor.withValues(alpha: 0.12),
                      _isDark ? const Color(0xFF243042) : Colors.white,
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
                        color: _isDark ? const Color(0xFF1E2430) : Colors.white,
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _textDark,
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
                                  color: _textGray,
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
    final isDark = ThemeManager.isDark(context);
    final shimmerColors = isDark
        ? [const Color(0xFF1E2430), const Color(0xFF2D3748), const Color(0xFF1E2430)]
        : [Colors.grey.shade200, Colors.grey.shade100, Colors.grey.shade200];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF243042) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? ThemeManager.darkBorder : Colors.grey.shade100),
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
                      colors: shimmerColors,
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
                      _buildShimmerBar(width: double.infinity, height: 10, colors: shimmerColors),
                      const SizedBox(height: 6),
                      // Title line 2
                      _buildShimmerBar(width: 100, height: 10, colors: shimmerColors),
                      const Spacer(),
                      // Rating line
                      _buildShimmerBar(width: 80, height: 8, colors: shimmerColors),
                      const SizedBox(height: 6),
                      // Price line
                      _buildShimmerBar(width: 90, height: 14, colors: shimmerColors),
                      const SizedBox(height: 4),
                      // Location line
                      _buildShimmerBar(width: 70, height: 8, colors: shimmerColors),
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

  Widget _buildShimmerBar({
    required double width, 
    required double height, 
    required List<Color> colors,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
          end: Alignment(-1.0 + 2.0 * _controller.value + 1.0, 0),
          colors: colors,
        ),
      ),
    );
  }
}
