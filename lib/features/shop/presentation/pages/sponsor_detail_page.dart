import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';
import 'package:vbat_ponsel/core/widgets/sponsor_tier_badge.dart';

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
  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF8FAFC);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF0F172A);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    _sponsor = widget.sponsorData ?? _getEmptySponsor();
    _initProducts();
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  /// Data cadangan saat halaman dibuka tanpa membawa data sponsor.
  ///
  /// Tidak ada nama, deskripsi, maupun produk palsu di sini. Halaman menampilkan
  /// keadaan kosong dan menunggu data sebenarnya dari pemanggil (daftar mitra
  /// atau API). Dengan demikian, aplikasi tidak pernah menampilkan mitra atau
  /// produk yang tidak ada.
  Map<String, dynamic> _getEmptySponsor() {
    return {
      "name": "",
      "short_name": "",
      "tier": "",
      "tier_label": "",
      "logo": "",
      "description": "",
      "website_url": "",
      "products": const <Map<String, dynamic>>[],
    };
  }

  /// True bila data sponsor belum tersedia.
  bool get _hasSponsorData =>
      (_sponsor["name"] ?? "").toString().trim().isNotEmpty;

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
    // WR-01: warna tier TIDAK dipakai sebagai latar header. Header memakai
    // palet aplikasi. Warna tier hanya untuk badge/label/ikon.
    const Color appBlue = Color(0xFF1B4F9B);
    final Color brandColor = appBlue;

    // CW-02: tier selalu dibersihkan lewat SponsorTierBadge supaya tidak ada
    // lagi tulisan "PLATINUM SPONSOR" di mana pun.
    final String tierLabel = SponsorTierBadge.cleanTierName(
      (_sponsor["tier_label"] ?? _sponsor["tier"] ?? "").toString(),
    );
    final String sponsorName = (_sponsor["name"] ?? "Mitra Sponsor").toString();
    final String sponsorDesc = (_sponsor["description"] ?? "").toString();

    // WM-01: Website dan Marketplace dipisah. Yang kosong tidak ditampilkan.
    final String marketplaceUrl =
        (_sponsor["marketplace_url"] ?? _sponsor["website_url"] ?? "")
            .toString()
            .trim();
    final String websiteUrl =
        (_sponsor["website_url"] ?? "").toString().trim();
    final bool hasMarketplace = marketplaceUrl.isNotEmpty;
    final bool hasWebsite = websiteUrl.isNotEmpty;

    // WR-02: gambar header sponsor bila ada.
    final String headerImage = (_sponsor["header_image_url"] ??
            _sponsor["header_url"] ??
            "")
        .toString()
        .trim();
    final bool hasHeaderImage = headerImage.isNotEmpty;

    final String logo = (_sponsor["logo"] ?? "").toString();

    // CW-09: bila data sponsor tidak tersedia, tampilkan keadaan kosong yang
    // jujur. Tidak ada mitra atau produk contoh yang ditampilkan.
    if (!_hasSponsorData) {
      return Scaffold(
        backgroundColor: _bgLight,
        appBar: AppBar(
          backgroundColor: _bgLight,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: _textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 56,
                  color: _textGray,
                ),
                const SizedBox(height: 12),
                Text(
                  "Data mitra tidak tersedia",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Silakan buka kembali dari daftar mitra.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _textGray),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                onPressed: () => _launchUrl(
                  hasMarketplace ? marketplaceUrl : websiteUrl,
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  // WR-01: latar header memakai palet aplikasi, bukan warna tier.
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1B4F9B),
                      Color(0xFF153F7D),
                      Color(0xFF0F2C57),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  // WR-02: gambar header sponsor menimpa gradient bila diisi.
                  image: hasHeaderImage
                      ? DecorationImage(
                          image: NetworkImage(headerImage),
                          fit: BoxFit.cover,
                          onError: (_, _) {},
                        )
                      : null,
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
                              // CW-02 + APP-02: satu-satunya tempat label tier
                              // ditampilkan. Komponen ini membersihkan "PLATINUM
                              // SPONSOR" menjadi "Platinum" dan menyertakan ikon.
                              if (tierLabel.isNotEmpty)
                                SponsorTierBadge(
                                  rawTier: tierLabel,
                                  tierColor: _sponsor["tier_color"] is Color
                                      ? _sponsor["tier_color"] as Color
                                      : null,
                                  isSolid: true,
                                  fontSize: 10,
                                  iconSize: 12,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
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
              color: _cardColor,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Highlights Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // CW-05: klaim "Rating Mitra" tetap karena bisa dihitung
                      // dari data; tapi bila belum ada data, tampilkan "-".
                      _buildMetricItem(
                        Icons.star_rounded,
                        (_sponsor["rating"] ?? "").toString().isEmpty
                            ? "-"
                            : (_sponsor["rating"] ?? "").toString(),
                        "Rating Mitra",
                        Colors.amber,
                      ),
                      _buildDivider(),
                      // CW-07: label jumlah produk ditulis apa adanya, tanpa
                      // klaim "Resmi" yang tidak bisa dibuktikan.
                      _buildMetricItem(
                        Icons.inventory_2_outlined,
                        "${_allProducts.length}",
                        "Produk",
                        _isDark ? Colors.blue.shade300 : brandColor,
                      ),
                      _buildDivider(),
                      // CW-04: "Garansi Ori" dihapus (klaim tanpa dasar).
                      // Digantikan status mitra yang bisa dibuktikan.
                      _buildMetricItem(
                        Icons.verified_rounded,
                        "Resmi",
                        "Mitra VBAT",
                        const Color(0xFF1B4F9B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Button Row — WM-01: tampilkan hanya tautan yang ada isinya.
                  Row(
                    children: [
                      if (hasMarketplace)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchUrl(marketplaceUrl),
                            icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                            // CW-08: teks tombol tidak lagi menyebut salah satu
                            // marketplace, karena tautan bisa ke mana saja.
                            label: const Text(
                              "Kunjungi Toko",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              // CW-08: warna mengikuti palet aplikasi.
                              backgroundColor: brandColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      if (hasMarketplace && hasWebsite) const SizedBox(width: 10),
                      if (hasWebsite)
                        ElevatedButton.icon(
                          onPressed: () => _launchUrl(websiteUrl),
                          icon: const Icon(Icons.public, size: 16),
                          label: const Text(
                            "Website",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandColor.withValues(alpha: _isDark ? 0.25 : 0.1),
                            foregroundColor: _isDark ? Colors.white : brandColor,
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
              color: _cardColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: _isDark ? Colors.blue.shade300 : brandColor),
                      const SizedBox(width: 8),
                      Text(
                        "Tentang Mitra Resmi",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    // CW-03: tidak ada lagi deskripsi contoh yang dipatok di
                    // kode. Deskripsi hanya muncul bila diisi Admin/Sponsor.
                    sponsorDesc.isNotEmpty
                        ? sponsorDesc
                        : "Deskripsi mitra belum diisi.",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: _textGray,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // CW-05: tiga klaim ("Mitra Terverifikasi", "Pengiriman Cepat",
                  // "Garansi Retur") dihapus karena tidak berasal dari data dan
                  // bukan tanggung jawab VBAT. Diganti satu keterangan yang
                  // benar-benar bisa dibuktikan sistem.
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDark ? ThemeManager.darkBg : _bgLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureChip(
                          Icons.storefront_outlined,
                          "Mitra Resmi VBAT",
                        ),
                        _buildFeatureChip(
                          Icons.open_in_new_rounded,
                          "Transaksi di Marketplace",
                        ),
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
              color: _cardColor,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.storefront_rounded, size: 18, color: _isDark ? Colors.blue.shade300 : brandColor),
                          const SizedBox(width: 8),
                          Text(
                            "Produk ${_sponsor['short_name'] ?? sponsorName}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: _isDark ? 0.25 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${_filteredProducts.length} Produk",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isDark ? Colors.blue.shade300 : brandColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Field
                  TextField(
                    controller: _searchController,
                    style: TextStyle(color: _textDark, fontSize: 13),
                    onChanged: (val) => _applyFilter(val, _selectedCategory),
                    decoration: InputDecoration(
                      hintText: "Cari produk di toko ini...",
                      hintStyle: TextStyle(fontSize: 13, color: _textGray.withValues(alpha: 0.7)),
                      prefixIcon: Icon(Icons.search, size: 20, color: _textGray),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 18, color: _textGray),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilter("", _selectedCategory);
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: _isDark ? ThemeManager.darkBg : _bgLight,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _borderColor),
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
                                color: isSel ? Colors.white : _textDark,
                              ),
                              selected: isSel,
                              selectedColor: brandColor,
                              backgroundColor: _isDark ? ThemeManager.darkBg : _bgLight,
                              checkmarkColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSel ? brandColor : _borderColor,
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
                    color: _cardColor,
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 54, color: _textGray.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          "Produk tidak ditemukan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Coba gunakan kata kunci pencarian yang lain.",
                          style: TextStyle(fontSize: 12, color: _textGray),
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
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: _isDark ? 0.25 : 0.03),
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
                                        color: _isDark ? Colors.black26 : Colors.grey.shade50,
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
                                            color: _cardColor,
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
                                            color: isFav ? Colors.red : _textGray,
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
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _textDark),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "• $pSold",
                                            style: TextStyle(fontSize: 10, color: _textGray),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: _textGray),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: _borderColor,
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _isDark ? Colors.blue.shade300 : _primaryBlue),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
      ],
    );
  }
}
