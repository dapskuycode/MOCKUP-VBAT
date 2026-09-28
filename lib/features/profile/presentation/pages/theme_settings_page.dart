import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);

  String _selectedTheme = "Terang"; // Options: Terang, Gelap, Sistem

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
          _selectedTheme = "Sistem";
          break;
        case ThemeMode.light:
          _selectedTheme = "Terang";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDark(context);
    final Color bgColor = isDark ? ThemeManager.darkBg : _bgLight;
    final Color cardColor = isDark ? ThemeManager.darkCard : Colors.white;
    final Color textColor = isDark ? ThemeManager.darkText : _textDark;
    final Color textSubtitleColor =
        isDark ? ThemeManager.darkTextSecondary : _textGray;
    final Color borderColor =
        isDark ? ThemeManager.darkBorder : Colors.grey.shade200;
    final Color dividerColor =
        isDark ? ThemeManager.darkBorder : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : _primaryBlue,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Pengaturan Tema",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildThemeOption(
                  title: "Tema Terang",
                  subtitle: "Tampilan cerah standar aplikasi",
                  icon: Icons.light_mode_rounded,
                  value: "Terang",
                  textColor: textColor,
                  subtitleColor: textSubtitleColor,
                  isDark: isDark,
                ),
                Divider(height: 1, color: dividerColor),
                _buildThemeOption(
                  title: "Tema Gelap",
                  subtitle: "Tampilan gelap (nyaman di mata pada malam hari)",
                  icon: Icons.dark_mode_rounded,
                  value: "Gelap",
                  textColor: textColor,
                  subtitleColor: textSubtitleColor,
                  isDark: isDark,
                ),
                Divider(height: 1, color: dividerColor),
                _buildThemeOption(
                  title: "Sesuai Sistem",
                  subtitle: "Secara otomatis menyesuaikan tema perangkat",
                  icon: Icons.settings_system_daydream_rounded,
                  value: "Sistem",
                  textColor: textColor,
                  subtitleColor: textSubtitleColor,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color textColor,
    required Color subtitleColor,
    required bool isDark,
  }) {
    final bool isSelected = _selectedTheme == value;

    return InkWell(
      onTap: () {
        ThemeMode newMode;
        if (value == "Gelap") {
          newMode = ThemeMode.dark;
        } else if (value == "Sistem") {
          newMode = ThemeMode.system;
        } else {
          newMode = ThemeMode.light;
        }
        ThemeManager.setTheme(newMode);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tema berhasil diubah ke: $value"),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? _primaryBlue.withValues(alpha: 0.15)
                    : (isDark
                        ? const Color(0xFF243042)
                        : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? (isDark ? const Color(0xFF60A5FA) : _primaryBlue)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (isDark ? const Color(0xFF60A5FA) : _primaryBlue)
                          : textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: isDark ? const Color(0xFF60A5FA) : _primaryBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
