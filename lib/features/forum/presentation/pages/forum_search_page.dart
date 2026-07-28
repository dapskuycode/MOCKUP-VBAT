import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForumSearchPage extends StatelessWidget {
  const ForumSearchPage({super.key});

  final Color _primaryBlue = const Color(0xFF1B4F9B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari di Forum"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _primaryBlue),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          "Halaman Pencarian Forum\n(Segera Hadir)",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      ),
    );
  }
}
