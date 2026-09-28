import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class FeedResult {
  final List<Map<String, dynamic>> items;
  final String? nextCursor;
  final bool hasMore;

  const FeedResult({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });
}

class FeedRepository {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: SessionManager.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  /// Fetch mixed Home Feed (materials + products)
  static Future<FeedResult> getHomeFeed({String? cursor, int perPage = 15}) async {
    try {
      final Map<String, dynamic> query = {'per_page': perPage};
      if (cursor != null) query['cursor'] = cursor;

      final response = await _dio.get(
        '/feed/home',
        queryParameters: query,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List rawData = response.data['data'] ?? [];
        final meta = response.data['meta'] ?? {};

        final items = rawData.map<Map<String, dynamic>>((e) {
          final map = Map<String, dynamic>.from(e);
          return map;
        }).toList();

        return FeedResult(
          items: items,
          nextCursor: meta['next_cursor'],
          hasMore: meta['has_more'] ?? false,
        );
      }
    } catch (e) {
      debugPrint("getHomeFeed API notice: $e, falling back to local dataset");
    }

    return FeedResult(
      items: _fallbackHomeFeed,
      nextCursor: null,
      hasMore: false,
    );
  }

  /// Fetch product-only Shop Feed
  static Future<FeedResult> getShopFeed({String? cursor, int perPage = 20}) async {
    try {
      final Map<String, dynamic> query = {'per_page': perPage};
      if (cursor != null) query['cursor'] = cursor;

      final response = await _dio.get(
        '/feed/shop',
        queryParameters: query,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List rawData = response.data['data'] ?? [];
        final meta = response.data['meta'] ?? {};

        final items = rawData.map<Map<String, dynamic>>((e) {
          final map = Map<String, dynamic>.from(e);
          return map;
        }).toList();

        return FeedResult(
          items: items,
          nextCursor: meta['next_cursor'],
          hasMore: meta['has_more'] ?? false,
        );
      }
    } catch (e) {
      debugPrint("getShopFeed API notice: $e, falling back to local dataset");
    }

    return FeedResult(
      items: _fallbackShopFeed,
      nextCursor: null,
      hasMore: false,
    );
  }

  static final List<Map<String, dynamic>> _fallbackHomeFeed = [
    {
      "content_type": "material",
      "id": 5,
      "title": "Mendeteksi Komponen Panas dengan Rosin & Thermal Cam",
      "description": "Metode praktis melacak short circuit pada logic board HP",
      "material_type": "youtube_video",
      "thumbnail": "assets/images/product_1.png",
      "youtube_url": "https://www.youtube.com/watch?v=drcMv73jEGE",
    },
    {
      "content_type": "product",
      "id": 16,
      "name": "Mesin Pemisah LCD Separator Sunshine S-918F Plus",
      "description": "Rotari 360 derajat untuk pemisah layar edge dan flat.",
      "price": 890000,
      "discount_price": 890000,
      "image": "assets/images/product_1.png",
      "shopee_url": "https://shopee.co.id/brader_parts",
      "sponsor": {"name": "BraderParts Indonesia", "tier": "platinum"},
    },
    {
      "content_type": "material",
      "id": 4,
      "title": "Diagram Skematik Jalur Charger & Pengisian Cepat (PDF)",
      "description": "Panduan tracing jalur VBUS, CC1, CC2 tipe C",
      "material_type": "pdf_document",
      "thumbnail": "assets/images/product_battery.png",
      "pdf_path": "https://vbat.id/docs/skema_pmic_android.pdf",
    },
    {
      "content_type": "product",
      "id": 17,
      "name": "LCD iPhone 11 Pro Max OLED Original Quality",
      "price": 1250000,
      "discount_price": 1250000,
      "image": "assets/images/product_lcd.png",
      "shopee_url": "https://shopee.co.id/brader_parts",
      "sponsor": {"name": "BraderParts Indonesia", "tier": "platinum"},
    },
  ];

  static final List<Map<String, dynamic>> _fallbackShopFeed = [
    {
      "content_type": "product",
      "id": 16,
      "name": "Mesin Pemisah LCD Separator Sunshine S-918F Plus",
      "description": "Rotari 360 derajat untuk pemisah layar edge dan flat.",
      "price": 890000,
      "discount_price": 890000,
      "image": "assets/images/product_1.png",
      "shopee_url": "https://shopee.co.id/brader_parts",
      "sponsor": {"name": "BraderParts Indonesia", "tier": "platinum"},
    },
    {
      "content_type": "product",
      "id": 17,
      "name": "LCD iPhone 11 Pro Max OLED Original Quality",
      "price": 1250000,
      "discount_price": 1250000,
      "image": "assets/images/product_lcd.png",
      "shopee_url": "https://shopee.co.id/brader_parts",
      "sponsor": {"name": "BraderParts Indonesia", "tier": "platinum"},
    },
    {
      "content_type": "product",
      "id": 18,
      "name": "Baterai Infinix Hot 9/10/11 Play BL-58BX Original",
      "price": 145000,
      "discount_price": 145000,
      "image": "assets/images/product_battery.png",
      "shopee_url": "https://shopee.co.id/brader_parts",
      "sponsor": {"name": "TITAN Tools", "tier": "gold"},
    },
    {
      "content_type": "product",
      "id": 19,
      "name": "Obeng Set Magnetik 24 in 1 Presisi S2 Steel",
      "price": 45000,
      "discount_price": 45000,
      "image": "assets/images/product_1.png",
      "shopee_url": "https://shopee.co.id/titan_tools",
      "sponsor": {"name": "TITAN Tools", "tier": "gold"},
    },
    {
      "content_type": "product",
      "id": 20,
      "name": "Flux Amtech NC-559-ASM 10cc",
      "price": 85000,
      "discount_price": 85000,
      "image": "assets/images/product_1.png",
      "shopee_url": "https://shopee.co.id/titan_tools",
      "sponsor": {"name": "TITAN Tools", "tier": "gold"},
    },
  ];
}
