import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service untuk menangani penerimaan notifikasi sponsor (FCM Receiver Architecture)
/// Mendukung background message handler, foreground in-app alert, dan deep-linking sponsor URL.
class PushNotificationItem {
  final String id;
  final String title;
  final String body;
  final String? sponsorName;
  final String? targetUrl;
  final String? imageUrl;
  final DateTime receivedAt;
  bool isRead;

  PushNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.sponsorName,
    this.targetUrl,
    this.imageUrl,
    DateTime? receivedAt,
    this.isRead = false,
  }) : receivedAt = receivedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'sponsor_name': sponsorName,
        'target_url': targetUrl,
        'image_url': imageUrl,
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
      imageUrl: data['image_url'] ?? data['image'],
      receivedAt: parsedTime,
    );
  }
}

class PushNotificationService {
  static final StreamController<PushNotificationItem> _notificationStreamController =
      StreamController<PushNotificationItem>.broadcast();

  static Stream<PushNotificationItem> get onNotificationReceived =>
      _notificationStreamController.stream;

  static final List<PushNotificationItem> _history = [
    PushNotificationItem(
      id: 'demo-1',
      title: 'Diskon 30% Sparepart LCD BraderParts',
      body: 'Khusus member VbatPonsel! Dapatkan potongan langsung LCD iPhone & Samsung hari ini.',
      sponsorName: 'BraderParts Indonesia',
      targetUrl: 'https://shopee.co.id/brader_parts',
      receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PushNotificationItem(
      id: 'demo-2',
      title: 'Toolkit Titan Tools Bergaransi Resmi',
      body: 'Paket solder T12 dan mikroskop presisi siap dikirim ke alamat Anda.',
      sponsorName: 'TITAN Tools Official',
      targetUrl: 'https://tokopedia.com',
      receivedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static List<PushNotificationItem> get notifications => List.unmodifiable(_history);

  static int get unreadCount => _history.where((n) => !n.isRead).length;

  static String fcmToken = 'fcm_mock_token_${DateTime.now().millisecondsSinceEpoch}';

  /// Inisialisasi service saat aplikasi dibuka (main.dart)
  static Future<void> initialize() async {
    debugPrint('[PushNotificationService] FCM Receiver initialized. Token: $fcmToken');
    await fetchNotificationsFromBackend();
  }

  /// Sinkronisasi notifikasi langsung dari Backend Laravel API
  static Future<void> fetchNotificationsFromBackend() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api/v1',
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
          if (!existingIds.contains(item.id)) {
            _history.insert(0, item);
            existingIds.add(item.id);
          }
        }
      }
    } catch (e) {
      debugPrint('[PushNotificationService] Error fetching notifications: $e');
    }
  }

  /// Handler saat pesan FCM masuk di foreground / background
  static void handleIncomingMessage(Map<String, dynamic> payload, {BuildContext? context}) {
    final item = PushNotificationItem.fromPayload(payload);
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

  /// Melakukan deep-link / eksternal redirect saat user menekan notifikasi sponsor
  static Future<void> openNotificationTarget(PushNotificationItem item) async {
    item.isRead = true;
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
                            "Notifikasi & Promo Sponsor",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF001944),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${_history.length} Pesan",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _history.isEmpty
                        ? const Center(child: Text("Belum ada notifikasi"))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _history.length,
                            itemBuilder: (ctx, index) {
                              final notif = _history[index];
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF1B4F9B).withValues(alpha: 0.1),
                                    child: const Icon(Icons.storefront_rounded, color: Color(0xFF1B4F9B)),
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
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    openNotificationTarget(notif);
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
