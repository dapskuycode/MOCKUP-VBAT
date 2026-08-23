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
  
  // Warna brand WhatsApp
  final Color _waGreen = const Color(0xFF25D366);

  String _selectedCategory = "Semua";
  
  // Simulasi status premium pengguna
  bool _isPremiumSimulation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      // --- FAB WhatsApp Helpdesk (Hanya untuk Premium) ---
      floatingActionButton: _isPremiumSimulation 
        ? FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Membuka WhatsApp: wa.me/62811268717 (Pak Tomi)"),
                  backgroundColor: Color(0xFF25D366),
                )
              );
            },
            backgroundColor: _waGreen,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text("Bantuan (Premium)", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        : null,
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
              "Pusat Informasi",
              style: TextStyle(
                color: _primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            actions: [
              // Toggle simulasi Premium
              Row(
                children: [
                  Text(
                    _isPremiumSimulation ? "Premium" : "Free",
                    style: TextStyle(
                      color: _isPremiumSimulation ? Colors.orange.shade700 : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                  ),
                  Switch(
                    value: _isPremiumSimulation,
                    activeColor: Colors.orange,
                    onChanged: (val) {
                      setState(() {
                        _isPremiumSimulation = val;
                      });
                    },
                  ),
                ],
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
          
          // Spacer for FAB
          SliverToBoxAdapter(
            child: SizedBox(height: _isPremiumSimulation ? 80 : 24),
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
          color: isSelected ? _primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : _textGray,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                data['imageUrl'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data['category'],
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Judul
                Text(
                  data['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001944),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Konten (Preview)
                Text(
                  data['content'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Action dummy
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Membuka detail: ${data['title']}"))
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Lihat Selengkapnya", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
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
        "content": "Jangan lewatkan sesi live Q&A via Zoom eksklusif untuk member Premium. Siapkan kasus terberat kalian dan mari kita bahas tuntas bersama instruktur senior dari Quantum Semarang.",
        "date": "Hari ini, 10:00",
        "imageUrl": "https://img.freepik.com/free-photo/repairman-fixing-broken-smartphone_171337-18451.jpg",
      },
      {
        "category": "Lowongan Pekerjaan",
        "title": "Dibutuhkan Segera: Teknisi Senior di Quantum Telecom Pontianak",
        "content": "Kami membuka lowongan bagi lulusan VbatPonsel yang telah menguasai reparasi iPhone dan Android tingkat dewa (Level 3). Penempatan di cabang baru Pontianak dengan benefit menarik.",
        "date": "Kemarin",
        "imageUrl": null,
      },
      {
        "category": "Upgrade Kelas Offline",
        "title": "Roadshow Training Teknisi Ponsel - Pontianak",
        "content": "Dibimbing langsung dari nol menjadi teknisi profesional. Segera daftarkan diri Anda pada roadshow offline terdekat di Pontianak. Kuota sangat terbatas!",
        "date": "2 hari yang lalu",
        "imageUrl": "https://img.freepik.com/free-vector/gradient-mobile-repair-logo-template_23-2149806497.jpg",
      },
      {
        "category": "Magang",
        "title": "Program Magang Intensif 3 Bulan (Batch 4)",
        "content": "Bagi alumni yang membutuhkan jam terbang dan pengalaman menghadapi pelanggan secara nyata, pendaftaran program magang Batch 4 kini resmi dibuka. Tersedia mes/tempat tinggal.",
        "date": "1 minggu yang lalu",
        "imageUrl": null,
      },
    ];

    if (_selectedCategory == "Semua") {
      return allPosts;
    }
    return allPosts.where((post) => post['category'] == _selectedCategory).toList();
  }
}
