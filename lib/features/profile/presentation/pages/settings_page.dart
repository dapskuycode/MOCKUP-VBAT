import 'package:flutter/material.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';

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
  void initState() {
    super.initState();
    _syncThemeFromManager();
    ThemeManager.themeModeNotifier.addListener(_syncThemeFromManager);
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_syncThemeFromManager);
    super.dispose();
  }

  void _syncThemeFromManager() {
    if (!mounted) return;
    setState(() {
      switch (ThemeManager.themeMode) {
        case ThemeMode.dark:
          _selectedTheme = "Gelap";
          break;
        case ThemeMode.system:
          _selectedTheme = "Otomatis";
          break;
        case ThemeMode.light:
          _selectedTheme = "Terang";
          break;
      }
    });
  }

  void _onThemeSelected(String title) {
    setState(() => _selectedTheme = title);
    ThemeMode mode;
    if (title == "Gelap") {
      mode = ThemeMode.dark;
    } else if (title == "Otomatis") {
      mode = ThemeMode.system;
    } else {
      mode = ThemeMode.light;
    }
    ThemeManager.setTheme(mode);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Tema tampilan diubah ke: $title"),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDark(context);
    final Color bgColor = isDark ? ThemeManager.darkBg : _bgLight;
    final Color cardColor = isDark ? ThemeManager.darkCard : Colors.white;
    final Color textColor = isDark ? ThemeManager.darkText : _textDark;
    final Color subtextColor = isDark ? ThemeManager.darkTextSecondary : _textGray;
    final Color borderColor = isDark ? ThemeManager.darkBorder : _borderColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF151B26) : _primaryBlue,
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
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildThemeOption("Terang", Icons.light_mode_rounded, isDark, cardColor, borderColor),
              const SizedBox(width: 12),
              _buildThemeOption("Gelap", Icons.dark_mode_outlined, isDark, cardColor, borderColor),
              const SizedBox(width: 12),
              _buildThemeOption("Otomatis", Icons.settings_brightness_rounded, isDark, cardColor, borderColor),
            ],
          ),
          const SizedBox(height: 32),

          // --- 2. Notifikasi ---
          _buildSectionCard(
            title: "Notifikasi",
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            children: [
              _buildSwitchTile(
                "Notifikasi Transaksi",
                _notifTransaksi,
                (val) => setState(() => _notifTransaksi = val),
                textColor,
              ),
              _buildDivider(borderColor),
              _buildSwitchTile(
                "Notifikasi Forum",
                _notifForum,
                (val) => setState(() => _notifForum = val),
                textColor,
              ),
              _buildDivider(borderColor),
              _buildSwitchTile(
                "Notifikasi Promo",
                _notifPromo,
                (val) => setState(() => _notifPromo = val),
                textColor,
              ),
              _buildDivider(borderColor),
              _buildSwitchTile(
                "Pengingat Belajar Harian",
                _notifPengingat,
                (val) => setState(() => _notifPengingat = val),
                textColor,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- 3. Bahasa ---
          _buildSectionCard(
            title: "Bahasa",
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            children: [
              _buildLanguageTile("Indonesia", textColor, isDark),
              _buildDivider(borderColor),
              _buildLanguageTile("English", textColor, isDark),
            ],
          ),
          const SizedBox(height: 24),

          // --- 4. Informasi ---
          _buildSectionCard(
            title: "Informasi",
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            children: [
              _buildLinkTile("Kebijakan Privasi", Icons.chevron_right_rounded, textColor, subtextColor),
              _buildDivider(borderColor),
              _buildLinkTile("Syarat & Ketentuan", Icons.chevron_right_rounded, textColor, subtextColor),
              _buildDivider(borderColor),
              _buildLinkTile(
                "Tentang VBat Ponsel",
                Icons.chevron_right_rounded,
                textColor,
                subtextColor,
              ),
              _buildDivider(borderColor),
              _buildLinkTile(
                "Hubungi Bantuan",
                Icons.open_in_new_rounded,
                textColor,
                subtextColor,
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
                color: subtextColor,
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
  Widget _buildThemeOption(
    String title,
    IconData icon,
    bool isDark,
    Color cardColor,
    Color borderColor,
  ) {
    bool isSelected = _selectedTheme == title;
    final Color activeColor = isDark ? const Color(0xFF60A5FA) : _primaryBlue;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onThemeSelected(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? activeColor : borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (!isSelected && !isDark)
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
                      color: isSelected ? activeColor : (isDark ? Colors.grey.shade400 : _textGray),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? activeColor : (isDark ? Colors.white : _textGray),
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
                      color: activeColor,
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
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
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
              color: isDark
                  ? const Color(0xFF243042)
                  : const Color(0xFFF1F3FF).withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // Item Notifikasi (Switch)
  Widget _buildSwitchTile(
    String title,
    bool value,
    Function(bool) onChanged,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: textColor)),
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
  Widget _buildLanguageTile(String language, Color textColor, bool isDark) {
    bool isSelected = _selectedLanguage == language;
    final Color activeColor = isDark ? const Color(0xFF60A5FA) : _primaryBlue;

    return InkWell(
      onTap: () => setState(() => _selectedLanguage = language),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language, style: TextStyle(fontSize: 15, color: textColor)),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : (isDark ? Colors.grey.shade600 : _textGray),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: activeColor,
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
    IconData trailingIcon,
    Color textColor,
    Color subtextColor, {
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
                color: isPrimary ? _primaryBlue : textColor,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Icon(
              trailingIcon,
              color: isPrimary ? _primaryBlue : subtextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Garis Pemisah (Divider)
  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, color: borderColor);
  }
}
