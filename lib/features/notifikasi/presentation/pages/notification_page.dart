import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/utils/push_notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF0D2B5E);
  final Color _textGray = const Color(0xFF434751);
  final Color _unreadBg = const Color(0xFFEFF6FF);

  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  Future<void> _refreshNotifications() async {
    await PushNotificationService.fetchNotificationsFromBackend();
    if (mounted) {
      setState(() {});
    }
  }

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
          "Notifikasi",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // --- 1. Filter Chips (Horizontal Scroll) ---
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: _bgLight,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterChip("Semua"),
                _buildFilterChip("Promo"),
                _buildFilterChip("Transaksi"),
                _buildFilterChip("Forum"),
                _buildFilterChip("Pengingat Belajar"),
              ],
            ),
          ),

          // --- 2. Notification List (Scrollable) ---
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(16),
                children: [
                // Group: Sponsor & Promo Terkini
                if (_selectedFilter == 'Semua' || _selectedFilter == 'Promo') ...[
                  _buildGroupHeader("Promo Sponsor Resmi (FCM)"),
                  for (final notif in PushNotificationService.notifications)
                    _buildNotificationCard(
                      title: notif.title,
                      message: notif.body,
                      time: "${notif.receivedAt.hour}:${notif.receivedAt.minute.toString().padLeft(2, '0')}",
                      icon: Icons.campaign_rounded,
                      iconColor: const Color(0xFF1B4F9B),
                      isUnread: !notif.isRead,
                      targetUrl: notif.targetUrl,
                    ),
                  const SizedBox(height: 16),
                ],

                // Group: Hari Ini
                if (_selectedFilter == 'Semua' || _selectedFilter == 'Transaksi' || _selectedFilter == 'Forum') ...[
                  _buildGroupHeader("Hari Ini"),
                  if (_selectedFilter == 'Semua' || _selectedFilter == 'Transaksi')
                    _buildNotificationCard(
                      title: "Pesanan Anda telah dikirim",
                      message:
                          'Paket berisi "Obeng Set Pro" dan 2 item lainnya sedang dalam perjalanan menuju alamat Anda. Lacak pesanan Anda sekarang.',
                      time: "10:45 AM",
                      icon: Icons.shopping_bag_rounded,
                      isUnread: true,
                    ),
                  if (_selectedFilter == 'Semua' || _selectedFilter == 'Forum')
                    _buildNotificationCard(
                      title: "Balasan Baru di Diskusi Anda",
                      message:
                          'Budi Teknisi membalas pertanyaan Anda di topik "Cara Mengatasi Layar Bergaris pada Seri X".',
                      time: "09:15 AM",
                      icon: Icons.forum_rounded,
                      isUnread: true,
                    ),
                  const SizedBox(height: 24),
                ],

                // Group: Kemarin
                if (_selectedFilter == 'Semua' || _selectedFilter == 'Pengingat Belajar' || _selectedFilter == 'Promo') ...[
                  _buildGroupHeader("Kemarin"),
                  if (_selectedFilter == 'Semua' || _selectedFilter == 'Pengingat Belajar')
                    _buildNotificationCard(
                      title: "Jadwal Kelas Belajar",
                      message:
                          'Jangan lupa, kelas "Dasar Mikrosolder" akan dimulai dalam 1 jam. Persiapkan peralatan Anda.',
                      time: "Kemarin, 14:00 PM",
                      icon: Icons.notifications_rounded,
                      isUnread: false,
                    ),
                  if (_selectedFilter == 'Semua' || _selectedFilter == 'Promo')
                    _buildNotificationCard(
                      title: "Flash Sale Sparepart!",
                      message:
                          "Diskon hingga 50% untuk layar dan baterai original. Terbatas hanya hari ini!",
                      time: "Kemarin, 10:00 AM",
                      icon: Icons.local_offer_rounded,
                      iconColor: const Color(0xFFFD761A), // Orange CTA color
                      isUnread: false,
                      targetUrl: "https://shopee.co.id/brader_parts",
                    ),
                ],

                const SizedBox(height: 40), // Safe area
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? _primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : _textGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _textDark,
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required bool isUnread,
    Color? iconColor,
    String? targetUrl,
  }) {
    return GestureDetector(
      onTap: () async {
        if (targetUrl != null && targetUrl.isNotEmpty) {
          try {
            final uri = Uri.parse(targetUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } catch (_) {}
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? _unreadBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? _primaryBlue.withValues(alpha: 0.2)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread Dot Indicator
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 16, right: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _primaryBlue,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 16), // Spacer alignment if no dot
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? _primaryBlue).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? _primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: _textGray, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (targetUrl != null && targetUrl.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              "Buka Link",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.open_in_new_rounded, size: 12, color: _primaryBlue),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
