import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class PricelistPage extends StatefulWidget {
  final String? highlightPackage;

  const PricelistPage({super.key, this.highlightPackage});

  @override
  State<PricelistPage> createState() => _PricelistPageState();
}

class _PricelistPageState extends State<PricelistPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _accentOrange = const Color(0xFFFD761A);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
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
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    _animController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _simulatePayment(String package, String price) {
    final orderId = "VBAT-ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _isDark ? const Color(0xFF2D3748) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B4F9B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.payment_rounded,
                            color: Color(0xFF1B4F9B),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Midtrans Snap Checkout",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textDark,
                              ),
                            ),
                            Text(
                              "Simulasi Pembayaran Gateway",
                              style: TextStyle(fontSize: 12, color: _textGray),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _isDark
                            ? Colors.amber.shade900.withValues(alpha: 0.3)
                            : Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "SANDBOX",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("No. Referensi", style: TextStyle(color: _textGray, fontSize: 13)),
                          Text(orderId, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textDark)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Paket Pembelajaran", style: TextStyle(color: _textGray, fontSize: 13)),
                          Text(package, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textDark)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Tagihan", style: TextStyle(color: _textGray, fontSize: 13)),
                          Text(
                            price,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1B4F9B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Pilih Hasil Transaksi (Testing Sandbox):",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGray),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _executeSuccessfulPayment(package);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 18),
                        SizedBox(width: 8),
                        Text("Bayar Sekarang (Konfirmasi Sukses)", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Transaksi berstatus Pending / Batal. Akses kelas tetap terkunci."),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Simulasi Pending / Batalkan"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _executeSuccessfulPayment(String package) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    final pkg = package.toLowerCase();
    // Sinkronisasi aktivasi membership KTA dan hak akses ke Laravel backend
    await SessionManager.activateMembershipOnBackend(pkg);

    if (!mounted) return;
    Navigator.pop(context); // close loader

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Pembayaran Berhasil! Hak akses $package dan KTA Digital telah aktif."),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop(true);
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
                  icon: Icon(Icons.close_rounded, color: _textDark),
                  onPressed: () => context.pop(false),
                ),
                title: Text(
                  "Pilih Paket Belajar",
                  style: TextStyle(
                    color: _textDark,
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
                          color: _isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Investasi Terbaik Untuk Masa Depanmu!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Dapatkan akses eksklusif ke seluruh materi VBat Ponsel dan pelajari teknik servis profesional dari para ahli.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textGray,
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
                      onTap: () => _simulatePayment("Kelas Android", "Rp 800.000"),
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
                      color: _isDark ? const Color(0xFF94A3B8) : const Color(0xFF555555), // Apple Gray
                      onTap: () => _simulatePayment("Kelas iPhone", "Rp 2.000.000"),
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
                      onTap: () => _simulatePayment("Paket Bundling", "Rp 2.500.000"),
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
    final bool isRequestedHighlight = widget.highlightPackage != null &&
        title.toLowerCase().contains(widget.highlightPackage!.toLowerCase());
    final bool effectiveHighlight = isBestValue || isRequestedHighlight;

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: effectiveHighlight ? color : _borderColor,
          width: effectiveHighlight ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: effectiveHighlight ? 0.15 : 0.08),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: _textGray,
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
                      style: TextStyle(
                        fontSize: 14,
                        color: _textGray,
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
                Divider(height: 1, color: _borderColor),
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
                            style: TextStyle(
                              fontSize: 13,
                              color: _textDark,
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
          if (effectiveHighlight)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBestValue
                        ? const [Color(0xFFFD761A), Color(0xFFF95316)]
                        : [color, color.withValues(alpha: 0.85)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isBestValue ? const Color(0xFFFD761A) : color)
                          .withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  isBestValue ? "PALING HEMAT" : "PAKET PILIHAN ANDA",
                  style: const TextStyle(
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
