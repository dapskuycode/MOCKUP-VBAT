import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/push_notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);

  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardBg => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF0D2B5E);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF434751);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;
  Color get _unreadBg => _isDark ? const Color(0xFF1A2638) : const Color(0xFFEFF6FF);

  String _selectedFilter = 'Semua';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    _refreshNotifications();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await PushNotificationService.fetchNotificationsFromBackend();
      PushNotificationService.syncHardwareUnlockNotification();
    } catch (e) {
      _errorMessage = "Gagal memuat notifikasi terbaru. Silakan coba lagi.";
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<PushNotificationItem> _getFilteredNotifications() {
    final all = PushNotificationService.notifications;
    if (_selectedFilter == 'Semua') {
      return all;
    }
    String targetCat = 'promo';
    if (_selectedFilter == 'Transaksi') targetCat = 'transaksi';
    if (_selectedFilter == 'Forum') targetCat = 'forum';
    if (_selectedFilter == 'Pengingat Belajar') targetCat = 'pengingat_belajar';

    return all.where((n) => n.category.toLowerCase() == targetCat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredNotifications();
    final unreadCount = PushNotificationService.unreadCount;

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _isDark ? _cardBg : _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _isDark ? Colors.blue.shade300 : Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notifikasi",
              style: TextStyle(
                color: _isDark ? _textDark : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unreadCount > 0)
              Text(
                "$unreadCount pesan belum dibaca",
                style: TextStyle(
                  color: _isDark ? _textGray : Colors.white70,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () async {
                await PushNotificationService.markAllAsRead();
                if (mounted) setState(() {});
              },
              icon: Icon(Icons.done_all_rounded, color: _isDark ? Colors.blue.shade300 : Colors.white70, size: 16),
              label: Text(
                "Tandai Dibaca",
                style: TextStyle(color: _isDark ? Colors.blue.shade300 : Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // --- 1. Filter Chips (Horizontal Scroll) ---
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: _bgLight,
              border: Border(bottom: BorderSide(color: _borderColor)),
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
              color: _primaryBlue,
              child: _isLoading && filteredItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null && filteredItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: _textGray, fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _refreshNotifications,
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: const Text("Coba Lagi"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filteredItems.isEmpty
                          ? Center(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: _isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.notifications_none_rounded,
                                          size: 40,
                                          color: _textGray,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Belum Ada Notifikasi",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Tidak ada pembaruan untuk kategori '$_selectedFilter' saat ini.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _textGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final notif = filteredItems[index];
                                final isHardwareUnlock = notif.id == 'hw-solution-unlocked';

                                IconData icon = Icons.notifications_rounded;
                                Color iconColor = _primaryBlue;

                                if (isHardwareUnlock) {
                                  icon = Icons.lock_open_rounded;
                                  iconColor = Colors.green.shade700;
                                } else if (notif.category == 'promo') {
                                  icon = Icons.campaign_rounded;
                                  iconColor = const Color(0xFFFD761A);
                                } else if (notif.category == 'transaksi') {
                                  icon = Icons.shopping_bag_rounded;
                                  iconColor = Colors.teal;
                                } else if (notif.category == 'forum') {
                                  icon = Icons.forum_rounded;
                                  iconColor = Colors.indigo;
                                } else if (notif.category == 'pengingat_belajar') {
                                  icon = Icons.school_rounded;
                                  iconColor = _primaryBlue;
                                }

                                final timeStr = "${notif.receivedAt.hour.toString().padLeft(2, '0')}:${notif.receivedAt.minute.toString().padLeft(2, '0')}";

                                return _buildNotificationCard(
                                  item: notif,
                                  title: notif.title,
                                  message: notif.body,
                                  time: timeStr,
                                  icon: icon,
                                  iconColor: iconColor,
                                  isUnread: !notif.isRead,
                                  targetUrl: notif.targetUrl,
                                  targetRoute: notif.targetRoute,
                                  isHighlight: isHardwareUnlock,
                                );
                              },
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
            color: isSelected ? _primaryBlue : _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : _borderColor,
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

  Widget _buildNotificationCard({
    required PushNotificationItem item,
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required bool isUnread,
    Color? iconColor,
    String? targetUrl,
    String? targetRoute,
    bool isHighlight = false,
  }) {
    return GestureDetector(
      onTap: () async {
        // Tandai terbaca persisten
        await PushNotificationService.markAsRead(item.id);
        if (mounted) setState(() {});

        // Deep Link ke Route aplikasi (misal: /hardware-solution)
        if (targetRoute != null && targetRoute.isNotEmpty) {
          if (mounted) {
            context.push(targetRoute);
          }
          return;
        }

        // Redirect eksternal (Shopee/Tokopedia promo sponsor)
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
          color: isHighlight
              ? (_isDark ? const Color(0xFF143022) : const Color(0xFFF0FDF4))
              : (isUnread ? _unreadBg : _cardBg),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlight
                ? (_isDark ? Colors.green.shade600 : Colors.green.shade300)
                : (isUnread
                    ? (_isDark ? Colors.blue.shade700 : _primaryBlue.withValues(alpha: 0.25))
                    : _borderColor),
            width: isHighlight ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.04),
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
                margin: const EdgeInsets.only(top: 14, right: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isHighlight ? Colors.green.shade700 : _primaryBlue,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 8),

            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (iconColor ?? _primaryBlue).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? _primaryBlue, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (isHighlight)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "UNLOCKED",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: _textGray, height: 1.4),
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
                          color: _textGray,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (targetRoute != null && targetRoute.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              "Buka Akses",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isHighlight
                                    ? (_isDark ? Colors.green.shade400 : Colors.green.shade700)
                                    : (_isDark ? Colors.blue.shade300 : _primaryBlue),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: isHighlight
                                  ? (_isDark ? Colors.green.shade400 : Colors.green.shade700)
                                  : (_isDark ? Colors.blue.shade300 : _primaryBlue),
                            ),
                          ],
                        )
                      else if (targetUrl != null && targetUrl.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              "Buka Link",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 12,
                              color: _isDark ? Colors.blue.shade300 : _primaryBlue,
                            ),
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
