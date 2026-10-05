import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';
import 'package:vbat_ponsel/core/widgets/sponsor_tier_badge.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _orangeSale = const Color(0xFFFD761A);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF8FAFC);
  Color get _surfaceWhite => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF0F172A);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF64748B);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _selectedTab = "Semua";
  String _currentQuery = "";

  final List<String> _recentSearches = [
    "Blower Quick 2008",
    "Skema iPhone 14 Pro Max",
    "IC Power Oppo",
    "LCD iPhone 13",
  ];

  final List<String> _popularSearches = [
    "LCD iPhone",
    "Baterai Samsung",
    "Solder T12",
    "Box Software",
    "IC Power",
    "Borneo Skema",
    "Blower Hot Air",
    "Flux Amtech",
  ];

  // Dynamic sponsor banner from API
  Map<String, dynamic>? _sponsorBanner;
  List<Map<String, dynamic>> _dynamicProducts = [];

  // Static rich database items for search
  final List<Map<String, dynamic>> _allProducts = [
    {
      "type": "product",
      "name": "LCD iPhone 13 Original BraderParts",
      "category": "SPAREPART",
      "price": 450000,
      "originalPrice": 560000,
      "partner": "BraderParts Indonesia",
      "rating": "4.9",
      "sold": "350+",
      "image": "assets/images/product_lcd.png",
      "link": "https://shopee.co.id/brader_parts",
    },
    {
      "type": "product",
      "name": "LCD iPhone 11 Pro Max Original Quality",
      "category": "SPAREPART",
      "price": 1250000,
      "originalPrice": 1400000,
      "partner": "BraderParts Indonesia",
      "rating": "4.9",
      "sold": "180+",
      "image": "assets/images/product_lcd.png",
      "link": "https://shopee.co.id/brader_parts",
    },
    {
      "type": "product",
      "name": "Baterai Infinix Hot 9/10/11 Play BL-58BX",
      "category": "BATERAI",
      "price": 145000,
      "originalPrice": 180000,
      "partner": "BT-ACC Official",
      "rating": "4.8",
      "sold": "500+",
      "image": "assets/images/product_battery.png",
      "link": "https://shopee.co.id",
    },
    {
      "type": "product",
      "name": "Baterai Samsung S20 Ultra Original IC Super",
      "category": "BATERAI",
      "price": 249000,
      "originalPrice": 310000,
      "partner": "BT-ACC Official",
      "rating": "4.9",
      "sold": "240+",
      "image": "assets/images/product_battery.png",
      "link": "https://shopee.co.id",
    },
    {
      "type": "product",
      "name": "Blower Quick 857D / 2008 Hot Air Gun Digital",
      "category": "ALAT SERVIS",
      "price": 850000,
      "originalPrice": 990000,
      "partner": "TITAN Tools",
      "rating": "5.0",
      "sold": "420+",
      "image": "assets/images/product_1.png",
      "link": "https://tokopedia.com/titantools",
    },
    {
      "type": "product",
      "name": "Solder Listrik T12 Digital Auto Sleep Presisi",
      "category": "ALAT SERVIS",
      "price": 389000,
      "originalPrice": 450000,
      "partner": "TITAN Tools",
      "rating": "4.9",
      "sold": "310+",
      "image": "assets/images/product_1.png",
      "link": "https://tokopedia.com/titantools",
    },
    {
      "type": "product",
      "name": "Obeng Set Magnetik 24 in 1 Presisi S2 Teknisi",
      "category": "ALAT SERVIS",
      "price": 45000,
      "originalPrice": 60000,
      "partner": "TITAN Tools",
      "rating": "4.8",
      "sold": "850+",
      "image": "assets/images/product_1.png",
      "link": "https://tokopedia.com/titantools",
    },
    {
      "type": "product",
      "name": "Flux Amtech NC-559-ASM 10cc Original BGA Solder",
      "category": "KONSUMABEL",
      "price": 85000,
      "originalPrice": 105000,
      "partner": "Master Tech",
      "rating": "4.9",
      "sold": "600+",
      "image": "assets/images/product_1.png",
      "link": "https://shopee.co.id",
    },
    {
      "type": "product",
      "name": "IC Power PM8150 Qualcomm Snapdragon CPU Power",
      "category": "SPAREPART IC",
      "price": 65000,
      "originalPrice": 80000,
      "partner": "BraderParts Indonesia",
      "rating": "4.8",
      "sold": "190+",
      "image": "assets/images/product_1.png",
      "link": "https://shopee.co.id/brader_parts",
    },
  ];

  final List<Map<String, dynamic>> _allCourses = [
    {
      "type": "course",
      "title": "Cara Membaca Skema & Tracking Short VCC_MAIN iPhone 14 Pro Max",
      "instructor": "Instruktur Borneo",
      "duration": "35:00",
      "views": "15.2K",
      "image": "assets/images/course_soldering.png",
      "badge": "GRATIS",
      "badgeColor": Color(0xFF10B981),
      "topic": "Skema Hardware",
    },
    {
      "type": "course",
      "title": "Teknik Jumper Jalur Putus di Bawah IC CPU Snapdragon & IC Power Oppo",
      "instructor": "Teknisi Senior",
      "duration": "28:40",
      "views": "8.1K",
      "image": "assets/images/course_soldering.png",
      "badge": "PREMIUM",
      "badgeColor": Color(0xFF8B5CF6),
      "topic": "Micro Soldering",
    },
    {
      "type": "course",
      "title": "Mastering iPhone 13 Pro Max Dual-Layer Board Reballing",
      "instructor": "Mas VBat",
      "duration": "45:12",
      "views": "12.5K",
      "image": "assets/images/course_soldering.png",
      "badge": "PREMIUM",
      "badgeColor": Color(0xFF8B5CF6),
      "topic": "Hardware Board",
    },
    {
      "type": "course",
      "title": "Pengenalan Blower Quick 2008 & Setup Meja Kerja Teknisi",
      "instructor": "Mas VBat",
      "duration": "15:30",
      "views": "6.4K",
      "image": "assets/images/course_soldering.png",
      "badge": "GRATIS",
      "badgeColor": Color(0xFF10B981),
      "topic": "Perkakas Servis",
    },
    {
      "type": "course",
      "title": "Solusi No Service / Sinyal Hilang pada Android 5G",
      "instructor": "Ahli RF",
      "duration": "40:15",
      "views": "9.8K",
      "image": "assets/images/course_soldering.png",
      "badge": "GRATIS",
      "badgeColor": Color(0xFF10B981),
      "topic": "Jaringan & Sinyal",
    },
  ];

  final List<Map<String, dynamic>> _allBrands = [
    {
      "type": "brand",
      "name": "BraderParts Indonesia",
      "subtitle": "Official Partner Sparepart & LCD Bergaransi",
      "tier": "PLATINUM SPONSOR",
      "verified": true,
      "rating": "4.9",
      "productsCount": "120+ Produk",
      "logo": "assets/images/logo_braderparts.png",
      "link": "https://shopee.co.id/brader_parts",
    },
    {
      "type": "brand",
      "name": "TITAN Tools Official",
      "subtitle": "Peralatan Solder, Blower & Toolkit Presisi Teknisi",
      "tier": "GOLD SPONSOR",
      "verified": true,
      "rating": "4.9",
      "productsCount": "85+ Produk",
      "logo": "assets/images/logo_titan.png",
      "link": "https://tokopedia.com/titantools",
    },
    {
      "type": "brand",
      "name": "BT-ACC Battery Super",
      "subtitle": "Baterai Handphone Kapasitas Murni Garansi 1 Tahun",
      "tier": "SILVER SPONSOR",
      "verified": true,
      "rating": "4.8",
      "productsCount": "64+ Produk",
      "logo": "assets/images/logo_btacc.png",
      "link": "https://shopee.co.id",
    },
    {
      "type": "brand",
      "name": "Borneo Schematics",
      "subtitle": "Software Skema & Solusi Jalur PCB Hardware",
      "tier": "VERIFIED PARTNER",
      "verified": true,
      "rating": "5.0",
      "productsCount": "Aktivasi Resmi",
      "logo": "assets/images/logo_borneo.png",
      "link": "https://borneoschematics.com",
    },
    {
      "type": "brand",
      "name": "Pragmafix",
      "subtitle": "Panduan Interaktif Pelacakan Komponen Handphone",
      "tier": "OFFICIAL PARTNER",
      "verified": true,
      "rating": "4.9",
      "productsCount": "Aktivasi Resmi",
      "logo": "assets/images/logo_pragmafix.png",
      "link": "https://pragmafix.com",
    },
  ];

  final List<Map<String, dynamic>> _allForums = [
    {
      "type": "forum",
      "title": "Review LCD BraderParts vs Original Cabutan iPhone",
      "author": "TeknisiJakarta",
      "time": "2 jam lalu",
      "content":
          "Apakah ada rekan teknisi yang sudah menguji perbandingan kontras warna, refresh rate, dan ketahanan kaca LCD BraderParts dibandingkan ori copotan?",
      "likes": 28,
      "comments": 14,
      "tag": "Diskusi Sparepart",
    },
    {
      "type": "forum",
      "title": "Tips Kalibrasi Panas Blower Quick 2008 & 857D Agar Elemen Awet",
      "author": "VbatMaster",
      "time": "5 jam lalu",
      "content":
          "Rekomendasi setelan angin dan suhu saat mengangkat IC eMMC/UFS dual-board tanpa merusak jalur PCB bawah.",
      "likes": 42,
      "comments": 19,
      "tag": "Tips Alat Servis",
    },
    {
      "type": "forum",
      "title": "Diskusi Jalur IC Power PM8150 Short VDD_CPU",
      "author": "BorneoTeam",
      "time": "1 hari lalu",
      "content":
          "Sharing kasus Poco F3 / Black Shark mati total karena kapasitor bypass dekat IC Power bocor ke ground.",
      "likes": 56,
      "comments": 27,
      "tag": "Hardware Trouble",
    },
  ];

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    _fetchDynamicData();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchDynamicData() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      // 1. Fetch Sponsor Horizontal Banner
      try {
        final bannerRes = await dio.get('/banners/shop-horizontal');
        if (bannerRes.data != null && bannerRes.data['data'] != null) {
          final List list = bannerRes.data['data'];
          if (list.isNotEmpty && mounted) {
            setState(() {
              _sponsorBanner = Map<String, dynamic>.from(list.first);
            });
          }
        }
      } catch (_) {}

      // 2. Fetch Live Products from Database (/shop/products)
      try {
        final dealsRes = await dio.get('/shop/products');
        if (dealsRes.data != null && dealsRes.data['data'] != null) {
          final List list = dealsRes.data['data'];
          if (list.isNotEmpty && mounted) {
            final mapped = list.map<Map<String, dynamic>>((item) {
              return {
                "type": "product",
                "id": item['id'],
                "name": item['name'] ?? '',
                "category": (item['category'] ?? 'ALAT SERVIS').toString().toUpperCase(),
                "price": item['discount_price'] ?? item['price'] ?? 0,
                "originalPrice": item['price'] ?? 0,
                "partner": (item['sponsor'] != null && item['sponsor']['name'] != null)
                    ? item['sponsor']['name']
                    : 'Mitra VBAT',
                "rating": (item['rating'] ?? '4.9').toString(),
                "sold": (item['sold'] ?? '250+').toString(),
                "image": (item['image'] ?? 'assets/images/product_1.png').toString(),
                "link": (item['shopee_url'] ?? item['tokopedia_url'] ?? 'https://shopee.co.id').toString(),
              };
            }).toList();

            setState(() {
              _dynamicProducts = mapped;
            });
          }
        }
      } catch (_) {}
    } catch (_) {}
  }

  void _onSearch(String query) {
    setState(() {
      _currentQuery = query.trim();
      if (_currentQuery.isNotEmpty && !_recentSearches.contains(_currentQuery)) {
        _recentSearches.insert(0, _currentQuery);
        if (_recentSearches.length > 8) {
          _recentSearches.removeLast();
        }
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentQuery = "";
    });
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/');
    }
  }

  // --- Filtering Logic ---
  List<Map<String, dynamic>> get _effectiveProducts {
    if (_dynamicProducts.isEmpty) return _allProducts;
    final dynamicNames = _dynamicProducts.map((p) => p['name'].toString().toLowerCase()).toSet();
    final uniqueStatic = _allProducts.where((p) => !dynamicNames.contains(p['name'].toString().toLowerCase())).toList();
    return [..._dynamicProducts, ...uniqueStatic];
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final products = _effectiveProducts;
    if (_currentQuery.isEmpty) return products;
    final q = _currentQuery.toLowerCase();
    return products.where((p) {
      return p['name'].toString().toLowerCase().contains(q) ||
          p['category'].toString().toLowerCase().contains(q) ||
          p['partner'].toString().toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredCourses {
    if (_currentQuery.isEmpty) return _allCourses;
    final q = _currentQuery.toLowerCase();
    return _allCourses.where((c) {
      return c['title'].toString().toLowerCase().contains(q) ||
          c['instructor'].toString().toLowerCase().contains(q) ||
          c['topic'].toString().toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredBrands {
    if (_currentQuery.isEmpty) return _allBrands;
    final q = _currentQuery.toLowerCase();
    return _allBrands.where((b) {
      return b['name'].toString().toLowerCase().contains(q) ||
          b['subtitle'].toString().toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredForums {
    if (_currentQuery.isEmpty) return _allForums;
    final q = _currentQuery.toLowerCase();
    return _allForums.where((f) {
      return f['title'].toString().toLowerCase().contains(q) ||
          f['content'].toString().toLowerCase().contains(q) ||
          f['tag'].toString().toLowerCase().contains(q);
    }).toList();
  }

  int get _totalResultsCount {
    return _filteredProducts.length +
        _filteredCourses.length +
        _filteredBrands.length +
        _filteredForums.length;
  }

  String _formatRupiah(num val) {
    return "Rp ${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Column(
        children: [
          // --- 1. Top Bar & Tabs (Gradient & Elevated) ---
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [_primaryBlue, const Color(0xFF0F3670)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: [
                // Search Input Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _handleBack,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: _isDark ? const Color(0xFF1E2430) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: _isDark ? Border.all(color: const Color(0xFF2D3748)) : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  autofocus: true,
                                  textInputAction: TextInputAction.search,
                                  onChanged: (val) {
                                    setState(() {
                                      _currentQuery = val.trim();
                                    });
                                  },
                                  onSubmitted: _onSearch,
                                  decoration: InputDecoration(
                                    hintText: "Cari sparepart, kursus, alat servis...",
                                    hintStyle: TextStyle(
                                      color: _textGray,
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: _clearSearch,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: _isDark ? Colors.white70 : Colors.grey.shade600,
                                      size: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          if (_searchController.text.isNotEmpty) {
                            _onSearch(_searchController.text);
                          } else {
                            _handleBack();
                          }
                        },
                        child: Text(
                          _searchController.text.isNotEmpty ? "Cari" : "Batal",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Tabs with Count Badges
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildTabItem("Semua", _currentQuery.isEmpty ? null : _totalResultsCount),
                      _buildTabItem("Produk", _currentQuery.isEmpty ? null : _filteredProducts.length),
                      _buildTabItem("Kursus", _currentQuery.isEmpty ? null : _filteredCourses.length),
                      _buildTabItem("Brand", _currentQuery.isEmpty ? null : _filteredBrands.length),
                      _buildTabItem("Forum", _currentQuery.isEmpty ? null : _filteredForums.length),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- 2. Content Area ---
          Expanded(
            child: _currentQuery.isEmpty
                ? _buildInitialSuggestionsView()
                : _buildSearchResultsView(),
          ),
        ],
      ),
    );
  }

  // --- Header Tab Item ---
  Widget _buildTabItem(String label, int? count) {
    final bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? _orangeSale : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? _orangeSale : Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
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
      ),
    );
  }

  // --- Initial View: Recent & Popular Searches ---
  Widget _buildInitialSuggestionsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. Pencarian Terakhir
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded, color: _primaryBlue, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "Pencarian Terakhir",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                },
                child: Text(
                  "Hapus Semua",
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: _surfaceWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              children: List.generate(_recentSearches.length, (index) {
                final query = _recentSearches[index];
                return InkWell(
                  onTap: () {
                    _searchController.text = query;
                    _onSearch(query);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_rounded, color: _textGray, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            query,
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _recentSearches.removeAt(index);
                            });
                          },
                          child: Icon(Icons.close_rounded, color: _textGray, size: 18),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 2. Pencarian Populer
        Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFD761A), size: 18),
            const SizedBox(width: 6),
            Text(
              "Pencarian Populer",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _textDark,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _popularSearches.map((chip) {
            return InkWell(
              onTap: () {
                _searchController.text = chip;
                _onSearch(chip);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, color: _isDark ? Colors.blue.shade300 : _primaryBlue, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      chip,
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // 3. Rekomendasi Teratas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Rekomendasi Teratas",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _textDark,
                fontSize: 15,
              ),
            ),
            Text(
              "Lihat Semua",
              style: TextStyle(
                color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._allProducts.take(3).map((prod) => _buildProductCard(prod)),
      ],
    );
  }

  // --- Active Search Results View ---
  Widget _buildSearchResultsView() {
    if (_totalResultsCount == 0) {
      return _buildEmptyState();
    }

    if (_selectedTab == "Produk") {
      return _filteredProducts.isEmpty
          ? _buildEmptyTabState("Produk")
          : ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: _filteredProducts.map((p) => _buildProductCard(p)).toList(),
            );
    }

    if (_selectedTab == "Kursus") {
      return _filteredCourses.isEmpty
          ? _buildEmptyTabState("Kursus")
          : ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: _filteredCourses.map((c) => _buildCourseCard(c)).toList(),
            );
    }

    if (_selectedTab == "Brand") {
      return _filteredBrands.isEmpty
          ? _buildEmptyTabState("Brand")
          : ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: _filteredBrands.map((b) => _buildBrandCard(b)).toList(),
            );
    }

    if (_selectedTab == "Forum") {
      return _filteredForums.isEmpty
          ? _buildEmptyTabState("Forum")
          : ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: _filteredForums.map((f) => _buildForumCard(f)).toList(),
            );
    }

    // --- Tab "Semua" (Mixed view) ---
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Total Results Indicator
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            "Ditemukan $_totalResultsCount hasil untuk \"$_currentQuery\"",
            style: TextStyle(
              color: _textGray,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // 1. Matched Products
        if (_filteredProducts.isNotEmpty) ...[
          _buildSectionHeader("Produk & Sparepart (${_filteredProducts.length})", "Produk"),
          const SizedBox(height: 8),
          ..._filteredProducts.take(3).map((p) => _buildProductCard(p)),
          const SizedBox(height: 16),
        ],

        // 2. Sponsor Banner di sela-sela hasil pencarian
        _buildSponsorBannerCard(),
        const SizedBox(height: 16),

        // 3. Matched Courses
        if (_filteredCourses.isNotEmpty) ...[
          _buildSectionHeader("Video Kursus Pembelajaran (${_filteredCourses.length})", "Kursus"),
          const SizedBox(height: 8),
          ..._filteredCourses.take(2).map((c) => _buildCourseCard(c)),
          const SizedBox(height: 16),
        ],

        // 4. Matched Brands
        if (_filteredBrands.isNotEmpty) ...[
          _buildSectionHeader("Official Store & Partner (${_filteredBrands.length})", "Brand"),
          const SizedBox(height: 8),
          ..._filteredBrands.take(2).map((b) => _buildBrandCard(b)),
          const SizedBox(height: 16),
        ],

        // 5. Matched Forum
        if (_filteredForums.isNotEmpty) ...[
          _buildSectionHeader("Diskusi Forum (${_filteredForums.length})", "Forum"),
          const SizedBox(height: 8),
          ..._filteredForums.take(2).map((f) => _buildForumCard(f)),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, String targetTab) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _textDark,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _selectedTab = targetTab),
          child: Text(
            "Lihat Semua",
            style: TextStyle(
              color: _primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // --- Beautiful Product Card ---
  Widget _buildProductCard(Map<String, dynamic> product) {
    final String title = product['name'] as String;
    final int price = product['price'] as int;
    final int origPrice = product['originalPrice'] as int? ?? price;
    final String category = product['category'] as String? ?? 'PRODUK';
    final String partner = product['partner'] as String? ?? 'Official Partner';
    final String image = product['image'] as String? ?? 'assets/images/product_lcd.png';
    final String rating = product['rating'] as String? ?? '4.9';
    final String sold = product['sold'] as String? ?? '100+';
    final String link = product['link'] as String? ?? 'https://shopee.co.id';

    final int discountPct = origPrice > price ? (((origPrice - price) / origPrice) * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          WishlistHelper.showMarketplaceSheet(
            context,
            "$partner: $title",
            link,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with category badge
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      image.startsWith('http')
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildPlaceholder(),
                            )
                          : Image.asset(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildPlaceholder(),
                            ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: _primaryBlue.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category,
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
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Partner Name
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, color: Colors.amber, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            partner,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Rating & Sold
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          "$rating • $sold terjual",
                          style: TextStyle(color: _textGray, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price & Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatRupiah(price),
                              style: TextStyle(
                                color: _orangeSale,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            if (discountPct > 0) ...[
                              const SizedBox(width: 6),
                              Text(
                                _formatRupiah(origPrice),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Buy/Visit Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primaryBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 11),
                              SizedBox(width: 3),
                              Text(
                                "Beli",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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

  // --- Beautiful Course Video Card ---
  Widget _buildCourseCard(Map<String, dynamic> course) {
    final String title = course['title'] as String;
    final String instructor = course['instructor'] as String;
    final String duration = course['duration'] as String;
    final String views = course['views'] as String;
    final String badge = course['badge'] as String;
    final Color badgeColor = course['badgeColor'] as Color? ?? const Color(0xFF10B981);
    final String image = course['image'] as String? ?? 'assets/images/course_soldering.png';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Play video / course
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Membuka materi: $title"),
              backgroundColor: _primaryBlue,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Play button & Badges
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholder(),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    // Badge Gratis / Premium
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    // Duration
                    Positioned(
                      bottom: 8,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white70, size: 11),
                            const SizedBox(width: 3),
                            Text(
                              duration,
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Course Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                      fontSize: 13.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_rounded, color: _primaryBlue, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            instructor,
                            style: TextStyle(color: _textGray, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.visibility_rounded, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "$views ditonton",
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
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

  // --- Beautiful Brand Partner Card ---
  Widget _buildBrandCard(Map<String, dynamic> brand) {
    final String name = brand['name'] as String;
    final String subtitle = brand['subtitle'] as String;
    final String tier = brand['tier'] as String;
    final String logo = brand['logo'] as String;
    final String rating = brand['rating'] as String;
    final String productsCount = brand['productsCount'] as String;
    final String link = brand['link'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          WishlistHelper.showMarketplaceSheet(context, name, link);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Logo
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _borderColor, width: 1.5),
                ),
                child: ClipOval(
                  child: Image.asset(
                    logo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: _primaryBlue,
                      child: const Center(
                        child: Icon(Icons.storefront_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(Icons.verified_rounded, color: Colors.blue, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _textGray, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tier,
                            style: TextStyle(
                              color: _primaryBlue,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "⭐ $rating • $productsCount",
                          style: TextStyle(color: _textGray, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  // --- Beautiful Forum Card ---
  Widget _buildForumCard(Map<String, dynamic> forum) {
    final String title = forum['title'] as String;
    final String author = forum['author'] as String;
    final String time = forum['time'] as String;
    final String content = forum['content'] as String;
    final String tag = forum['tag'] as String;
    final int likes = forum['likes'] as int;
    final int comments = forum['comments'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Membuka diskusi forum: $title"),
              backgroundColor: _primaryBlue,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: (_isDark ? Colors.blue.shade300 : _primaryBlue).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: TextStyle(
                        color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(color: _textGray, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                  fontSize: 14,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _textGray, fontSize: 12, height: 1.3),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Oleh @$author",
                    style: TextStyle(color: _primaryBlue, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt_rounded, color: Colors.grey.shade400, size: 14),
                      const SizedBox(width: 4),
                      Text("$likes", style: TextStyle(color: _textGray, fontSize: 11)),
                      const SizedBox(width: 14),
                      Icon(Icons.chat_bubble_rounded, color: Colors.grey.shade400, size: 14),
                      const SizedBox(width: 4),
                      Text("$comments", style: TextStyle(color: _textGray, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Real Dynamic Sponsor Banner Card ---
  Widget _buildSponsorBannerCard() {
    final String title = _sponsorBanner?['title'] ?? "BraderParts Indonesia: Sparepart Bergaransi Resmi";
    final String sponsorName = _sponsorBanner?['sponsor_name'] ?? "BraderParts Indonesia";
    final String tier = _sponsorBanner?['tier'] ?? "PLATINUM";
    final String image = _sponsorBanner?['media_path'] ?? "assets/images/banner_braderparts.png";
    final String targetUrl = _sponsorBanner?['target_url'] ?? "https://shopee.co.id/brader_parts";

    return Container(
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
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
              image.startsWith('http')
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildSponsorFallback(title),
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildSponsorFallback(title),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 10,
                child: SponsorTierBadge(
                  rawTier: tier,
                  isSolid: true,
                  fontSize: 8.5,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
              ),
              Positioned(
                top: 8,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "SPONSORED",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 10,
                right: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sponsorName,
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Kunjungi",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSponsorFallback(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primaryBlue, Colors.blue.shade900]),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, color: _primaryBlue, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              "Hasil Tidak Ditemukan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Tidak ada hasil yang cocok dengan \"$_currentQuery\". Coba periksa ejaan atau gunakan kata kunci lain seperti \"LCD\", \"Baterai\", atau \"Solder\".",
              textAlign: TextAlign.center,
              style: TextStyle(color: _textGray, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text("Reset Pencarian"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTabState(String tabName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, color: _textGray, size: 40),
            const SizedBox(height: 12),
            Text(
              "Tidak ada $tabName untuk \"$_currentQuery\"",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Coba pilih tab \"Semua\" untuk melihat kategori lainnya.",
              style: TextStyle(color: _textGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: _isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
      child: Center(
        child: Icon(Icons.image_rounded, color: _textGray, size: 32),
      ),
    );
  }
}
