import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textGray = const Color(0xFF737782);

  // Warna brand WhatsApp
  final Color _waGreen = const Color(0xFF25D366);

  String _selectedCategory = "Semua";

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  bool get _isDark => ThemeManager.isDark(context);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _pageBgColor => _isDark ? ThemeManager.darkBg : _bgLight;
  Color get _textColor => _isDark ? Colors.white : const Color(0xFF001944);
  Color get _subtextColor => _isDark ? ThemeManager.darkTextSecondary : Colors.grey.shade700;
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  @override
  Widget build(BuildContext context) {
    final double bottomNavPadding = 72.0 + MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: _pageBgColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomNavPadding + 10.0),
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: SessionManager.activeEntitlements,
          builder: (context, entitlements, child) {
            final bool isMember = SessionManager.hasPermanentMembership || SessionManager.isPremium.value;
            return FloatingActionButton.extended(
              onPressed: () async {
                if (isMember) {
                  final text = Uri.encodeComponent(
                    "Halo Tim Support VBAT Official, saya member KTA ${SessionManager.membershipNumber} (${SessionManager.userName}) ingin berkonsultasi mengenai materi pembelajaran & teknis ponsel.",
                  );
                  final Uri waUri = Uri.parse('https://wa.me/6281234567890?text=$text');
                  if (!await launchUrl(
                    waUri,
                    mode: LaunchMode.externalApplication,
                  )) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal membuka WhatsApp'),
                        ),
                      );
                    }
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: Color(0xFFF97316)),
                          SizedBox(width: 8),
                          Text("Konsultasi WhatsApp VIP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: const Text(
                        "Layanan pendampingan WhatsApp VIP dan Ruang Konsultasi teknisi hanya tersedia bagi member yang membeli Kelas Android, iPhone, atau Bundling.",
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Nanti Saja"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.push('/pricelist');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4F9B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Lihat Paket Belajar"),
                        ),
                      ],
                    ),
                  );
                }
              },
              backgroundColor: isMember ? _waGreen : const Color(0xFFF97316),
              foregroundColor: Colors.white,
              elevation: 4,
              icon: Icon(isMember ? Icons.chat_bubble_outline_rounded : Icons.lock_rounded),
              label: Text(
                isMember ? "Bantuan VIP (WhatsApp)" : "Buka Konsultasi VIP",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- 1. Top App Bar ---
          SliverAppBar(
            backgroundColor: _cardColor,
            pinned: true,
            floating: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: _isDark ? Colors.white : _primaryBlue),
              onPressed: () => context.pop(),
            ),
            title: Text(
              "Pusat Informasi",
              style: TextStyle(
                color: _isDark ? Colors.white : _primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            actions: [
              // Toggle simulasi Premium
              ValueListenableBuilder<bool>(
                valueListenable: SessionManager.isPremium,
                builder: (context, isPremium, child) {
                  return Row(
                    children: [
                      Text(
                        isPremium ? "Premium" : "Free",
                        style: TextStyle(
                          color: isPremium
                              ? Colors.orange.shade700
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Switch(
                        value: isPremium,
                        activeThumbColor: Colors.orange,
                        onChanged: (val) {
                          SessionManager.isPremium.value = val;
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: _borderColor, height: 1),
            ),
          ),

          // --- 2. Filter Kategori (Horizontal Scroll) ---
          SliverToBoxAdapter(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: _pageBgColor,
                border: Border(bottom: BorderSide(color: _borderColor)),
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
                  _buildCategoryChip("Ruang Konsultasi"),
                  _buildCategoryChip("Lowongan Pekerjaan"),
                  _buildCategoryChip("Magang"),
                  _buildCategoryChip("Upgrade Kelas Offline"),
                ],
              ),
            ),
          ),

          // --- 3. Main Feed (Daftar Pengumuman Admin) ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _getFilteredPosts().map((post) {
                  return _buildInfoCard(post);
                }).toList(),
              ),
            ),
          ),

          // Spacer for FAB & Bottom Navigation Bar
          SliverToBoxAdapter(
            child: SizedBox(height: bottomNavPadding + 70.0),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String title) {
    bool isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue : (_isDark ? const Color(0xFF1E2430) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primaryBlue : _borderColor,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : (_isDark ? Colors.grey.shade400 : _textGray),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          if (!_isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Jika ada gambar
          if (data['imageUrl'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                data['imageUrl'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  width: double.infinity,
                  color: _isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                  child: Center(
                    child: Icon(
                      Icons.article_rounded,
                      size: 44,
                      color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori Label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withValues(alpha: _isDark ? 0.25 : 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data['category'],
                    style: TextStyle(
                      color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Judul
                Text(
                  data['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Konten (Preview)
                Text(
                  data['content'],
                  style: TextStyle(
                    fontSize: 14,
                    color: _subtextColor,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Waktu & Tombol Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['date'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/forum-detail', extra: data);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Lihat Selengkapnya",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  // --- Dummy Data ---
  List<Map<String, dynamic>> _getFilteredPosts() {
    List<Map<String, dynamic>> allPosts = [
      {
        "category": "Ruang Konsultasi",
        "title": "Jadwal Konsultasi Live Bersama Master Teknisi Bulan Ini",
        "content":
            "Jangan lewatkan sesi live Q&A via Zoom eksklusif untuk member Premium. Siapkan kasus terberat kalian dan mari kita bahas tuntas bersama instruktur senior dari Quantum Semarang.",
        "date": "Hari ini, 10:00",
        "imageUrl":
            "https://img.freepik.com/free-photo/repairman-fixing-broken-smartphone_171337-18451.jpg",
      },
      {
        "category": "Lowongan Pekerjaan",
        "title":
            "Dibutuhkan Segera: Teknisi Senior di Quantum Telecom Pontianak",
        "content":
            "Kami membuka lowongan bagi lulusan VbatPonsel yang telah menguasai reparasi iPhone dan Android tingkat dewa (Level 3). Penempatan di cabang baru Pontianak dengan benefit menarik.",
        "date": "Kemarin",
        "imageUrl": null,
      },
      {
        "category": "Upgrade Kelas Offline",
        "title": "Roadshow Training Teknisi Ponsel - Pontianak",
        "content":
            "Dibimbing langsung dari nol menjadi teknisi profesional. Segera daftarkan diri Anda pada roadshow offline terdekat di Pontianak. Kuota sangat terbatas!",
        "date": "2 hari yang lalu",
        "imageUrl":
            "https://img.freepik.com/free-vector/gradient-mobile-repair-logo-template_23-2149806497.jpg",
      },
      {
        "category": "Magang",
        "title": "Program Magang Intensif 3 Bulan (Batch 4)",
        "content":
            "Bagi alumni yang membutuhkan jam terbang dan pengalaman menghadapi pelanggan secara nyata, pendaftaran program magang Batch 4 kini resmi dibuka. Tersedia mes/tempat tinggal.",
        "date": "1 minggu yang lalu",
        "imageUrl": null,
      },
    ];

    if (_selectedCategory == "Semua") {
      return allPosts;
    }
    return allPosts
        .where((post) => post['category'] == _selectedCategory)
        .toList();
  }
}
