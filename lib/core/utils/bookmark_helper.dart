import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper untuk mengelola bookmark materi belajar teknisi (terpisah dari Wishlist sparepart toko)
/// Menyimpan data secara persisten ke SharedPreferences ('learning_bookmarks')
class BookmarkHelper {
  static const String _storageKey = 'learning_bookmarks';
  static final List<Map<String, dynamic>> _items = [];
  static bool _isInitialized = false;

  static List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  /// Inisialisasi awal saat aplikasi start
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        _items.clear();
        _items.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
      } else {
        // Default sample bookmark materi
        _items.clear();
        _items.add({
          "id": "mat-1",
          "title": "Pengenalan Komponen & Skematik Dasar",
          "category": "Kelas Android",
          "module": "Modul 1: Dasar Elektronika Ponsel",
          "type": "video",
          "duration": "14:20",
          "savedAt": DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        });
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('[BookmarkHelper] Error initializing: $e');
    }
  }

  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_items));
    } catch (e) {
      debugPrint('[BookmarkHelper] Error saving bookmarks: $e');
    }
  }

  static bool isBookmarked(String id) {
    return _items.any((element) => element["id"]?.toString() == id);
  }

  static bool toggleBookmark(BuildContext context, Map<String, dynamic> item) {
    final itemId = item["id"]?.toString() ?? item["title"];
    final index = _items.indexWhere((element) => (element["id"]?.toString() ?? element["title"]) == itemId);
    final isAdded = index == -1;

    if (isAdded) {
      _items.add({
        ...item,
        "id": itemId,
        "savedAt": DateTime.now().toIso8601String(),
      });
      _save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.bookmark_added_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item["title"] ?? "Materi"} disimpan ke Bookmark Belajar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1B4F9B),
        ),
      );
    } else {
      _items.removeAt(index);
      _save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item["title"] ?? "Materi"} dihapus dari Bookmark Belajar'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey.shade800,
        ),
      );
    }
    return isAdded;
  }

  /// Menampilkan modal daftar bookmark materi belajar
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              maxChildSize: 0.9,
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
                              Icon(
                                Icons.bookmark_rounded,
                                color: Color(0xFF1B4F9B),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Bookmark Materi Belajar",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001944),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${_items.length} Materi",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _items.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bookmark_border_rounded,
                                      size: 64,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Belum ada materi pelajaran yang di-bookmark",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Tekan ikon bookmark pada silabus untuk menyimpan materi penting",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  final isVideo = item["type"] == 'video' || item["videoUrl"] != null;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      leading: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1B4F9B).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isVideo ? Icons.play_circle_fill_rounded : Icons.menu_book_rounded,
                                          color: const Color(0xFF1B4F9B),
                                        ),
                                      ),
                                      title: Text(
                                        item["title"] ?? "Materi Pelajaran",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            item["category"] ?? item["module"] ?? "LMS VBAT",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (item["duration"] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                "Durasi: ${item["duration"]}",
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.bookmark_remove_rounded, color: Colors.redAccent),
                                        tooltip: "Hapus bookmark",
                                        onPressed: () {
                                          setSheetState(() {
                                            _items.removeAt(index);
                                            _save();
                                          });
                                        },
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        // Navigate to course detail
                                        context.push(
                                          '/course-detail',
                                          extra: {
                                            'category': item["category"] ?? 'Kelas Teknisi',
                                            'module': item["module"] ?? 'Materi Belajar',
                                          },
                                        );
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
      },
    );
  }
}
