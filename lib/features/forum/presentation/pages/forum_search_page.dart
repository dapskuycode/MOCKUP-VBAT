import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';

class ForumSearchPage extends StatelessWidget {
  const ForumSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDark(context);
    final Color bgLight = isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
    final Color cardColor = isDark ? ThemeManager.darkCard : Colors.white;
    final Color textDark = isDark ? ThemeManager.darkText : const Color(0xFF001944);
    final Color textGray = isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text(
          "Cari di Forum",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          "Halaman Pencarian Forum\n(Segera Hadir)",
          textAlign: TextAlign.center,
          style: TextStyle(color: textGray, fontSize: 16),
        ),
      ),
    );
  }
}
