import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PricelistPage extends StatefulWidget {
  const PricelistPage({super.key});

  @override
  State<PricelistPage> createState() => _PricelistPageState();
}

class _PricelistPageState extends State<PricelistPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _accentOrange = const Color(0xFFFD761A);
  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _simulatePayment(String package) {
    // Tampilkan loading sebentar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.pop(context); // Tutup dialog loading

      // Simpan status bahwa user sudah bayar (gunakan state sementara via Router extra atau global state)
      // Untuk mockup, kita cukup lempar parameter kembali ke learning page atau pushReplacement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil Berlangganan: $package!"),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman sebelumnya dengan parameter true (berhasil bayar)
      context.pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- Header ---
              SliverAppBar(
                backgroundColor: _bgLight,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.black87),
                  onPressed: () => context.pop(false),
                ),
                title: const Text(
                  "Pilih Paket Belajar",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
              ),

              // --- Banner Content ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.rocket_launch_rounded,
                          size: 48,
                          color: _primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Investasi Terbaik Untuk Masa Depanmu!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: Color(0xFF001944),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Dapatkan akses eksklusif ke seluruh materi VBat Ponsel dan pelajari teknik servis profesional dari para ahli.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Pricing Cards ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPricingCard(
                      title: "Kelas Android",
                      subtitle: "Materi Android + Hardware Solution Android",
                      normalPrice: "Rp 1.500.000",
                      promoPrice: "Rp 800.000",
                      features: [
                        "Akses Video Materi Android Sepuasnya",
                        "Dokumen Hardware Solution Android",
                        "Sertifikat Kelulusan",
                        "Grup Diskusi Android",
                      ],
                      icon: Icons.android_rounded,
                      color: const Color(0xFF3DDC84), // Android Green
                      onTap: () => _simulatePayment("Kelas Android"),
                    ),
                    const SizedBox(height: 16),
                    _buildPricingCard(
                      title: "Kelas iPhone",
                      subtitle: "Materi iPhone + Hardware Solution iPhone",
                      normalPrice: "Rp 3.500.000",
                      promoPrice: "Rp 2.000.000",
                      features: [
                        "Akses Video Materi iPhone Sepuasnya",
                        "Dokumen Hardware Solution iPhone",
                        "Sertifikat Kelulusan Premium",
                        "Grup Diskusi iPhone",
                      ],
                      icon: Icons.apple_rounded,
                      color: const Color(0xFF555555), // Apple Gray
                      onTap: () => _simulatePayment("Kelas iPhone"),
                    ),
                    const SizedBox(height: 16),
                    _buildPricingCard(
                      title: "Paket Bundling",
                      subtitle: "Akses Penuh Semua Kelas & Hardware Solution",
                      normalPrice: "Rp 5.000.000",
                      promoPrice: "Rp 2.500.000",
                      features: [
                        "Semua Fitur Kelas Android",
                        "Semua Fitur Kelas iPhone",
                        "Prioritas Support Ahli",
                        "Akses Alumni s/d Januari 2027",
                      ],
                      icon: Icons.workspace_premium_rounded,
                      color: _accentOrange,
                      isBestValue: true,
                      onTap: () => _simulatePayment("Paket Bundling"),
                    ),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String subtitle,
    required String normalPrice,
    required String promoPrice,
    required List<String> features,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isBestValue = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBestValue ? color : Colors.grey.shade200,
          width: isBestValue ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF001944),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      normalPrice,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                Text(
                  promoPrice,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),
                ...features.map(
                  (feat) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: color,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feat,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: isBestValue ? 4 : 0,
                    ),
                    child: const Text(
                      "Simulasi Bayar",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isBestValue)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFD761A), Color(0xFFF95316)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFD761A).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "PALING HEMAT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
