import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _orangeCTA = const Color(0xFFF78B00);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);
  final Color _greenBadge = const Color(0xFFE8F5E9);
  final Color _greenText = const Color(0xFF2E7D32);

  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 340,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 340,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _primaryBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Pilih Paket Kelas",
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSubscriptionCard(
                context,
                title: "KELAS ONLINE TEKNISI ANDROID",
                price: "800.000",
                perMonth: "HANYA RP 66.667/BULAN",
                features: [
                  "Di training instruktur berpengalaman",
                  "GRATIS Borneo Schematic 1 bulan",
                  "Bebas Konsultasi Selamanya",
                  "Bonus materi Bisnis / Scale Up usaha",
                  "Mendapatkan E-Sertifikat pelatihan",
                  "Akses video materi seumur hidup",
                  "Konsultasi via WhatsApp Group",
                  "Live session tanya jawab mingguan",
                ],
                buttonText: "PILIH KELAS ONLINE\nTEKNISI ANDROID",
              ),
              const SizedBox(width: 16),
              _buildSubscriptionCard(
                context,
                title: "KELAS ONLINE TEKNISI IPHONE",
                price: "2.000.000",
                perMonth: "HANYA RP 166.667/BULAN",
                features: [
                  "30x Live Streaming (interaktif, bukan rekaman)!",
                  "3x per minggu | 1,5 jam / pertemuan",
                  "Rekaman kelas (bisa diulang)!",
                  "Grup diskusi teknisi (WhatsApp / Telegram)",
                  "Bimbingan kasus real peserta",
                  "File schematic & boardview iPhone",
                  "Sertifikat Pelatihan",
                  "Bebas konsultasi setelah kelas selesai",
                ],
                buttonText: "PILIH KELAS ONLINE\nTEKNISI IPHONE",
              ),
              const SizedBox(width: 16),
              _buildSubscriptionCard(
                context,
                title: "KELAS OFFLINE TEKNISI ANDROID",
                price: "4.000.000",
                perMonth: "HANYA RP 333.334/BULAN",
                features: [
                  "GRATIS Borneo Schematic 1 bulan",
                  "GRATIS Kaos Official LPK Quantum",
                  "GRATIS Antar jemput dari Bandara/Stasiun/Terminal",
                  "GRATIS Mess (kamar AC) bagi peserta luar kota Semarang",
                  "Dapur Umum dan peralatan masak disediakan",
                  "Sertifikat Training Resmi",
                  "GRATIS Mengulang di Kelas Berikutnya",
                  "Boleh bawa bahan Bedah kasus sendiri",
                ],
                buttonText: "PILIH KELAS OFFLINE\nTEKNISI ANDROID",
              ),
              const SizedBox(width: 16),
              _buildSubscriptionCard(
                context,
                title: "KELAS PRIVATE TEKNISI IPHONE",
                price: "15.000.000",
                perMonth: "HANYA RP 1.250.000/BULAN",
                features: [
                  "Sertifikat Training Resmi",
                  "GRATIS Kaos Official Quantum",
                  "GRATIS Antar jemput dari Bandara/Stasiun/Terminal",
                  "GRATIS Mess (kamar AC) bagi peserta luar kota Semarang",
                  "Dapur Umum dan peralatan masak disediakan",
                  "One-on-one training dengan instruktur",
                  "Sertifikat Training Resmi",
                  "GRATIS Mengulang di Kelas Berikutnya",
                ],
                buttonText: "PILIH KELAS PRIVATE\nTEKNISI IPHONE",
                isHighlight: true,
              ),
            ],
          ),
          
          // Navigation Arrows
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.chevron_left_rounded, color: _primaryBlue),
                  onPressed: _scrollLeft,
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: _primaryBlue),
                  onPressed: _scrollRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required String title,
    required String price,
    required String perMonth,
    required List<String> features,
    required String buttonText,
    bool isHighlight = false,
  }) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighlight ? _orangeCTA : Colors.grey.shade200,
          width: isHighlight ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHighlight ? _orangeCTA.withValues(alpha: 0.1) : _primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isHighlight ? _orangeCTA : _primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rp",
                style: TextStyle(
                  color: _textGray,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                price,
                style: TextStyle(
                  color: _textDark,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "/ 1 TAHUN",
            style: TextStyle(
              color: _textGray,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _greenBadge,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              perMonth,
              style: TextStyle(
                color: _greenText,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: features.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: _primaryBlue,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          features[index],
                          style: TextStyle(
                            color: _textDark,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Mengarahkan ke pembayaran $title")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isHighlight ? _orangeCTA : _primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      buttonText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isHighlight)
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
