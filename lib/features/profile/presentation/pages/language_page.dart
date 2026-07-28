import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);

  String _selectedLang = "ID"; // Options: ID, EN

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildLangOption(
                  title: "Bahasa Indonesia",
                  subtitle: "Bahasa utama antarmuka aplikasi",
                  icon: Icons.flag_rounded, // or text "ID"
                  value: "ID",
                ),
                Divider(height: 1, color: Colors.grey.shade100),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bahasa diubah ke: $title")),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? _primaryBlue.withValues(alpha: 0.1) : Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? _primaryBlue : Colors.grey.shade400,
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
                      color: isSelected ? _primaryBlue : _textDark,
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
            const SizedBox(width: 16),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: _primaryBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
