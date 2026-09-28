import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class AnalyticsTracker {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: SessionManager.apiBaseUrl,
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static Future<void> trackEvent({
    required String eventType,
    String? targetType,
    int? targetId,
    Map<String, dynamic>? context,
  }) async {
    try {
      final Map<String, dynamic> eventItem = {'event_type': eventType};
      if (targetType != null) eventItem['target_type'] = targetType;
      if (targetId != null) eventItem['target_id'] = targetId;
      if (context != null) eventItem['context'] = context;

      final payload = {
        'events': [eventItem]
      };

      await _dio.post('/events', data: payload);
      debugPrint("Analytics event recorded: $eventType target: $targetType #$targetId");
    } catch (e) {
      debugPrint("Analytics tracking notice: $e");
    }
  }

  static Future<void> trackProductClick({
    int? productId,
    required String productName,
    String? url,
    String? platform,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'event_type': 'click',
        'product_name': productName,
      };
      if (productId != null) payload['product_id'] = productId;
      if (SessionManager.userId != null) payload['user_id'] = SessionManager.userId;
      if (SessionManager.userEmail.isNotEmpty) payload['email'] = SessionManager.userEmail;

      await _dio.post('/track', data: payload);
      debugPrint("[AnalyticsTracker] Click berhasil direkam ke /track untuk: $productName (ID: $productId)");
    } catch (e) {
      debugPrint("[AnalyticsTracker] trackProductClick notice: $e");
    }

    if (productId != null) {
      trackEvent(
        eventType: 'marketplace_outbound',
        targetType: 'product',
        targetId: productId,
        context: {
          'name': productName,
          if (url != null) 'url': url,
          if (platform != null) 'platform': platform,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  static void trackMarketplaceOutbound({
    required int productId,
    required String url,
    required String platform,
    String? productName,
  }) {
    if (productName != null && productName.isNotEmpty) {
      trackProductClick(
        productId: productId,
        productName: productName,
        url: url,
        platform: platform,
      );
    } else {
      trackEvent(
        eventType: 'marketplace_outbound',
        targetType: 'product',
        targetId: productId,
        context: {
          'url': url,
          'platform': platform,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  static Future<void> trackWishlist({
    int? productId,
    String? productName,
    required bool isAdded,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        if (productId != null) 'product_id': productId,
        if (productName != null) 'product_name': productName,
        if (SessionManager.userId != null) 'user_id': SessionManager.userId,
        if (SessionManager.userEmail.isNotEmpty) 'email': SessionManager.userEmail,
      };
      await _dio.post('/wishlist/toggle', data: payload);
    } catch (e) {
      debugPrint("[AnalyticsTracker] trackWishlist notice: $e");
    }

    if (productId != null) {
      trackEvent(
        eventType: isAdded ? 'wishlist_add' : 'wishlist_remove',
        targetType: 'product',
        targetId: productId,
        context: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  static void trackImpression({
    required String targetType,
    required int targetId,
  }) {
    trackEvent(
      eventType: 'impression',
      targetType: targetType,
      targetId: targetId,
    );
  }
}
