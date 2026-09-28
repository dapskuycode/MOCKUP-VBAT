import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardBg => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

  String _selectedLang = "ID"; // Options: ID, EN

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _cardBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _isDark ? Colors.blue.shade300 : _primaryBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Pengaturan Bahasa",
          style: TextStyle(
            color: _textDark,
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
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildLangOption(
                  title: "Bahasa Indonesia",
                  subtitle: "Bahasa utama antarmuka aplikasi",
                  icon: Icons.flag_rounded,
                  value: "ID",
                ),
                Divider(height: 1, color: _borderColor),
                _buildLangOption(
                  title: "English",
                  subtitle: "Application interface language",
                  icon: Icons.language_rounded,
                  value: "EN",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final bool isSelected = _selectedLang == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLang = value;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Bahasa diubah ke: $title")));
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (_isDark ? Colors.blue.withValues(alpha: 0.2) : _primaryBlue.withValues(alpha: 0.1))
                    : (_isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? (_isDark ? Colors.blue.shade300 : _primaryBlue)
                    : _textGray,
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
                          ? (_isDark ? Colors.blue.shade300 : _primaryBlue)
                          : _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: _textGray),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
