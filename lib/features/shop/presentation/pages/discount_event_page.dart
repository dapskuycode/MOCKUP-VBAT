import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';

class DiscountEventPage extends StatefulWidget {
  final Map<String, dynamic>? initialEventData;
  const DiscountEventPage({super.key, this.initialEventData});

  @override
  State<DiscountEventPage> createState() => _DiscountEventPageState();
}

class _DiscountEventPageState extends State<DiscountEventPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _orangeSale = const Color(0xFFFD761A);
  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  bool _isLoading = true;
  Map<String, dynamic>? _event;
  List<Map<String, dynamic>> _products = [];
  String _selectedCategory = "Semua";
  final TextEditingController _searchController = TextEditingController();

  late Timer _countdownTimer;
  Duration _remainingTime = const Duration(hours: 48, minutes: 0, seconds: 0);

  final List<String> _categories = [
    "Semua",
    "LCD & Layar",
    "Baterai",
    "Konektor",
    "Tools",
    "Aksesoris",
  ];

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    _fetchEventData();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        }
      });
    });
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    _countdownTimer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
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

  Future<void> _fetchEventData() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final res = await dio.get('/shop/events/active');
      if (res.data != null && res.data['has_active_event'] == true && res.data['data'] != null) {
        final data = res.data['data'];
        final List rawProds = data['products'] ?? [];
        if (mounted) {
          setState(() {
            _event = data;
            _products = rawProds.map((e) => Map<String, dynamic>.from(e)).toList();
            _isLoading = false;
          });
        }
      } else {
        // Fallback demo items
        _fallbackEvent();
      }
    } catch (_) {
      _fallbackEvent();
    }
  }

  void _fallbackEvent() {
    if (!mounted) return;
    setState(() {
      _event = {
        "name": "FLASH SALE SPESIAL VBAT",
        "type": "percentage",
        "value": 15,
        "banner_text": "DISKON SPESIAL 15% PRODUK PILIHAN!",
      };
      _products = [
        {
          "id": 1,
          "name": "LCD iPhone 11 Pro Max Original Quality",
          "price": 1250000,
          "discount_price": 1062500,
          "discount_percentage": 15,
          "image": "assets/images/product_lcd.png",
          "category": "LCD",
          "sponsor": {"name": "BraderParts", "tier": "PLATINUM"},
          "shopee_url": "https://shopee.co.id/brader_parts",
        },
        {
          "id": 2,
          "name": "Baterai Infinix Hot 9/10/11 Play BL-58BX",
          "price": 145000,
          "discount_price": 123250,
          "discount_percentage": 15,
          "image": "assets/images/product_battery.png",
          "category": "Baterai",
          "sponsor": {"name": "BraderParts", "tier": "PLATINUM"},
          "shopee_url": "https://shopee.co.id/brader_parts",
        },
        {
          "id": 3,
          "name": "Solder Listrik T12 Digital Auto Sleep",
          "price": 389000,
          "discount_price": 330650,
          "discount_percentage": 15,
          "image": "assets/images/product_1.png",
          "category": "Tools",
          "sponsor": {"name": "TITAN Tools", "tier": "GOLD"},
          "shopee_url": "https://shopee.co.id/titan_tools",
        },
        {
          "id": 4,
          "name": "Blower Quick 857D Hot Air Gun Digital",
          "price": 850000,
          "discount_price": 722500,
          "discount_percentage": 15,
          "image": "assets/images/product_1.png",
          "category": "Tools",
          "sponsor": {"name": "TITAN Tools", "tier": "GOLD"},
          "shopee_url": "https://shopee.co.id/titan_tools",
        },
      ];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final cat = (p['category'] ?? '').toString().toLowerCase();

      final matchesQuery = query.isEmpty || name.contains(query);
      final matchesCategory = _selectedCategory == "Semua" ||
          cat.contains(_selectedCategory.toLowerCase()) ||
          name.contains(_selectedCategory.toLowerCase());

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventName = _event?['name'] ?? "Flash Event Diskon";
    final bannerText = _event?['banner_text'] ?? "DISKON SPESIAL UNTUK PRODUK PILIHAN";
    final discountVal = _event?['value'] ?? 15;
    final discountType = _event?['type'] ?? 'percentage';
    final discountLabel = discountType == 'percentage' ? "HEMAT $discountVal%" : "POTONGAN ${_formatRupiah(discountVal)}";

    final displayProducts = _filteredProducts;

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _orangeSale,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          eventName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchEventData,
              color: _orangeSale,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // 1. Hero Event Banner Header
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFD761A), Color(0xFFE05300)],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFD761A), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  discountLabel,
                                  style: const TextStyle(
                                    color: Color(0xFFFD761A),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bannerText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Countdown timer pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                const Text(
                                  "Berakhir dalam: ",
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                                Text(
                                  _formatDuration(_remainingTime),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Search & Category Filters
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        children: [
                          // Search Input
                          Container(
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _borderColor),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: _textDark, fontSize: 13),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: "Cari produk diskon...",
                                hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.7), fontSize: 13),
                                prefixIcon: Icon(Icons.search_rounded, color: _textGray, size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Category Filter Chips
                          SizedBox(
                            height: 34,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 8),
                              itemBuilder: (context, idx) {
                                final cat = _categories[idx];
                                final isSelected = _selectedCategory == cat;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedCategory = cat),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? _orangeSale : _cardColor,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected ? _orangeSale : _borderColor,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        cat,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : _textDark,
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Grid of Discounted Products
                  if (displayProducts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: _textGray.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              "Tidak ada produk diskon untuk kategori ini",
                              style: TextStyle(color: _textGray, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final prod = displayProducts[index];
                            return _buildDiscountCard(context, prod);
                          },
                          childCount: displayProducts.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 60)),
                ],
              ),
            ),
    );
  }

  Widget _buildDiscountCard(BuildContext context, Map<String, dynamic> prod) {
    final name = prod['name'] ?? 'Produk Diskon';
    final origPrice = (prod['price'] as num?) ?? 0;
    final discPrice = (prod['discount_price'] as num?) ?? origPrice;
    final discPercent = (prod['discount_percentage'] as num?)?.toInt() ?? 15;
    final imgPath = (prod['image'] ?? prod['image_path'] ?? '').toString();
    final sponsor = prod['sponsor'] is Map ? prod['sponsor']['name'] : 'Mitra Resmi';

    Widget imgWidget;
    if (imgPath.startsWith('http')) {
      imgWidget = Image.network(
        imgPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(color: _isDark ? Colors.grey.shade900 : Colors.grey.shade100, child: Icon(Icons.broken_image, color: _textGray)),
      );
    } else {
      imgWidget = Image.asset(
        imgPath.isNotEmpty ? imgPath : 'assets/images/product_1.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(color: _isDark ? Colors.grey.shade900 : Colors.grey.shade100, child: Icon(Icons.broken_image, color: _textGray)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            WishlistHelper.openProductMarketplace(
              context,
              productName: name.toString(),
              shopeeUrl: prod['shopee_url']?.toString(),
              tokopediaUrl: prod['tokopedia_url']?.toString(),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with discount badge
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: imgWidget,
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFC62828)]),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Text(
                          "-$discPercent%",
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
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
                      sponsor.toString(),
                      style: TextStyle(color: _isDark ? Colors.blue.shade300 : _primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name.toString(),
                      style: TextStyle(color: _textDark, fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatRupiah(discPrice),
                      style: TextStyle(color: _isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE53935), fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      _formatRupiah(origPrice),
                      style: TextStyle(color: _textGray, fontSize: 10, decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
