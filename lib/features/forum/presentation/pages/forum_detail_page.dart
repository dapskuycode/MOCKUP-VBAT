import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForumDetailPage extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ForumDetailPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF1B4F9B);
    final Color bgLight = const Color(0xFFF5F7FA);
    final Color textDark = const Color(0xFF001944);
    
    // Fallback data jika null (terjadi jika state extra GoRouter hilang akibat Hot Reload)
    final infoData = data ?? {
      "category": "Ruang Konsultasi",
      "title": "Jadwal Konsultasi Tanya Jawab Kasus Bersama Instruktur",
      "content": "Halo Sobat Teknisi,\n\nMengingatkan kembali bahwa sesi konsultasi teknikal minggu ini akan diadakan secara live (via Zoom/Grup) pada hari Jumat pukul 19.30 WIB.\n\nSilakan siapkan pertanyaan mengenai studi kasus perbaikan (troubleshooting) HP, analisa skema jalur, maupun kendala-kendala software dan hardware yang belum terselesaikan di tempat servis masing-masing.\n\nHarap mencatat detail kasus (Tipe HP, Kronologi kerusakaan, dan hasil pengecekan tegangan) agar pembahasan bisa langsung tepat sasaran.\n\nTerima kasih dan salam solder!",
      "date": "1 Jam yang lalu",
      "imageUrl": "https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
    };

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primaryBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Detail Informasi",
          style: TextStyle(
            color: primaryBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (infoData['imageUrl'] != null)
              Image.network(
                infoData['imageUrl'],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      infoData['category'],
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    infoData['title'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        infoData['date'],
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 48, thickness: 1),
                  Text(
                    infoData['content'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
