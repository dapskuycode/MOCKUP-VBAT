import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/utils/camera_picker_helper.dart';

class HomeHeaderSliver extends StatelessWidget {
  const HomeHeaderSliver({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryContainer = Color(0xFF1B4F9B); // Warna biru khas VBat

    return SliverAppBar(
      backgroundColor: primaryContainer,
      pinned: true,
      floating: true,
      elevation: 0,
      expandedHeight: 70,
      toolbarHeight: 70,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(color: primaryContainer),
      ),
      title: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/global-search'),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: primaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              enabled: false,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: "Cari kursus atau sparepart...",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 13, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => CameraPickerHelper.show(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Notification Icon
          IconButton(
            onPressed: () => context.push('/notification'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          // Wishlist Icon (Replacing Chat/Cart)
          IconButton(
            onPressed: () => context.push('/wishlist'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
