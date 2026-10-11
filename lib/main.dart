import 'package:flutter/material.dart';
import 'package:vbat_ponsel/core/config/app_config.dart';
import 'package:vbat_ponsel/core/routes/app_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/bookmark_helper.dart';
import 'package:vbat_ponsel/core/utils/offline_media_manager.dart';
import 'package:vbat_ponsel/core/utils/push_notification_service.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/utils/sponsor_tier_store.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();
  await SessionManager.initSession();
  await ThemeManager.init();
  await WishlistHelper.init();
  await BookmarkHelper.init();
  await OfflineMediaManager.init();
  await PushNotificationService.initialize();
  // Ambil data tier (nama, warna, ikon) dari server. Tidak menunggu hasilnya
  // supaya aplikasi tetap cepat terbuka saat server lambat atau tidak tersedia.
  SponsorTierStore.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeModeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp.router(
          title: 'VBat Ponsel',
          debugShowCheckedModeBanner: false,
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          themeMode: currentThemeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
