import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);

  final Color _textGray = const Color(0xFF737782);
  final Color _orangeCTA = const Color(0xFFFD761A);

  String _selectedCategory = "Semua";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      // --- FAB (Buat Postingan Baru) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-thread'),
        backgroundColor: _orangeCTA,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- 1. Top App Bar ---
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: true,
            floating: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: _primaryBlue),
              onPressed: () => context.pop(),
            ),
            title: Text(
              "Forum Teknisi",
              style: TextStyle(
                color: _primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(Icons.search_rounded, color: _primaryBlue),
                onPressed: () => context.push('/forum-search'),
              ),
              IconButton(
                icon: Icon(Icons.add_rounded, color: _primaryBlue),
                onPressed: () => context.push('/create-thread'),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.grey.shade200, height: 1),
            ),
          ),

          // --- 2. Filter Kategori (Horizontal Scroll) ---
          SliverToBoxAdapter(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: _bgLight,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCategoryChip("Semua"),
                  _buildCategoryChip("Tips & Trik"),
                  _buildCategoryChip("Tanya Jawab"),
                  _buildCategoryChip("Pengumuman Resmi"),
                  _buildCategoryChip("Diskusi Umum"),
                ],
              ),
            ),
          ),

          // --- 4. Main Feed (Daftar Postingan) ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                 PostCard(
                  author: "Budi Teknisi",
                  badge: "Teknisi Senior",
                  badgeColor: Colors.blue.shade100,
                  badgeTextColor: _primaryBlue,
                  time: "2 jam yang lalu",
                  title: "Cara jumper IC Power iPhone 11",
                  content:
                      "Kasus masuk iPhone 11 mati total setelah jatuh. Cek tegangan vbat normal, tapi vdd main short tipis. Setelah angkat kaleng, ternyata jalur dekat IC power putus. Ini skema jumpernya brader.",
                  hasImage: true,
                  likes: "12 Suka",
                  comments: "5 Komentar",
                ),
                const SizedBox(height: 16),
                PostCard(
                  author: "Agus Fixit",
                  badge: "Pemula",
                  badgeColor: Colors.grey.shade200,
                  badgeTextColor: Colors.grey.shade700,
                  time: "5 jam yang lalu",
                  title: "Rekomendasi blower pemula?",
                  content:
                      "Malam suhu-suhu sekalian, mohon pencerahan. Saya baru mau buka konter kecil-kecilan. Budget terbatas, kira-kira rekomendasi blower yang awet untuk angkat IC dasar apa ya?",
                  hasImage: false,
                  likes: "4 Suka",
                  comments: "18 Komentar",
                ),
                const SizedBox(height: 100), // Safe area for FAB & Bottom Nav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? _primaryBlue.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? _primaryBlue : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? _primaryBlue : _textGray,
            ),
          ),
        ),
      ),
    );
  }

}

class PostCard extends StatefulWidget {
  final String author;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final String time;
  final String title;
  final String content;
  final bool hasImage;
  final String likes;
  final String comments;

  const PostCard({
    super.key,
    required this.author,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.time,
    required this.title,
    required this.content,
    required this.hasImage,
    required this.likes,
    required this.comments,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);

  bool _isLiked = false;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _likesCount = int.tryParse(widget.likes.split(' ').first) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/forum-detail'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Post (Avatar & Info)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade100,
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.author,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _textDark,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: widget.badgeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.badge,
                                style: TextStyle(
                                  color: widget.badgeTextColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.time,
                          style: TextStyle(fontSize: 11, color: _textGray),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    color: Colors.grey.shade400,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Menu opsi selengkapnya")),
                      );
                    },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // 2. Isi Teks Post
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: _textGray, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Gambar (Jika ada)
            if (widget.hasImage)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),

            // 4. Footer (Action Bar: Like & Comment)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Tombol Like Stateful
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (_isLiked) {
                              _isLiked = false;
                              _likesCount--;
                            } else {
                              _isLiked = true;
                              _likesCount++;
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                              color: _isLiked ? _primaryBlue : _textGray,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "$_likesCount Suka",
                              style: TextStyle(
                                color: _isLiked ? _primaryBlue : _textGray,
                                fontSize: 13,
                                fontWeight: _isLiked ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Tombol Comment
                      InkWell(
                        onTap: () => context.push('/forum-detail'),
                        child: Row(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, color: _textGray, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.comments,
                              style: TextStyle(
                                color: _textGray,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Membuka menu bagikan")),
                      );
                    },
                    child: Icon(Icons.share_outlined, color: _textGray, size: 20),
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
