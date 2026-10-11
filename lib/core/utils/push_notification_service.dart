import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

/// Item Notifikasi aplikasi (Promo sponsor, transaksi, forum, pengingat belajar, sistem)
class PushNotificationItem {
  final String id;
  final String title;
  final String body;
  final String? sponsorName;
  final String? targetUrl;
  final String? targetRoute;
  final String? imageUrl;
  final String category; // 'promo', 'transaksi', 'forum', 'pengingat_belajar', 'sistem'
  final DateTime receivedAt;
  bool isRead;

  PushNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.sponsorName,
    this.targetUrl,
    this.targetRoute,
    this.imageUrl,
    this.category = 'promo',
    DateTime? receivedAt,
    this.isRead = false,
  }) : receivedAt = receivedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'sponsor_name': sponsorName,
        'target_url': targetUrl,
        'target_route': targetRoute,
        'image_url': imageUrl,
        'category': category,
        'received_at': receivedAt.toIso8601String(),
        'is_read': isRead,
      };

  factory PushNotificationItem.fromPayload(Map<String, dynamic> data) {
    DateTime parsedTime = DateTime.now();
    if (data['sent_at'] != null) {
      try {
        parsedTime = DateTime.parse(data['sent_at']);
      } catch (_) {}
    }
    return PushNotificationItem(
      id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? 'Promo Sponsor Baru',
      body: data['body'] ?? data['message'] ?? 'Cek penawaran spesial sekarang juga!',
      sponsorName: data['sponsor_name'] ?? data['sponsor'] ?? 'Sponsor VbatPonsel',
      targetUrl: data['target_url'] ?? data['deep_link'] ?? data['link'] ?? 'https://shopee.co.id',
      targetRoute: data['target_route'],
      imageUrl: data['image_url'] ?? data['image'],
      category: (data['category'] ?? 'promo').toString().toLowerCase(),
      receivedAt: parsedTime,
    );
  }
}

class PushNotificationService {
  static const String _readStorageKey = 'read_notification_ids';
  static final Set<String> _readIds = {};

  static final StreamController<PushNotificationItem> _notificationStreamController =
      StreamController<PushNotificationItem>.broadcast();

  static Stream<PushNotificationItem> get onNotificationReceived =>
      _notificationStreamController.stream;

  // CW-09: riwayat notifikasi contoh dihapus. Notifikasi hanya berasal dari
  // server, sehingga aplikasi tidak menampilkan promo atau tautan yang tidak ada.
  static final List<PushNotificationItem> _history = <PushNotificationItem>[];

  static List<PushNotificationItem> get notifications {
    syncHardwareUnlockNotification();
    return List.unmodifiable(_history);
  }

  static int get unreadCount => _history.where((n) => !n.isRead).length;

  static String fcmToken = 'fcm_mock_token_${DateTime.now().millisecondsSinceEpoch}';

  /// Inisialisasi service saat aplikasi dibuka (main.dart)
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRead = prefs.getStringList(_readStorageKey) ?? [];
      _readIds.clear();
      _readIds.addAll(savedRead);

