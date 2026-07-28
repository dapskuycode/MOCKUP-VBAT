import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);
  final Color _borderColor = const Color(0xFFE2E8F0);

  // States
  String _selectedTheme = "Terang";
  String _selectedLanguage = "Indonesia";

  bool _notifTransaksi = true;
  bool _notifForum = true;
  bool _notifPromo = false;
  bool _notifPengingat = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pengaturan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // --- 1. Tema Tampilan ---
          Text(
            "Tema Tampilan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildThemeOption("Terang", Icons.light_mode_rounded),
              const SizedBox(width: 12),
              _buildThemeOption("Gelap", Icons.dark_mode_outlined),
              const SizedBox(width: 12),
              _buildThemeOption("Otomatis", Icons.settings_brightness_rounded),
            ],
          ),
          const SizedBox(height: 32),

          // --- 2. Notifikasi ---
          _buildSectionCard(
            title: "Notifikasi",
            children: [
              _buildSwitchTile(
                "Notifikasi Transaksi",
                _notifTransaksi,
                (val) => setState(() => _notifTransaksi = val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                "Notifikasi Forum",
                _notifForum,
                (val) => setState(() => _notifForum = val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                "Notifikasi Promo",
                _notifPromo,
                (val) => setState(() => _notifPromo = val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                "Pengingat Belajar Harian",
                _notifPengingat,
                (val) => setState(() => _notifPengingat = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- 3. Bahasa ---
          _buildSectionCard(
            title: "Bahasa",
            children: [
              _buildLanguageTile("Indonesia"),
              _buildDivider(),
              _buildLanguageTile("English"),
            ],
          ),
          const SizedBox(height: 24),

          // --- 4. Informasi ---
          _buildSectionCard(
            title: "Informasi",
            children: [
              _buildLinkTile("Kebijakan Privasi", Icons.chevron_right_rounded),
              _buildDivider(),
              _buildLinkTile("Syarat & Ketentuan", Icons.chevron_right_rounded),
              _buildDivider(),
              _buildLinkTile(
                "Tentang VBat Ponsel",
                Icons.chevron_right_rounded,
              ),
              _buildDivider(),
              _buildLinkTile(
                "Hubungi Bantuan",
                Icons.open_in_new_rounded,
                isPrimary: true,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // --- 5. Footer Version ---
          Center(
            child: Text(
              "VBat Ponsel v1.0.0",
              style: TextStyle(
                color: _textGray,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  // Pilihan Tema
  Widget _buildThemeOption(String title, IconData icon) {
    bool isSelected = _selectedTheme == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTheme = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _primaryBlue : _borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? _primaryBlue : _textGray,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? _primaryBlue : _textGray,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: -8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Wrapper untuk Kartu Pengaturan
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(
                0xFFF1F3FF,
              ).withValues(alpha: 0.5), // surface-container-low
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: _borderColor)),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // Item Notifikasi (Switch)
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: _textDark)),
          Switch.adaptive(
            value: value,
            activeThumbColor: _primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Item Bahasa (Radio Button Custom)
  Widget _buildLanguageTile(String language) {
    bool isSelected = _selectedLanguage == language;
    return InkWell(
      onTap: () => setState(() => _selectedLanguage = language),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language, style: TextStyle(fontSize: 15, color: _textDark)),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primaryBlue : _textGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Item Link (Syarat, Privasi, dll)
  Widget _buildLinkTile(
    String title,
    IconData trailingIcon, {
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isPrimary ? _primaryBlue : _textDark,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Icon(
              trailingIcon,
              color: isPrimary ? _primaryBlue : _textGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Garis Pemisah (Divider)
  Widget _buildDivider() {
    return Divider(height: 1, color: _borderColor);
  }
}
