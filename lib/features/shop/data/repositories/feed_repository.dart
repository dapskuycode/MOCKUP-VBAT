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
      debugPrint("getHomeFeed gagal: $e");
    }

    // CW-09: tidak ada data contoh. Bila server tidak dapat dihubungi, feed
    // dikembalikan kosong supaya aplikasi tidak menayangkan produk atau mitra
    // yang sebenarnya tidak ada.
    return const FeedResult(
      items: [],
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
      debugPrint("getShopFeed gagal: $e");
    }

    // CW-09: tidak ada data contoh untuk Shop juga.
    return const FeedResult(
      items: [],
      nextCursor: null,
      hasMore: false,
    );
  }

  // CW-09: daftar data contoh dihapus. Feed hanya berisi data dari server.

}
