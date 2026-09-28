import 'package:flutter/material.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';

class CreateThreadPage extends StatefulWidget {
  // Flag ini menentukan apakah yang membuka halaman ini admin atau bukan
  final bool isAdmin;

  const CreateThreadPage({super.key, this.isAdmin = false});

  @override
  State<CreateThreadPage> createState() => _CreateThreadPageState();
}

class _CreateThreadPageState extends State<CreateThreadPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF0D2B5E);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  // States
  String _selectedCategory = "Pilih Kategori";
  bool _pinPost = false;
  bool _sendNotification = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cardColor,
      appBar: AppBar(
        backgroundColor: _cardColor,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: _isDark ? Colors.blue.shade300 : _primaryBlue, size: 20),
          label: Text(
            "Batal",
            style: TextStyle(color: _isDark ? Colors.blue.shade300 : _primaryBlue, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "Buat Thread",
          style: TextStyle(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _borderColor, height: 1),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Logika Publish Post
            },
            child: Text(
              "Posting",
              style: TextStyle(
                color: _isDark ? Colors.blue.shade300 : _primaryBlue,
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
                        bottom: BorderSide(color: _borderColor),
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
                      hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.7)),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: _borderColor),

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
                    color: _isDark ? Colors.black26 : _bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _borderColor,
                      style: BorderStyle.solid,
                    ),
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
            Divider(height: 1, color: _borderColor),

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
                        color: _isDark ? Colors.black26 : _bgLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.campaign_rounded,
                            color: _isDark ? Colors.blue.shade300 : _primaryBlue,
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
                          color: _cardColor,
                          border: Border.all(color: _borderColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategory,
                              style: TextStyle(
                                color: _selectedCategory == "Pilih Kategori"
                                    ? _textGray
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
                        side: BorderSide(color: _isDark ? Colors.blue.shade300 : _primaryBlue, width: 2),
                        foregroundColor: _isDark ? Colors.blue.shade300 : _primaryBlue,
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
      backgroundColor: _cardColor,
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
                    style: TextStyle(fontWeight: FontWeight.w500, color: _textDark),
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