      for (final item in _history) {
        if (_readIds.contains(item.id)) {
          item.isRead = true;
        }
      }
    } catch (e) {
      debugPrint('[PushNotificationService] Error loading read state: $e');
    }

    debugPrint('[PushNotificationService] FCM Receiver initialized. Token: $fcmToken');
    await fetchNotificationsFromBackend();
    syncHardwareUnlockNotification();
  }

  /// Sinkronisasi notifikasi unlock Hardware Solution berdasarkan progress server (>= 90%)
  static void syncHardwareUnlockNotification() {
    if (SessionManager.isHardwareSolutionUnlocked) {
      final bool alreadyExists = _history.any((n) => n.id == 'hw-solution-unlocked');
      if (!alreadyExists) {
        final item = PushNotificationItem(
          id: 'hw-solution-unlocked',
          title: '🎉 Akses Hardware Solution Terbuka!',
          body: 'Selamat! Progres belajar Anda telah mencapai 90%+. Fitur Skematik & Solusi Hardware resmi terbuka untuk akun Anda.',
          category: 'pengingat_belajar',
          targetRoute: '/hardware-solution',
          receivedAt: DateTime.now(),
          isRead: _readIds.contains('hw-solution-unlocked'),
        );
        _history.insert(0, item);
      }
    }
  }

  /// Tandai notifikasi spesifik telah dibaca dan simpan secara persisten
  static Future<void> markAsRead(String id) async {
    final item = _history.firstWhere((n) => n.id == id, orElse: () => _history.first);
    if (item.id == id) {
      item.isRead = true;
      _readIds.add(id);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_readStorageKey, _readIds.toList());
      } catch (e) {
        debugPrint('[PushNotificationService] Error saving read state: $e');
      }
    }
  }

  /// Tandai semua notifikasi telah dibaca
  static Future<void> markAllAsRead() async {
    for (final item in _history) {
      item.isRead = true;
      _readIds.add(item.id);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_readStorageKey, _readIds.toList());
    } catch (e) {
      debugPrint('[PushNotificationService] Error saving all read: $e');
    }
  }

  /// Sinkronisasi notifikasi langsung dari Backend Laravel API
  static Future<void> fetchNotificationsFromBackend() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final res = await dio.get('/notifications');
      if (res.data != null && res.data['data'] != null) {
        final List list = res.data['data'];
        final Set<String> existingIds = _history.map((e) => e.id).toSet();
        for (final raw in list.reversed) {
          final item = PushNotificationItem.fromPayload(Map<String, dynamic>.from(raw));
          if (_readIds.contains(item.id)) {
            item.isRead = true;
          }
          if (!existingIds.contains(item.id)) {
            _history.insert(0, item);
            existingIds.add(item.id);
          }
        }
      }
    } catch (e) {
      debugPrint('[PushNotificationService] Notice: fetching notifications: $e');
    }
  }

  /// Handler saat pesan FCM masuk di foreground / background
  static void handleIncomingMessage(Map<String, dynamic> payload, {BuildContext? context}) {
    final item = PushNotificationItem.fromPayload(payload);
    if (_readIds.contains(item.id)) {
      item.isRead = true;
    }
    _history.insert(0, item);
    _notificationStreamController.add(item);

    if (context != null && context.mounted) {
      showForegroundBanner(context, item);
    }
  }

  /// Menampilkan popup / snackbar interaktif saat ada pesan promosi masuk ketika app terbuka
  static void showForegroundBanner(BuildContext context, PushNotificationItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1B4F9B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.campaign_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    item.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'BUKA',
          textColor: Colors.amber,
          onPressed: () => openNotificationTarget(item),
        ),
      ),
    );
  }

  /// Melakukan deep-link / eksternal redirect saat user menekan notifikasi
  static Future<void> openNotificationTarget(PushNotificationItem item) async {
    await markAsRead(item.id);
    if (item.targetUrl != null && item.targetUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(item.targetUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('[PushNotificationService] Failed to open URL: $e');
      }
    }
  }

  /// Dialog riwayat notifikasi untuk pengguna
  static void showNotificationHistoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            final notifs = notifications;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notifications_active_rounded, color: Color(0xFF1B4F9B)),
                          SizedBox(width: 8),
                          Text(
                            "Pemberitahuan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF001944),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await markAllAsRead();
                        },
                        child: const Text("Tandai Semua Dibaca", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: notifs.isEmpty
                        ? const Center(child: Text("Tidak ada notifikasi"))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: notifs.length,
                            itemBuilder: (context, index) {
                              final notif = notifs[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: notif.isRead ? Colors.white : const Color(0xFFEFF6FF),
                                child: ListTile(
                                  leading: Icon(
                                    notif.targetRoute != null
                                        ? Icons.lock_open_rounded
                                        : Icons.campaign_rounded,
                                    color: const Color(0xFF1B4F9B),
                                  ),
                                  title: Text(
                                    notif.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF001944),
                                    ),
                                  ),
                                  subtitle: Text(
                                    notif.body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                                  onTap: () async {
                                    Navigator.pop(ctx);
                                    await openNotificationTarget(notif);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
