// ignore_for_file: unused_element
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'home_header_sliver.dart';
import 'package:vbat_ponsel/core/widgets/video_preview_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _orangeSale = const Color(0xFFFD761A);
  final Color _bgLight = const Color(0xFFF1F3FF);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);

  final ScrollController _scrollController = ScrollController();

  // Banner Promo Ala Tokopedia
  final PageController _promoPageController = PageController();
  int _currentPromoIndex = 0;
  Timer? _promoTimer;
  bool _adShown = false;
  final List<String> _promoBanners = [
    'assets/images/PHOTO-2026-07-22-20-21-55.jpg',
    'assets/images/banner_promo_diskon.png',
    'assets/images/PHOTO-2026-07-22-20-36-05.jpg',
  ];

  // POIN 12: Konfigurasi admin - jumlah sponsor yang muncul (3-6)
  final int _adminSponsorCount = 4;

  // Mosaic blocks: setiap blok punya 'pattern' (4×2 grid of 'x'/'y') dan 'items' (8 cards)
  // x = course/banner (1:1 square), y = product (portrait 0.68)
  final List<Map<String, dynamic>> _mosaicBlocks = [];
  bool _isLoadingMore = false;

  // Template data untuk 2-kolom grid rekomendasi
  final List<Map<String, dynamic>> _productTemplates = [
    {
      "type": "product",
      "name": "LCD iPhone 11 Pro Max Original Pull",
      "price": "Rp 1.250.000",
      "rating": "4.9",
      "sold": "120",
      "image": "assets/images/product_lcd.png",
      "isMitra": true,
      "partner": "BraderParts",
    },
    {
      "type": "product",
      "name": "Baterai Xiaomi Redmi Note 10 Pro BN53",
      "price": "Rp 145.000",
      "rating": "4.8",
      "sold": "350",
      "image": "assets/images/product_battery.png",
      "isMitra": true,
      "partner": "BraderParts",
    },
    {
      "type": "product",
      "name": "Obeng Set Presisi 24 in 1 Magnetik",
      "price": "Rp 45.000",
      "rating": "4.7",
      "sold": "500",
      "image": "assets/images/product_1.png",
      "isMitra": true,
      "partner": "TITAN Tools",
    },
    {
      "type": "product",
      "name": "Flux Amtech RMA-223 Original 100g",
      "price": "Rp 85.000",
      "rating": "4.9",
      "sold": "210",
      "image": "assets/images/product_1.png",
      "isMitra": true,
      "partner": "BT-ACC",
    },
    {
      "type": "product",
      "name": "Kawat Jumper 0.01mm Sunshine Ultra Thin",
      "price": "Rp 15.000",
      "rating": "4.6",
      "sold": "890",
      "image": "assets/images/product_1.png",
      "isMitra": false,
      "partner": "",
    },
    {
      "type": "product",
      "name": "Timah Gulung Mechanic 0.3mm 40g 63/37",
      "price": "Rp 35.000",
      "rating": "4.8",
      "sold": "440",
      "image": "assets/images/product_1.png",
      "isMitra": false,
      "partner": "",
    },
    {
      "type": "product",
      "name": "Pinset Lengkung anti statik ESD-15",
      "price": "Rp 25.000",
      "rating": "4.7",
      "sold": "670",
      "image": "assets/images/product_1.png",
      "isMitra": true,
      "partner": "TITAN Tools",
    },
    {
      "type": "product",
      "name": "Isopropil Alkohol 99.9% 500ml Pembersih PCB",
      "price": "Rp 55.000",
      "rating": "4.9",
      "sold": "310",
      "image": "assets/images/product_1.png",
      "isMitra": false,
      "partner": "",
    },
    {
      "type": "product",
      "name": "Lem Touchscreen T7000 Hitam 50ml",
      "price": "Rp 20.000",
      "rating": "4.8",
      "sold": "1.1K",
      "image": "assets/images/product_1.png",
      "isMitra": false,
      "partner": "",
    },
    {
      "type": "product",
      "name": "Solder Wick Goot Wick 2.5mm 1.5m",
      "price": "Rp 18.000",
      "rating": "4.9",
      "sold": "780",
      "image": "assets/images/product_1.png",
      "isMitra": true,
      "partner": "TITAN Tools",
    },
  ];

  // Template data untuk kursus pembelajaran (otomatis disematkan link YouTube)
  final List<Map<String, dynamic>> _learningTemplates = [
    {
      "type": "learning",
      "title": "Mastering iPhone 13 Pro Max Dual-Layer Board Reballing",
      "instructor": "Mas VBat",
      "duration": "45:12",
      "views": "12.5K",
      "image": "assets/images/course_soldering.png",
      "videoUrl": "assets/videos/VIDEO-2026-07-26-21-31-11.mp4",
      "badge": "FREE",
    },
    {
      "type": "learning",
      "title": "Teknik Jumper Jalur Putus di Bawah IC CPU Snapdragon",
      "instructor": "Teknisi Senior",
      "duration": "28:40",
      "views": "8.1K",
      "image": "assets/images/course_soldering.png",
      "videoUrl": "assets/videos/VIDEO-2026-07-26-21-31-11.mp4",
      "badge": "PREMIUM",
    },
    {
      "type": "learning",
      "title": "Cara Membaca Skema & Tracking Short VCC_MAIN iPhone",
      "instructor": "Instruktur Borneo",
      "duration": "35:00",
      "views": "15.2K",
      "image": "assets/images/course_soldering.png",
      "videoUrl": "assets/videos/VIDEO-2026-07-26-21-31-11.mp4",
      "badge": "FREE",
    },
    {
      "type": "learning",
      "title": "Pengenalan Alat Servis Modern & Setup Meja Kerja",
      "instructor": "Mas VBat",
      "duration": "15:30",
      "views": "6.4K",
      "image": "assets/images/course_soldering.png",
      "videoUrl": "assets/videos/VIDEO-2026-07-26-21-31-11.mp4",
      "badge": "FREE",
    },
    {
      "type": "learning",
      "title": "Solusi No Service / Sinyal Hilang pada Android 5G",
      "instructor": "Ahli RF",
      "duration": "40:15",
      "views": "9.8K",
      "image": "assets/images/course_soldering.png",
      "videoUrl": "assets/videos/VIDEO-2026-07-26-21-31-11.mp4",
      "badge": "PREMIUM",
    },
  ];

  @override
  void initState() {
    super.initState();

    _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_promoBanners.isEmpty) return;
      int nextIndex = (_currentPromoIndex + 1) % _promoBanners.length;
      if (_promoPageController.hasClients) {
        _promoPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    // Generate 3 mosaic blocks awal
    for (int i = 0; i < 3; i++) {
      _mosaicBlocks.add(_generateMosaicBlock());
    }

    // Scroll listener untuk infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 400) {
        _loadMore();
      }
    });

    // Tampilkan pop-up iklan saat pertama kali buka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_adShown && mounted) {
        _adShown = true;
        _showAdDialog();
      }
    });
  }

  void _showAdDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Ad',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, anim, secondAnim, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, anim, secondAnim) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A1628),
                    Color(0xFF0D2045),
                    Color(0xFF0A1628),
                  ],
                ),
                border: Border.all(color: const Color(0xFF1B4F9B), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B4F9B).withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header label iklan
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(19),
                        topRight: Radius.circular(19),
                      ),
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B4F9B), Color(0xFF0D6EFD)],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.campaign_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Sponsor & Mitra VBat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Gambar iklan
                  ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: Image.asset(
                      'assets/images/PHOTO-2026-07-22-20-21-55.jpg',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  // Footer dengan tombol aksi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(19),
                        bottomRight: Radius.circular(19),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(ctx).pop(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(
                                    0xFF1B4F9B,
                                  ).withValues(alpha: 0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Tutup',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(ctx).pop();
                              // TODO: navigasi ke halaman Digital Ways / toko
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1B4F9B),
                                    Color(0xFF0D6EFD),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0D6EFD,
                                    ).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.storefront_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Kunjungi Toko',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
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
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoPageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Pola layout mosaic: 4 baris × 2 kolom
  // x = portrait (produk + banner), y = kursus (image 1:1 + info di bawah)
  // SEMUA card selalu tinggi portrait, sehingga tidak ada gap
  // [0][0] selalu 'x' agar banner sponsor di pojok kiri atas
  static const List<List<List<String>>> _mosaicPatterns = [
    [
      ['x', 'y'],
      ['y', 'x'],
      ['x', 'y'],
      ['y', 'x'],
    ], // A: checkerboard
    [
      ['x', 'x'],
      ['y', 'x'],
      ['x', 'y'],
      ['y', 'y'],
    ], // B: blocks
    [
      ['x', 'y'],
      ['x', 'x'],
      ['y', 'y'],
      ['y', 'x'],
    ], // C: diagonal
    [
      ['x', 'y'],
      ['y', 'y'],
      ['x', 'x'],
      ['y', 'x'],
    ], // D: cross
    [
      ['x', 'x'],
      ['y', 'y'],
      ['x', 'y'],
      ['y', 'x'],
    ], // E: symmetric
    [
      ['x', 'y'],
      ['y', 'x'],
      ['y', 'x'],
      ['x', 'y'],
    ], // F: zigzag
  ];

  // Generate satu mosaic block berdasarkan pola layout
  Map<String, dynamic> _generateMosaicBlock() {
    final random = Random();
    final pattern = _mosaicPatterns[random.nextInt(_mosaicPatterns.length)];
    final items = <Map<String, dynamic>>[];
    bool bannerPlaced = false;

    for (final row in pattern) {
      for (final type in row) {
        if (!bannerPlaced && type == 'x') {
          // Slot 'x' pertama = banner sponsor
          items.add({'type': 'banner_sponsor'});
          bannerPlaced = true;
        } else if (type == 'x') {
          // Slot 'x' berikutnya = product card (portrait, sama ukuran dengan banner)
          items.add(
            Map<String, dynamic>.from(
              _productTemplates[random.nextInt(_productTemplates.length)],
            ),
          );
        } else {
          // Slot 'y' = course card (1:1 square)
          items.add(
            Map<String, dynamic>.from(
              _learningTemplates[random.nextInt(_learningTemplates.length)],
            ),
          );
        }
      }
    }

    return {'pattern': pattern, 'items': items};
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _mosaicBlocks.add(_generateMosaicBlock());
        _isLoadingMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: _buildSlivers(context),
      ),
    );
  }

  // --- Dynamic Slivers Generator (Alternating Grid & Full Width Blocks) ---
  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = [];

    // 1. Header Sliver
    slivers.add(const HomeHeaderSliver());

    // 2. Quick Actions Container
    slivers.add(
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          // POIN 3: padding vertikal dikurangi agar lebih rapat ke konten 3
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildQuickAction(
                  Icons.local_activity_rounded,
                  Colors.blue,
                  "Sertifikat Saya",
                  "Lihat pencapaian",
                  onTap: () => context.push('/certificate'),
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  Icons.local_fire_department_rounded,
                  Colors.orange,
                  "Streak Belajar",
                  "3 hari beruntun!",
                  onTap: () => _showStreakDialog(),
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  Icons.credit_card_rounded,
                  Colors.brown,
                  "Member VBat",
                  "Akses Alumni",
                  onTap: () => context.push('/subscription'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 3. Grid Menu Ikon Utama + Sub Kategori
    slivers.add(
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          // POIN 3 & 4: margin bottom dikurangi agar lebih rapat ke Flash Sale
          margin: const EdgeInsets.only(bottom: 4),
          // POIN 3: padding atas dikurangi juga
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon menu row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconMenu(
                    Icons.school_rounded,
                    "Kelas Saya",
                    badge: "",
                    onTap: () {
                      SessionManager.currentTabIndex.value = 2; // Belajar Tab
                    },
                  ),
                  _buildIconMenu(
                    Icons.build_rounded,
                    "Alat Servis",
                    badge: "PROMO",
                    badgeColor: Colors.red,
                    onTap: () {
                      SessionManager.currentTabIndex.value = 1; // Shop Tab
                    },
                  ),
                  _buildIconMenu(
                    Icons.stars_rounded,
                    "VBat Premium",
                    badge: "VIP",
                    badgeColor: Colors.amber.shade700,
                    onTap: () => context.push('/pricelist'),
                  ),
                  _buildIconMenu(
                    Icons.info_rounded,
                    "Pusat Informasi",
                    badge: "",
                    onTap: () {
                      SessionManager.currentTabIndex.value = 3; // Informasi Tab
                    },
                  ),
                  _buildIconMenu(
                    Icons.location_on_rounded,
                    "Mitra",
                    badge: "",
                    onTap: () {
                      SessionManager.currentTabIndex.value = 1;
                    },
                  ),
                ],
              ),
              // Banner Promo Ala Tokopedia (menggantikan Kategori)
              _buildPromoBannerSlider(),
            ],
          ),
        ),
      ),
    );

    // POIN 8: Best Deal - produk dari mitra sponsor
    slivers.add(
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
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
                  const SizedBox(width: 8),
                  // POIN 8: label mitra
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.verified_rounded,
                          color: Color(0xFFFFB300),
                          size: 10,
                        ),
                        SizedBox(width: 3),
                        Text(
                          "Produk Mitra",
                          style: TextStyle(
                            color: Color(0xFFE65100),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      SessionManager.currentTabIndex.value = 1;
                    },
                    child: Row(
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
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildBestDealCard(
                      "Infinix Hot 10 Play Battery",
                      "Rp145.000",
                      "Rp220.000",
                      "35%",
                      "assets/images/product_battery.png",
                      partner: "BraderParts",
                    ),
                    const SizedBox(width: 12),
                    _buildBestDealCard(
                      "LCD iPhone 11 Pro Max OLED",
                      "Rp1.250.000",
                      "Rp1.850.000",
                      "32%",
                      "assets/images/product_lcd.png",
                      partner: "BraderParts",
                    ),
                    const SizedBox(width: 12),
                    _buildBestDealCard(
                      "Obeng Set Presisi 24 in 1 Magnet",
                      "Rp45.000",
                      "Rp80.000",
                      "44%",
                      "assets/images/product_battery.png",
                      partner: "TITAN Tools",
                    ),
                    const SizedBox(width: 12),
                    _buildBestDealCard(
                      "Flux Amtech NC-559-ASM 10cc",
                      "Rp85.000",
                      "Rp130.000",
                      "34%",
                      "assets/images/product_battery.png",
                      partner: "BT-ACC",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // POIN 5: Banner Sponsor antara Flash Sale dan Rekomendasi diganti dengan gambar statis
    slivers.add(SliverToBoxAdapter(child: _buildStaticSeparatorBanner()));

    // 5. Header Rekomendasi
    slivers.add(
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                "Rekomendasi Untukmu",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.star_outline_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );

    // 6. Mosaic blocks — setiap blok = 4 baris × 2 kolom (8 card), lalu jeda banner statis
    for (int blockIdx = 0; blockIdx < _mosaicBlocks.length; blockIdx++) {
      slivers.add(
        SliverToBoxAdapter(
          child: _buildMosaicBlock(context, _mosaicBlocks[blockIdx]),
        ),
      );
      // Separator setelah setiap blok 8 card: Gambar PHOTO-2026-07-22-20-20-24 statis tanpa slider
      slivers.add(SliverToBoxAdapter(child: _buildStaticSeparatorBanner()));
    }

    // 7. Loading skeleton
    if (_isLoadingMore) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: List.generate(
                2,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // POIN 14: Hardware Solution Section
    slivers.add(SliverToBoxAdapter(child: _buildHardwareSolutionSection()));

    // 8. Safe area padding
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 100)));

    return slivers;
  }

  // ---- MOSAIC BLOCK BUILDER ----
  // Layout Masonry (2 kolom independen):
  // x = produk / banner (rasio portrait 0.68), y = kursus (rasio kotak 1:1 mutlak).
  // Karena setiap pola di _mosaicPatterns memiliki tepat 2 'x' dan 2 'y' di tiap kolomnya,
  // maka total tinggi kolom kiri dan kanan selalu persis sama (tidak ada gap di akhir block!).
  Widget _buildMosaicBlock(BuildContext context, Map<String, dynamic> block) {
    final pattern = (block['pattern'] as List)
        .map((r) => (r as List).cast<String>())
        .toList();
    final items = (block['items'] as List).cast<Map<String, dynamic>>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final cw = (constraints.maxWidth - 6) / 2; // lebar tiap kolom / card

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Kiri (indeks item genap: 0, 2, 4, 6)
              Expanded(
                child: Column(
                  children: List.generate(4, (row) {
                    final type = pattern[row][0];
                    final item = items[row * 2];
                    final h = type == 'x' ? cw / 0.68 : cw;

                    return Padding(
                      padding: EdgeInsets.only(bottom: row < 3 ? 6 : 0),
                      child: SizedBox(
                        width: cw,
                        height: h,
                        child: _buildMosaicCell(context, type, item),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 6),
              // Kolom Kanan (indeks item ganjil: 1, 3, 5, 7)
              Expanded(
                child: Column(
                  children: List.generate(4, (row) {
                    final type = pattern[row][1];
                    final item = items[row * 2 + 1];
                    final h = type == 'x' ? cw / 0.68 : cw;

                    return Padding(
                      padding: EdgeInsets.only(bottom: row < 3 ? 6 : 0),
                      child: SizedBox(
                        width: cw,
                        height: h,
                        child: _buildMosaicCell(context, type, item),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Pilih widget berdasarkan type cell
  Widget _buildMosaicCell(
    BuildContext context,
    String type,
    Map<String, dynamic> item,
  ) {
    if (item['type'] == 'banner_sponsor') {
      return const SponsorSliderCard();
    }
    // x = product (portrait), y = course (1:1 square)
    return type == 'x'
        ? _buildZStackProductCard(context, item)
        : _buildZStackCourseCard(context, item);
  }

  Widget _buildZStackProductCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final bool isMitra = item['isMitra'] == true;
    final String? partner = item['partner'] as String?;

    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: item),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gambar produk (full cover)
            Image.asset(
              item['image'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFE8EAF6),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: _primaryBlue.withValues(alpha: 0.4),
                  size: 36,
                ),
              ),
            ),
            // Gradient overlay gelap 70% dari bawah
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xB3000000)],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
            // Badge "PRODUK" pojok kiri atas
            Positioned(
              top: 7,
              left: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRODUK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            // Badge "MITRA" pojok kanan atas (jika ada)
            if (isMitra)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 8,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'MITRA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Info overlay di bawah (nama, rating, harga)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMitra && partner != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.store_rounded,
                          size: 9,
                          color: Color(0xFFFFD54F),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            partner,
                            style: const TextStyle(
                              color: Color(0xFFFFD54F),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    item['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '${item['rating'] ?? ''} • ${item['sold'] ?? ''} terjual',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['price'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
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

  // ---- COURSE CARD: 1:1 square mutlak ----
  Widget _buildZStackCourseCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final String badge = item['badge'] ?? 'FREE';
    final bool isPremium = badge == 'PREMIUM';

    return GestureDetector(
      onTap: () {
        // Memutar video langsung di dalam aplikasi (In-App Video Player)
        context.push('/video-player', extra: item);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFF0D0D1A)),
            VideoPreviewWidget(
              videoUrl:
                  item['videoUrl'] ??
                  'assets/videos/VIDEO-2026-07-26-21-31-11.mp4',
              fallbackImage: item['image'] ?? '',
            ),
            // Gradient gelap dari bawah agar teks terbaca jelas
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0xD9000000)],
                  stops: [0.3, 1.0],
                ),
              ),
            ),
            // Tombol play di tengah
            Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // Badge KURSUS di pojok kiri atas
            Positioned(
              top: 7,
              left: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'KURSUS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            // Badge FREE / PREMIUM di pojok kanan atas
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPremium
                      ? const Color(0xFF7B1FA2)
                      : Colors.green.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Info teks di pojok kiri bawah (overlay di atas foto)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF90CAF9),
                        size: 10,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item['instructor'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF90CAF9),
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (item['duration'] != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white70,
                          size: 9,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          item['duration'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.visibility_rounded,
                          color: Colors.white70,
                          size: 9,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          item['views'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- BANNER PROMO SLIDER (GAYA TOKOPEDIA) ----
  Widget _buildPromoBannerSlider() {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 12),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 2.7, // Rasio banner memanjang ala e-commerce Tokopedia
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _promoPageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _promoBanners.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPromoIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        _promoBanners[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFFE8EAF6),
                          child: const Center(
                            child: Icon(
                              Icons.local_offer_rounded,
                              color: Color(0xFF1B4F9B),
                              size: 36,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient halus di bawah untuk memperjelas indikator slide
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 35,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x77000000)],
                        ),
                      ),
                    ),
                  ),
                  // Indikator Slide ala Tokopedia (Pill + Dots di tengah bawah)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_promoBanners.length, (index) {
                        final bool isActive = index == _currentPromoIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          width: isActive ? 18.0 : 6.0,
                          height: 5.0,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- STATIC SEPARATOR BANNER (PHOTO-2026-07-22-20-20-24.jpg) ----
  // Tanpa slider, sebagai jeda antar section 8 card & menggantikan bagian sponsor/mitra/promo oren.
  Widget _buildStaticSeparatorBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: AspectRatio(
        aspectRatio: 2.7, // Rasio banner memanjang ala e-commerce
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/PHOTO-2026-07-22-20-20-24.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFFE8EAF6),
              child: const Center(
                child: Icon(
                  Icons.image_rounded,
                  color: Color(0xFF1B4F9B),
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // POIN 14: Hardware Solution Section
  Widget _buildHardwareSolutionSection() {
    final List<Map<String, dynamic>> solutions = [
      {
        "brand": "iPhone",
        "model": "iPhone 11–14 Series",
        "icon": Icons.phone_iphone_rounded,
        "color": const Color(0xFF1B4F9B),
        "topics": ["LCD Replacement", "IC Power", "TrueTone", "Face ID"],
        "count": "24 Materi",
      },
      {
        "brand": "Samsung",
        "model": "Galaxy A & S Series",
        "icon": Icons.phone_android_rounded,
        "color": const Color(0xFF1428A0),
        "topics": ["Charging Port", "Kamera", "Touchscreen", "Boot Loop"],
        "count": "18 Materi",
      },
      {
        "brand": "Xiaomi",
        "model": "Redmi & POCO Series",
        "icon": Icons.smartphone_rounded,
        "color": const Color(0xFFFF6900),
        "topics": ["Baterai", "Layar", "Mikrofon", "Speaker"],
        "count": "15 Materi",
      },
      {
        "brand": "OPPO",
        "model": "Reno & A Series",
        "icon": Icons.phone_rounded,
        "color": const Color(0xFF1D7348),
        "topics": ["Charger IC", "LCD", "Sensor", "Software"],
        "count": "12 Materi",
      },
      {
        "brand": "Vivo",
        "model": "Y & V Series",
        "icon": Icons.phone_callback_rounded,
        "color": const Color(0xFF4154AF),
        "topics": ["Back Cover", "LCD", "Kamera", "Signal"],
        "count": "10 Materi",
      },
    ];

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _orangeSale.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.memory_rounded, color: _orangeSale, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "HARDWARE SOLUTION",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: _orangeSale,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/hardware-solution'),
                  child: Row(
                    children: [
                      Text(
                        "Lihat Semua",
                        style: TextStyle(
                          fontSize: 11,
                          color: _primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: _primaryBlue,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              "Panduan perbaikan per tipe & merek HP",
              style: TextStyle(fontSize: 11, color: _textGray),
            ),
          ),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              itemCount: solutions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final sol = solutions[index];
                final color = sol["color"] as Color;
                final topics = sol["topics"] as List<String>;
                return GestureDetector(
                  onTap: () => context.push('/hardware-solution'),
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    sol["icon"] as IconData,
                                    color: color,
                                    size: 18,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.lock_rounded,
                                      color: Colors.grey.shade700,
                                      size: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sol["brand"] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  Text(
                                    sol["count"] as String,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: color.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sol["model"] as String,
                          style: TextStyle(fontSize: 10, color: _textGray),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: topics
                              .take(3)
                              .map(
                                (t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // POIN 13: Horizontal Promo Card - muncul di setiap selingan
  Widget _buildHorizontalPromoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color1,
    required Color color2,
    required String badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => SessionManager.currentTabIndex.value = 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color1.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // POIN 12 & 5: Banner sponsor horizontal strip - jumlah sesuai admin config
  Widget _buildSponsorBannerStrip({int? maxCount}) {
    final List<Map<String, dynamic>> sponsors = [
      {
        "name": "BraderParts",
        "tagline": "Sparepart Original Bergaransi",
        "color1": const Color(0xFF1B4F9B),
        "color2": const Color(0xFF3B7ED9),
        "badge": "OFFICIAL PARTNER",
        "icon": Icons.verified_rounded,
      },
      {
        "name": "TITAN Tools",
        "tagline": "Peralatan Servis Presisi Tinggi",
        "color1": const Color(0xFF2D2D2D),
        "color2": const Color(0xFF555555),
        "badge": "TOOLS PARTNER",
        "icon": Icons.build_circle_rounded,
      },
      {
        "name": "BT-ACC Battery",
        "tagline": "Baterai Original & Tahan Lama",
        "color1": const Color(0xFFB8860B),
        "color2": const Color(0xFFFFD700),
        "badge": "BATTERY PARTNER",
        "icon": Icons.battery_charging_full_rounded,
      },
    ];

    // POIN 12: Batasi jumlah sponsor sesuai konfigurasi admin (3-6)
    final displayedSponsors = sponsors
        .take(maxCount ?? _adminSponsorCount)
        .toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      color: _bgLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _primaryBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Sponsor & Mitra VBat",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const Spacer(),
                Text(
                  "Lihat Semua",
                  style: TextStyle(
                    fontSize: 11,
                    color: _primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _primaryBlue,
                  size: 14,
                ),
              ],
            ),
          ),
          // POIN 12: info jumlah sponsor aktif
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(
              "${displayedSponsors.length} sponsor aktif",
              style: TextStyle(fontSize: 9, color: _textGray),
            ),
          ),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              itemCount: displayedSponsors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final s = displayedSponsors[index];
                return GestureDetector(
                  onTap: () => SessionManager.currentTabIndex.value = 1,
                  child: Container(
                    width: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [s["color1"] as Color, s["color2"] as Color],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (s["color1"] as Color).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            s["icon"] as IconData,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  s["badge"] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s["name"] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                s["tagline"] as String,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // --- Aksi Cepat Item ---
  Widget _buildQuickAction(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Menu Utama Ikon ---
  Widget _buildIconMenu(
    IconData icon,
    String label, {
    required String badge,
    Color badgeColor = Colors.transparent,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Icon(icon, color: const Color(0xFF1B4F9B), size: 24),
                ),
                if (badge.isNotEmpty)
                  Positioned(
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        badge,
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
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // POIN 6 & 8: Best Deal Card (menggantikan Flash Sale Card) - dengan badge mitra
  Widget _buildBestDealCard(
    String name,
    String price,
    String originalPrice,
    String discount,
    String assetImage, {
    required String partner,
  }) {
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
            "isMitra": true,
            "partner": partner,
            "link":
                "https://shopee.co.id/Braderparts-Baterai-Battery-Batre-BL-58BX-for-Infinix-Hot-9-Play-Hot-10-Play-Hot-10S-Hot-11-Play-Hot-12-Play-i.57356590.22913463095",
          },
        );
      },
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFB300).withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB300).withValues(alpha: 0.08),
              blurRadius: 6,
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
                      child: Image.asset(
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
                  // Discount badge
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
                  // POIN 10: Badge Mitra di pojok kanan atas
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 8,
                          ),
                          SizedBox(width: 2),
                          Text(
                            "MITRA",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                  // POIN 8: nama partner/mitra
                  Row(
                    children: [
                      const Icon(
                        Icons.store_rounded,
                        size: 9,
                        color: Color(0xFFFFB300),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        partner,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Color(0xFFE65100),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
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

  // --- Grid Card Builder (Shopee E-commerce Style) ---
  Widget _buildGridCard(BuildContext context, Map<String, dynamic> item) {
    final bool isProduct = item["type"] == "product";
    // POIN 10: cek apakah produk mitra
    final bool isMitra = item["isMitra"] == true;
    final String? partnerName = item["partner"] as String?;
    // Random location & shipping tags
    final List<String> locations = [
      "Jakarta Selatan",
      "Bandung",
      "Surabaya",
      "Tangerang",
      "Bekasi",
    ];
    final String locationKey = isProduct
        ? item["name"].toString()
        : (item["title"] ?? "").toString();
    final String location = locations[locationKey.length % locations.length];
    final bool hasFreeShipping = (locationKey.length % 3 == 0);

    return GestureDetector(
      onTap: () {
        if (isProduct) {
          context.push('/product-detail', extra: item);
        } else {
          context.push('/course-detail');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          // POIN 9: border berbeda: produk abu, video merah tipis
          border: Border.all(
            color: isProduct
                ? (isMitra
                      ? const Color(0xFFFFB300).withValues(alpha: 0.4)
                      : Colors.grey.shade100)
                : Colors.red.withValues(alpha: 0.15),
          ),
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
            // POIN 9: Produk pakai rasio portrait (0.85), video tetap kotak (1.0)
            AspectRatio(
              aspectRatio: isProduct ? 0.85 : 1.0,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isProduct ? Colors.grey.shade50 : Colors.black,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: !isProduct
                          ? VideoPreviewWidget(
                              videoUrl:
                                  item["videoUrl"] ??
                                  "assets/videos/VIDEO-2026-07-26-21-31-11.mp4",
                              fallbackImage: item["image"] ?? "",
                            )
                          : Image.asset(
                              item["image"] ?? "",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      Icons.handyman_rounded,
                                      color: _primaryBlue,
                                      size: 36,
                                    ),
                                  ),
                            ),
                    ),
                  ),
                  // POIN 1: Overlay play button preview untuk card kursus
                  if (!isProduct)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  // POIN 1: Label durasi untuk card kursus (pojok kanan bawah)
                  if (!isProduct && item["duration"] != null)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item["duration"] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Badge tag (PRODUK / KURSUS)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isProduct ? _primaryBlue : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isProduct ? "PRODUK" : "KURSUS",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // POIN 10: Badge Mitra khusus untuk produk dari sponsor
                  if (isProduct && isMitra && partnerName != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              color: Colors.white,
                              size: 9,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                partnerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // Free shipping badge (hanya untuk non-mitra)
                  else if (isProduct && hasFreeShipping && !isMitra)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(color: Colors.green.shade600),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              color: Colors.white,
                              size: 10,
                            ),
                            SizedBox(width: 3),
                            Text(
                              "Gratis Ongkir",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
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
                    // Nama produk/kursus - max 2 baris
                    Text(
                      isProduct ? item["name"] : item["title"],
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
                    // Rating & sold / instructor
                    if (isProduct)
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            "${item['rating']}",
                            style: TextStyle(fontSize: 10, color: _textGray),
                          ),
                          Text(
                            " • ${item['sold']} terjual",
                            style: TextStyle(fontSize: 10, color: _textGray),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            color: Colors.grey,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              item["instructor"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10, color: _textGray),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    // Harga - paling menonjol
                    Text(
                      isProduct ? item["price"] : (item["badge"] ?? "GRATIS"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isProduct ? _primaryBlue : _primaryBlue,
                        fontSize: 14,
                      ),
                    ),
                    // Lokasi
                    if (isProduct)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 10,
                              color: _textGray,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 9, color: _textGray),
                              ),
                            ),
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

  // --- Partner Banner ---
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryBlue, Colors.blue.shade900],
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

  void _showStreakDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.local_fire_department_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text("Streak Belajar"),
          ],
        ),
        content: const Text(
          "Hebat! Anda telah belajar 3 hari berturut-turut. Pertahankan streak Anda untuk mendapatkan bonus poin!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Mantap"),
          ),
        ],
      ),
    );
  }

  void _showMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.credit_card_rounded, color: Colors.brown),
            SizedBox(width: 8),
            Text("Member VBat"),
          ],
        ),
        content: const Text(
          "Sebagai Member VBat, Anda berhak mendapatkan diskon 10% untuk semua pembelian suku cadang di BraderParts resmi.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}

// --- Sliding Banner Card Widget (Auto Sliding Carousel) ---
class SlidingBannerCardWidget extends StatefulWidget {
  const SlidingBannerCardWidget({super.key});

  @override
  State<SlidingBannerCardWidget> createState() =>
      _SlidingBannerCardWidgetState();
}

class _SlidingBannerCardWidgetState extends State<SlidingBannerCardWidget> {
  late final PageController _pageController;
  Timer? _sliderTimer;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _promoBanners = [
    {
      "title": "Diskon Alat & Suku Cadang",
      "desc": "Hemat s.d 30% khusus hari ini",
      "color1": const Color(0xFFFD761A),
      "color2": const Color(0xFFFF9800),
      "image": "assets/images/banner_promo_diskon.png",
      "badge": "PROMO KILAT",
    },
    {
      "title": "Mitra Resmi BraderParts",
      "desc": "Modul eksklusif & parts original",
      "color1": const Color(0xFF1B4F9B),
      "color2": const Color(0xFF3B7ED9),
      "image": "assets/images/banner_braderparts.png",
      "badge": "OFFICIAL PARTNER",
    },
    {
      "title": "Gratis Ongkir Spesial",
      "desc": "Min. belanja 50rb se-Indonesia",
      "color1": const Color(0xFF03AC0E),
      "color2": const Color(0xFF2ECC71),
      "image": null,
      "badge": "FREE SHIPPING",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % _promoBanners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _promoBanners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final promo = _promoBanners[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (promo["image"] != null)
                      Image.asset(
                        promo["image"]!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [promo["color1"]!, promo["color2"]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [promo["color1"]!, promo["color2"]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    // Semi-transparent gradient overlay for better text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              promo["badge"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            promo["title"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            promo["desc"]!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _promoBanners.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: _currentPage == index ? 12 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: _currentPage == index ? 0.9 : 0.4,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Partner Logo Card Widget (1-cell Grid Card) ---
class PartnerLogoCardWidget extends StatelessWidget {
  final Map<String, dynamic> partner;
  const PartnerLogoCardWidget({super.key, required this.partner});

  void _showPartnerDetailDialog(BuildContext context, String partnerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                partnerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001944),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mitra Distribusi Resmi & Terverifikasi VBat Ponsel.",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF001944),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Menyediakan suku cadang smartphone asli bergaransi, tools perbaikan presisi, serta dukungan pasokan reguler untuk seluruh alumni dan teknisi VBat.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.blue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Jaminan 100% Produk Original",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              SessionManager.currentTabIndex.value = 1;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4F9B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Lihat Produk"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPartnerDetailDialog(context, partner["name"]),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: partner["color"] ?? Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: partner["image"] != null
                      ? ClipOval(
                          child: Image.asset(
                            partner["image"],
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          partner["icon"] ?? Icons.star,
                          color: partner["color"] == Colors.white
                              ? const Color(0xFF1B4F9B)
                              : Colors.white,
                          size: 26,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: partner["badge"] ?? Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              partner["name"],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001944),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Mitra Terverifikasi",
              style: TextStyle(fontSize: 9, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4F9B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Lihat Detail",
                style: TextStyle(
                  color: Color(0xFF1B4F9B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Sponsor Slider Card (banner foto di pojok kiri tiap section) ---
class SponsorSliderCard extends StatefulWidget {
  const SponsorSliderCard({super.key});

  @override
  State<SponsorSliderCard> createState() => _SponsorSliderCardState();
}

class _SponsorSliderCardState extends State<SponsorSliderCard> {
  late final PageController _pageController;
  Timer? _autoTimer;
  int _currentPage = 0;

  // 3 slide dummy — gambar sama, nanti bisa diganti per sponsor
  static const List<String> _bannerImages = [
    'assets/images/banner_sponsor_1.jpg',
    'assets/images/banner_sponsor_2.jpg',
    'assets/images/banner_sponsor_3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % _bannerImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // PageView foto
          PageView.builder(
            controller: _pageController,
            itemCount: _bannerImages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => Image.asset(
              _bannerImages[i],
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF1B4F9B),
                child: const Center(
                  child: Icon(
                    Icons.image_rounded,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          // Gradient bawah tipis agar dot terlihat
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x99000000)],
                ),
              ),
            ),
          ),
          // Dot indicator bawah tengah
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerImages.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
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
