import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardBg => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;

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
          "Riwayat Transaksi",
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
          _buildTransactionCard(
            context,
            id: "TRX-001234",
            title: "Langganan Kelas Online Teknisi iPhone",
            date: "14 Feb 2024, 10:30 WIB",
            amount: "Rp 2.000.000",
            status: "Berhasil",
            statusColor: const Color(0xFF10B981),
            icon: Icons.school_rounded,
          ),
          const SizedBox(height: 12),
          _buildTransactionCard(
            context,
            id: "TRX-001180",
            title: "Pembelian: Blower Quick 850A",
            date: "02 Feb 2024, 14:15 WIB",
            amount: "Rp 650.000",
            status: "Dibatalkan",
            statusColor: const Color(0xFFEF4444),
            icon: Icons.shopping_bag_rounded,
          ),
          const SizedBox(height: 12),
          _buildTransactionCard(
            context,
            id: "TRX-001095",
            title: "Langganan Kelas Online Teknisi Android",
            date: "10 Jan 2024, 09:00 WIB",
            amount: "Rp 800.000",
            status: "Berhasil",
            statusColor: const Color(0xFF10B981),
            icon: Icons.school_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context, {
    required String id,
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _textGray,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: _isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.blue.withValues(alpha: 0.2)
                      : _primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 11, color: _textGray),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: _borderColor),
          const SizedBox(height: 12),

          // Footer: Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Pembayaran",
                style: TextStyle(fontSize: 12, color: _textGray),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
