import 'package:flutter/material.dart';
// Jika Anda ingin mengimport bottom sheet filter, pastikan Anda juga mengimportnya
// import 'package:vbat_ponsel/features/shop/presentation/widgets/filter_bottom_sheet.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);
  final Color _orangeSale = const Color(0xFFFD761A);

  String _selectedTab = "Semua";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Column(
        children: [
          // --- 1. Top Bar & Tabs (Sticky) ---
          Container(
            color: _primaryBlue,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: [
                // Search Input Area
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: Colors.grey.shade500,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: "Cari sparepart, kursus, dll...",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.close_rounded,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tabs
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildTab("Semua"),
                      _buildTab("Produk"),
                      _buildTab("Kursus"),
                      _buildTab("Brand"),
                      _buildTab("Forum"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- 2. Main Content (Scrollable) ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                // Pencarian Terakhir
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pencarian Terakhir",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryBlue,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Hapus Semua",
                      style: TextStyle(color: _textGray, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildHistoryItem("Blower Quick 2008"),
                _buildHistoryItem("Skema iPhone 14 Pro Max"),
                _buildHistoryItem("IC Power Oppo"),
                const SizedBox(height: 24),

                // Pencarian Populer
                Text(
                  "Pencarian Populer",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPopularChip("LCD iPhone"),
                    _buildPopularChip("Baterai Samsung"),
                    _buildPopularChip("Solder T12"),
                    _buildPopularChip("Box Software"),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: Color(0xFFE2E8F0)),
                ),

                // Mixed Results
                _buildProductCard(),
                const SizedBox(height: 16),
                _buildSponsorBanner(),
                const SizedBox(height: 16),
                _buildVideoCard(),
                const SizedBox(height: 16),
                _buildForumCard(),
              ],
            ),
          ),
        ],
      ),
      // Contoh pemanggilan filter, bisa diaktifkan jika diperlukan
      /*
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryBlue,
        onPressed: () => FilterBottomSheet.show(context),
        icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
        label: const Text("Filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      */
    );
  }

  // --- Helper Widgets ---

  Widget _buildTab(String label) {
    bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? _orangeSale : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: _textGray, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(query, style: TextStyle(color: _textDark)),
          ),
          Icon(Icons.close_rounded, color: _textGray, size: 18),
        ],
      ),
    );
  }

  Widget _buildPopularChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(color: _textDark, fontSize: 13)),
    );
  }

  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.image, color: Colors.grey)),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _orangeSale,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "SPAREPART",
                      style: TextStyle(
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "LCD iPhone 13 Original BraderParts",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rp 450.000",
                        style: TextStyle(
                          color: _orangeSale,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorBanner() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const Center(
            child: Text(
              "Sponsor Banner Content",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Positioned(
            top: 4,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "SPONSORED",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.image, color: Colors.grey, size: 40),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "GRATIS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tutorial Ganti LCD iPhone 13",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.school_rounded, color: _textGray, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "Instruktur: Budi Teknisi",
                      style: TextStyle(color: _textGray, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.forum_rounded, color: _primaryBlue, size: 16),
              const SizedBox(width: 6),
              Text(
                "FORUM DISKUSI",
                style: TextStyle(
                  color: _primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Review LCD BraderParts vs Original",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _textDark,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Apakah ada yang sudah membandingkan hasil warna dan ketahanan layar dari BraderParts dengan yang asli cabutan?",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _textGray, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, color: _textGray, size: 14),
              const SizedBox(width: 4),
              Text(
                "12 Likes",
                style: TextStyle(color: _textGray, fontSize: 11),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: _textGray,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                "5 Comments",
                style: TextStyle(color: _textGray, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
