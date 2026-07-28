import 'package:flutter/material.dart';

class CreateThreadPage extends StatefulWidget {
  // Flag ini menentukan apakah yang membuka halaman ini admin atau bukan
  final bool isAdmin;

  const CreateThreadPage({super.key, this.isAdmin = false});

  @override
  State<CreateThreadPage> createState() => _CreateThreadPageState();
}

class _CreateThreadPageState extends State<CreateThreadPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF0D2B5E);
  final Color _textGray = const Color(0xFF737782);

  // States
  String _selectedCategory = "Pilih Kategori";
  bool _pinPost = false;
  bool _sendNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1, // Sedikit shadow untuk pembatas
        shadowColor: Colors.black.withValues(alpha: 0.2),
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: _primaryBlue, size: 20),
          label: Text(
            "Batal",
            style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "Buat Thread",
          style: TextStyle(
            color: _primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Logika Publish Post
            },
            child: Text(
              "Posting",
              style: TextStyle(
                color: _primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- 1. Admin Indicator (Muncul HANYA jika Admin) ---
            if (widget.isAdmin)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: _primaryBlue,
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Mode Admin — Postingan ditandai Resmi VBat",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // --- 2. Form Input (Judul & Konten) ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.isAdmin
                          ? "Judul pengumuman..."
                          : "Judul thread...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                    ),
                  ),

                  // Text Formatting Toolbar
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.format_bold_rounded,
                            color: _textGray,
                          ),
                          onPressed: () {},
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.format_italic_rounded,
                            color: _textGray,
                          ),
                          onPressed: () {},
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.format_list_bulleted_rounded,
                            color: _textGray,
                          ),
                          onPressed: () {},
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: Icon(Icons.link_rounded, color: _textGray),
                          onPressed: () {},
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Text Area Content
                  TextField(
                    maxLines: 8,
                    style: TextStyle(
                      fontSize: 16,
                      color: _textDark,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.isAdmin
                          ? "Tuliskan detail pengumuman di sini..."
                          : "Bagikan pertanyaan, tips, atau masalahmu di sini...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            // --- 3. Media Attachment ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  // Logika unggah gambar
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ), // Flutter tdk memiliki dashed border bawaan yg mudah, solid lebih aman
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 40, color: _textGray),
                      const SizedBox(height: 8),
                      Text(
                        widget.isAdmin
                            ? "Tambahkan Gambar Banner"
                            : "Tambahkan Foto (Opsional)",
                        style: TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Maks. 5MB (JPG, PNG)",
                        style: TextStyle(color: _textGray, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            // --- 4. Kategori & Opsi ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kategori",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Kategori Selector (Berbeda antara Admin & User)
                  if (widget.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _bgLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.campaign_rounded,
                            color: _primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Pengumuman Resmi",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _textDark,
                              ),
                            ),
                          ),
                          Icon(Icons.lock_rounded, color: _textGray, size: 18),
                        ],
                      ),
                    )
                  else
                    InkWell(
                      onTap:
                          _showCategoryBottomSheet, // Munculkan pilihan kategori untuk user biasa
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategory,
                              style: TextStyle(
                                color: _selectedCategory == "Pilih Kategori"
                                    ? Colors.grey.shade500
                                    : _textDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: _textGray,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Opsi Tambahan (Hanya muncul jika Admin)
                  if (widget.isAdmin) ...[
                    _buildAdminOption(
                      title: "Sematkan di atas feed (Pin)",
                      subtitle:
                          "Postingan akan selalu berada di urutan teratas",
                      value: _pinPost,
                      onChanged: (val) => setState(() => _pinPost = val),
                    ),
                    const SizedBox(height: 16),
                    _buildAdminOption(
                      title: "Kirim notifikasi ke semua user",
                      subtitle:
                          "Push notification akan dikirimkan secara instan",
                      value: _sendNotification,
                      onChanged: (val) =>
                          setState(() => _sendNotification = val),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),

            // --- 5. Primary Actions ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Publikasikan Sekarang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _primaryBlue, width: 2),
                        foregroundColor: _primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Simpan sebagai Draft",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
  }

  // --- Helper Widgets ---

  Widget _buildAdminOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: _textGray)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeThumbColor: _primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Bottom Sheet untuk memilih Kategori (Bagi User Biasa)
  void _showCategoryBottomSheet() {
    final List<String> categories = [
      "Tips & Trik",
      "Tanya Jawab",
      "Diskusi Umum",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Pilih Kategori",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 16),
              ...categories.map(
                (cat) => ListTile(
                  title: Text(
                    cat,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
