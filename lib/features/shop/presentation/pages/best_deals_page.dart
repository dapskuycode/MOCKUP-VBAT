

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';
import 'package:vbat_ponsel/core/widgets/sponsor_tier_badge.dart';
import 'package:vbat_ponsel/core/utils/sponsor_tier_store.dart';

class BestDealsPage extends StatefulWidget {
  const BestDealsPage({super.key});

  @override
  State<BestDealsPage> createState() => _BestDealsPageState();
}

class _BestDealsPageState extends State<BestDealsPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _orangeSale = const Color(0xFFFD761A);
  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  bool _isLoading = true;
  String _programTitle = "BEST DEALS VBAT";
  bool _hasActiveEvent = false;
  String _eventName = "";
  List<Map<String, dynamic>> _products = [];
  String _selectedCategory = "Semua";
  String _sortBy = "default"; // default, discount, price_asc, price_desc
  final TextEditingController _searchController = TextEditingController();

  late Timer _countdownTimer;
  Duration _remainingTime = const Duration(hours: 36, minutes: 45, seconds: 12);

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
    _fetchBestDeals();
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

  Future<void> _fetchBestDeals() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final res = await dio.get('/shop/best-deals');
      if (res.data != null && res.data['data'] != null) {
        final List rawProds = res.data['data'];
        if (mounted) {
          setState(() {
            _programTitle = res.data['program_title'] ?? "BEST DEALS VBAT";
            _hasActiveEvent = res.data['event_active'] == true;
            _eventName = res.data['event_name'] ?? "";
            _products = rawProds.map((e) => Map<String, dynamic>.from(e)).toList();
            _isLoading = false;
          });
        }
      } else {
        _fallbackDeals();
      }
    } catch (_) {
      _fallbackDeals();
    }
  }

  void _fallbackDeals() {
    if (!mounted) return;
    setState(() {
      _programTitle = "BEST DEALS PILIHAN VBAT";
      _hasActiveEvent = true;
      _eventName = "FLASH SALE SPESIAL VBAT";
      _products = [
        {
          "id": 1,
          "name": "LCD iPhone 11 Pro Max Original Quality",
          "category": "LCD",
          "description": "Layar jernih true-tone display dengan respon sentuh 120Hz.",
          "price": 1250000,
          "discount_price": 1062500,
          "discount_percentage": 15,
          "is_event_discount": true,
          "badge": "DISKON 15%",
          "image": "assets/images/product_lcd.png",
          "shopee_url": "https://shopee.co.id/brader_parts",
          "tokopedia_url": "https://tokopedia.com/braderparts",
          "rating": "4.9",
          "sold": "250+",
          "sponsor": {"name": "BraderParts Indonesia", "tier": "PLATINUM"},
        },
        {
          "id": 2,
          "name": "Baterai Infinix Hot 9/10/11 Play BL-58BX Original",
          "category": "Baterai",
          "description": "Baterai replacement berkapasitas 6000mAh pure original IC protection.",
          "price": 145000,
          "discount_price": 123250,
          "discount_percentage": 15,
          "is_event_discount": true,
          "badge": "DISKON 15%",
          "image": "assets/images/product_battery.png",
          "shopee_url": "https://shopee.co.id/brader_parts",
          "tokopedia_url": "https://tokopedia.com/braderparts",
          "rating": "4.9",
          "sold": "1.2k+",
          "sponsor": {"name": "BraderParts Indonesia", "tier": "PLATINUM"},
        },
        {
          "id": 3,
          "name": "Solder Listrik T12 Digital Auto Sleep C210 Fast Heating",
          "category": "Tools",
          "description": "Pemanasan super cepat dalam 2 detik dengan kontrol digital presisi.",
          "price": 389000,
          "discount_price": 330650,
          "discount_percentage": 15,
          "is_event_discount": true,
          "badge": "HOT DEAL",
          "image": "assets/images/product_1.png",
          "shopee_url": "https://shopee.co.id/titan_tools",
          "tokopedia_url": "https://tokopedia.com/titantools",
          "rating": "4.8",
          "sold": "540+",
          "sponsor": {"name": "TITAN Tools", "tier": "GOLD"},
        },
        {
          "id": 4,
          "name": "Blower Quick 857D Hot Air Gun Digital SMD Rework",
          "category": "Tools",
          "description": "Stasiun blower suhu presisi aliran udara halus tidak mudah melepuhkan PCB.",
          "price": 850000,
          "discount_price": 722500,
          "discount_percentage": 15,
          "is_event_discount": true,
          "badge": "BEST SELLER",
          "image": "assets/images/product_1.png",
          "shopee_url": "https://shopee.co.id/titan_tools",
          "tokopedia_url": "https://tokopedia.com/titantools",
          "rating": "5.0",
          "sold": "890+",
          "sponsor": {"name": "TITAN Tools", "tier": "GOLD"},
        },
      ];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredProducts {
    var list = List<Map<String, dynamic>>.from(_products);

    // Filter Kategori
    if (_selectedCategory != "Semua") {
      list = list.where((p) {
        final cat = (p['category'] ?? '').toString().toLowerCase();
        final name = (p['name'] ?? '').toString().toLowerCase();
        final sel = _selectedCategory.toLowerCase();

        if (sel.contains('lcd')) return cat.contains('lcd') || name.contains('lcd') || name.contains('layar');
        if (sel.contains('baterai')) return cat.contains('baterai') || name.contains('baterai') || name.contains('battery');
        if (sel.contains('konektor')) return cat.contains('konektor') || name.contains('konektor') || name.contains('charger') || name.contains('charging');
        if (sel.contains('tools')) return cat.contains('tools') || name.contains('solder') || name.contains('blower') || name.contains('obeng') || name.contains('alat');
        if (sel.contains('aksesoris')) return cat.contains('aksesoris') || name.contains('lem') || name.contains('kawat') || name.contains('tisu');
        return cat.contains(sel) || name.contains(sel);
      }).toList();
    }

    // Filter Search
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((p) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        final desc = (p['description'] ?? '').toString().toLowerCase();
        final sponsor = (p['sponsor'] is Map ? p['sponsor']['name'] ?? '' : '').toString().toLowerCase();
        return name.contains(query) || desc.contains(query) || sponsor.contains(query);
      }).toList();
    }

    // Sorting
    if (_sortBy == 'discount') {
      list.sort((a, b) => ((b['discount_percentage'] as num?) ?? 0).compareTo((a['discount_percentage'] as num?) ?? 0));
    } else if (_sortBy == 'price_asc') {
      list.sort((a, b) => ((a['discount_price'] ?? a['price'] ?? 0) as num).compareTo((b['discount_price'] ?? b['price'] ?? 0) as num));
    } else if (_sortBy == 'price_desc') {
      list.sort((a, b) => ((b['discount_price'] ?? b['price'] ?? 0) as num).compareTo((a['discount_price'] ?? a['price'] ?? 0) as num));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final displayProducts = _filteredProducts;

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Katalog Best Deals",
              style: TextStyle(
                color: _textDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "Rekomendasi harga & kualitas terbaik",
              style: TextStyle(
                color: _textGray,
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border_rounded, color: _textDark),
            onPressed: () => context.push('/wishlist'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchBestDeals,
              color: _primaryBlue,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // --- 1. Header Banner Program Best Deals ---
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0B2B68), Color(0xFF1B4F9B), Color(0xFFD9530F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B4F9B).withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              size: 130,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _orangeSale,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _orangeSale.withValues(alpha: 0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            "BEST DEALS & DISKON",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_hasActiveEvent)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.35),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.timer_outlined, color: Colors.white, size: 13),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDuration(_remainingTime),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _programTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _hasActiveEvent
                                      ? "Diskon terhubung langsung dengan event aktif: $_eventName"
                                      : "Kumpulan suku cadang dan alat servis pilihan dari sponsor resmi VBAT.",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- 2. Search & Sort Bar ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: _isDark ? 0.2 : 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: _textDark, fontSize: 13),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: "Cari produk promo, alat, atau sponsor...",
                                hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.7), fontSize: 13),
                                prefixIcon: Icon(Icons.search_rounded, color: _primaryBlue, size: 20),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear, size: 18, color: _textGray),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Sort pills row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildSortChip("Semua Pilihan", "default"),
                                const SizedBox(width: 8),
                                _buildSortChip("Diskon Tertinggi", "discount"),
                                const SizedBox(width: 8),
                                _buildSortChip("Harga Termurah", "price_asc"),
                                const SizedBox(width: 8),
                                _buildSortChip("Harga Tertinggi", "price_desc"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // --- 3. Kategori Filter Chips ---
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final cat = _categories[idx];
                          final isSelected = _selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : _textDark,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: _primaryBlue,
                            backgroundColor: _cardColor,
                            side: BorderSide(
                              color: isSelected ? _primaryBlue : _borderColor,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            showCheckmark: false,
                            onSelected: (val) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // --- 4. Subtitle Jumlah Produk ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            "Menampilkan ${displayProducts.length} Produk",
                            style: TextStyle(
                              color: _textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Diskon Terverifikasi",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- 5. Grid Produk ---
                  if (displayProducts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              "Tidak ada produk yang cocok dengan pencarian Anda",
                              style: TextStyle(color: _textGray, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final prod = displayProducts[index];
                            return _buildBestDealCard(context, prod);
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

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue.withValues(alpha: 0.15) : _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primaryBlue : _borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? (_isDark ? Colors.blue.shade300 : _primaryBlue) : _textGray,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBestDealCard(BuildContext context, Map<String, dynamic> prod) {
    final name = prod['name'] ?? 'Produk';
    final origPrice = (prod['price'] as num?) ?? 0;
    final discPrice = (prod['discount_price'] as num?) ?? origPrice;
    final discPercent = (prod['discount_percentage'] as num?)?.toInt() ?? 0;
    final hasDiscount = discPercent > 0 && discPrice < origPrice;
    final imgPath = (prod['image'] ?? prod['image_path'] ?? '').toString();
    final sponsor = prod['sponsor'] is Map ? prod['sponsor']['name'] ?? 'Mitra Resmi' : 'Mitra Resmi';
    final tier = prod['sponsor'] is Map ? (prod['sponsor']['tier'] ?? 'PARTNER').toString().toUpperCase() : 'PARTNER';
    final badgeText = prod['badge'] ?? (hasDiscount ? "HEMAT $discPercent%" : "BEST DEAL");

    Widget imgWidget;
    if (imgPath.startsWith('http')) {
      imgWidget = Image.network(
        imgPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: _isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          child: Icon(Icons.broken_image, color: _textGray),
        ),
      );
    } else {
      imgWidget = Image.asset(
        imgPath.isNotEmpty ? imgPath : 'assets/images/product_1.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: _isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          child: Icon(Icons.broken_image, color: _textGray),
        ),
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
              // 1. Gambar & Badge
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
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: hasDiscount
                                ? [const Color(0xFFE53935), const Color(0xFFC62828)]
                                : [const Color(0xFFFD761A), const Color(0xFFE05300)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          badgeText.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    // APP-02: Icon Penanda Visual Tier Resmi
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          SponsorTierBadge.getFallbackIcon(tier),
                          size: 13,
                          color: SponsorTierBadge.getFallbackColor(tier),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Info Detail Produk
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sponsor Name & APP-02 Ringkas Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sponsor.toString(),
                            style: TextStyle(
                              color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SponsorTierBadge(
                          rawTier: tier,
                          fontSize: 7.5,
                          iconSize: 9,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          iconSource: SponsorTierStore.iconFor(tier),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Product Title
                    Text(
                      name.toString(),
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Harga
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatRupiah(discPrice),
                          style: TextStyle(
                            color: hasDiscount ? (_isDark ? const Color(0xFFFF6B6B) : Colors.red.shade700) : _textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(height: 1),
                      Text(
                        _formatRupiah(origPrice),
                        style: TextStyle(
                          color: _textGray,
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),

                    // Rating & Tombol Beli
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          prod['rating']?.toString() ?? '4.9',
                          style: TextStyle(color: _textDark, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${prod['sold']?.toString() ?? '100+'})",
                          style: TextStyle(color: _textGray, fontSize: 9),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEE4D2D).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Beli",
                            style: TextStyle(
                              color: Color(0xFFEE4D2D),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
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
    );
  }
}
