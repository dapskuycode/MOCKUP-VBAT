import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WishlistHelper {
  // Simpan data wishlist sementara di memory
  static final List<Map<String, String>> items = [
    {
      "name": "Baterai Infinix Hot 9/10/11 Play BL-58BX Original",
      "price": "Rp145.000",
      "image": "assets/images/product_battery.png",
      "link":
          "https://shopee.co.id/Braderparts-Baterai-Battery-Batre-BL-58BX-for-Infinix-Hot-9-Play-Hot-10-Play-Hot-10S-Hot-11-Play-Hot-12-Play-i.57356590.22913463095?extraParams=%7B%22display_model_id%22%3A350188294975%2C%22model_selection_logic%22%3A3%7D&sp_atk=f8d0ca69-2d93-4324-b982-5cd7d983550e&xptdk=f8d0ca69-2d93-4324-b982-5cd7d983550e",
    },
    {
      "name": "LCD iPhone 11 Pro Max OLED Original Quality",
      "price": "Rp1.250.000",
      "image": "assets/images/product_lcd.png",
      "link":
          "https://shopee.co.id/brader_parts?categoryId=100013&entryPoint=ShopByPDP&itemId=22913463095",
    },
  ];

  static Widget buildThumbnail(String? image, String name, {double size = 60}) {
    final raw = (image ?? "").trim();
    final n = name.toLowerCase();

    String fallbackAsset = "assets/images/product_1.png";
    if (n.contains("lcd") || n.contains("layar") || n.contains("screen") || n.contains("oled")) {
      fallbackAsset = "assets/images/product_lcd.png";
    } else if (n.contains("baterai") || n.contains("battery") || n.contains("batre") || n.contains("bl-58bx")) {
      fallbackAsset = "assets/images/product_battery.png";
    }

    if (raw.startsWith("http://") || raw.startsWith("https://")) {
      return Image.network(
        raw,
        width: size,
        height: size,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Image.asset(
          fallbackAsset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.inventory_2_outlined,
            color: Colors.grey,
            size: 24,
          ),
        ),
      );
    }

    String assetPath = raw;
    if (assetPath.isEmpty ||
        assetPath.contains("brand_apple") ||
        assetPath.contains("brand_infinix")) {
      assetPath = fallbackAsset;
    }

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        fallbackAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.inventory_2_outlined,
          color: Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  static bool isWishlisted(String productName) {
    return items.any((element) => element["name"] == productName);
  }

  static bool toggleWishlist(BuildContext context, Map<String, String> item) {
    final index = items.indexWhere((element) => element["name"] == item["name"]);
    final isAdded = index == -1;
    if (isAdded) {
      items.add(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${item["name"]} ditambahkan ke Wishlist ❤️"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1B4F9B),
        ),
      );
    } else {
      items.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${item["name"]} dihapus dari Wishlist"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey.shade800,
        ),
      );
    }
    return isAdded;
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                          Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Wishlist Saya",
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
                        "${items.length} Barang",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border_rounded,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Belum ada barang di wishlist",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: Center(
                                          child: buildThumbnail(
                                            item["image"],
                                            item["name"] ?? "",
                                            size: 52,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["name"]!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF001944),
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item["price"]!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFFD761A),
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          showMarketplaceSheet(
                                            context,
                                            item["name"]!,
                                            item["link"]!,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1B4F9B,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          "Beli",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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

  static Future<void> showMarketplaceSheet(
    BuildContext context,
    String productName,
    String link,
  ) async {
    final bool isTokopedia = link.toLowerCase().contains("tokopedia");
    final String platform = isTokopedia ? "Tokopedia" : "Shopee";
    final Color color = isTokopedia ? const Color(0xFF03AC0E) : const Color(0xFFEE4D2D);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Membuka $platform...",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {}
  }

  static void openProductMarketplace(
    BuildContext context, {
    required String productName,
    String? shopeeUrl,
    String? tokopediaUrl,
  }) {
    final hasShopee = shopeeUrl != null && shopeeUrl.trim().isNotEmpty;
    final hasTokopedia = tokopediaUrl != null && tokopediaUrl.trim().isNotEmpty;

    if (hasShopee && hasTokopedia) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Pilih Toko Pembelian",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001944),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  productName,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF737782)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Tombol Shopee
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    showMarketplaceSheet(context, productName, shopeeUrl);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEE4D2D).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEE4D2D).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEE4D2D),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Beli di Shopee",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFFEE4D2D),
                                ),
                              ),
                              Text(
                                "Toko resmi mitra terverifikasi",
                                style: TextStyle(fontSize: 11, color: Color(0xFF737782)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFFEE4D2D)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Tombol Tokopedia
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    showMarketplaceSheet(context, productName, tokopediaUrl);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF03AC0E).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF03AC0E).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF03AC0E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Beli di Tokopedia",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF03AC0E),
                                ),
                              ),
                              Text(
                                "Toko resmi mitra terverifikasi",
                                style: TextStyle(fontSize: 11, color: Color(0xFF737782)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF03AC0E)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (hasTokopedia) {
      showMarketplaceSheet(context, productName, tokopediaUrl);
    } else {
      showMarketplaceSheet(context, productName, shopeeUrl ?? 'https://shopee.co.id');
    }
  }
}
