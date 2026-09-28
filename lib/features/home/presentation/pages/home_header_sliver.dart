import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/camera_picker_helper.dart';

class HomeHeaderSliver extends StatelessWidget {
  const HomeHeaderSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDark(context);
    final Color primaryContainer = isDark ? const Color(0xFF151B26) : const Color(0xFF1B4F9B);

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
                color: isDark ? const Color(0xFF222B38) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isDark ? Border.all(color: ThemeManager.darkBorder) : null,
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
                          Icon(
                            Icons.search_rounded,
                            color: isDark ? const Color(0xFF60A5FA) : primaryContainer,
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
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => CameraPickerHelper.show(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
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
