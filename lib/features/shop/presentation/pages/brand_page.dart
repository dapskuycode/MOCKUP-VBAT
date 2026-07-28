import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BrandPage extends StatelessWidget {
  const BrandPage({super.key});

  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Header (Statis)
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: _primaryBlue,
                        onPressed:
                            () {}, // Akan dihandle oleh router jika perlu
                      ),
                      Expanded(
                        child: Text(
                          "Brand Resmi",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryBlue,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline_rounded),
                        color: _primaryBlue,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // 2. Search & List Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      40,
                      100,
                    ), // padding right 40 untuk sidebar A-Z
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Search Bar
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: _textGray,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Cari brand HP...",
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.camera_alt_outlined,
                              color: _textGray,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Brand Terpopuler
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Brand Terpopuler",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primaryBlue,
                              fontSize: 15,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: _primaryBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildPopularBrand(context, "Apple"),
                            _buildPopularBrand(context, "Samsung"),
                            _buildPopularBrand(context, "Oppo"),
                            _buildPopularBrand(context, "Xiaomi"),
                            _buildPopularBrand(context, "Vivo"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Promo Banner
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _primaryBlue.withValues(alpha: 0.9),
                              _primaryBlue.withValues(alpha: 0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "SPONSORED",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Bersama BraderParts",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Text(
                                    "Sparepart Resmi Semua Brand",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Semua Brand List
                      Text(
                        "Semua Brand (A-Z)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildLetterHeader("A"),
                      _buildBrandListItem(
                        context,
                        "Apple",
                        "42 tipe tersedia",
                        "48",
                        "120",
                      ),
                      _buildBrandListItem(
                        context,
                        "Asus",
                        "28 tipe tersedia",
                        "12",
                        "45",
                      ),

                      const SizedBox(height: 16),
                      _buildLetterHeader("I"),
                      _buildBrandListItem(
                        context,
                        "Infinix",
                        "35 tipe tersedia",
                        "20",
                        "85",
                      ),

                      const SizedBox(height: 16),
                      _buildLetterHeader("O"),
                      _buildBrandListItem(
                        context,
                        "Oppo",
                        "56 tipe tersedia",
                        "65",
                        "150",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 3. Alphabet Sidebar (Floating on right)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSidebarLetter("A", true),
                      _buildSidebarLetter("B", false),
                      _buildSidebarLetter("C", false),
                      _buildSidebarLetter("D", true),
                      _buildSidebarLetter("E", false),
                      _buildSidebarLetter("•", false),
                      _buildSidebarLetter("I", true),
                      _buildSidebarLetter("•", false),
                      _buildSidebarLetter("O", true),
                      _buildSidebarLetter("•", false),
                      _buildSidebarLetter("Z", false),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildPopularBrand(BuildContext context, String name) {
    return GestureDetector(
      onTap: () => context.push('/brand-detail/$name'),
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/brand_${name.toLowerCase()}.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.phone_android_rounded, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterHeader(String letter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildBrandListItem(
    BuildContext context,
    String name,
    String typeCount,
    String courseCount,
    String productCount,
  ) {
    return GestureDetector(
      onTap: () => context.push('/brand-detail/$name'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _bgLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/brand_${name.toLowerCase()}.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.phone_android_rounded,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    typeCount,
                    style: TextStyle(fontSize: 12, color: _textGray),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "$courseCount Kursus",
                        style: TextStyle(
                          color: _primaryBlue,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "120 Produk",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarLetter(String text, bool isHighlight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isHighlight ? _primaryBlue : Colors.grey.shade500,
        ),
      ),
    );
  }
}
