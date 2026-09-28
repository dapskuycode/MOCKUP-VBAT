import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/features/home/presentation/pages/home_page.dart';
import 'package:vbat_ponsel/features/shop/presentation/pages/shop_page.dart';
import 'package:vbat_ponsel/features/forum/presentation/pages/forum_page.dart';
import 'package:vbat_ponsel/features/belajar/presentation/pages/learning_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/profile_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/guest_profile_page.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/widgets/pulsing_signal_dot.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final Color _primaryBlue = const Color(0xFF1B4F9B);

  @override
  void initState() {
    super.initState();
    _currentIndex = SessionManager.currentTabIndex.value;
    SessionManager.currentTabIndex.addListener(_onTabChangedExternally);
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    SessionManager.currentTabIndex.removeListener(_onTabChangedExternally);
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _onTabChangedExternally() {
    if (mounted) {
      final target = SessionManager.currentTabIndex.value;
      if (target == 4 && !SessionManager.isLoggedIn.value) {
        context.push('/login');
        return;
      }
      setState(() {
        _currentIndex = target;
      });
    }
  }

  // Urutan: Beranda(0), Shop(1), Belajar(2), Forum(3), Akun(4)
  List<Widget> get _pages => [
    const HomePage(),
    const ShopPage(),
    const LearningPage(),
    const ForumPage(),
    ValueListenableBuilder<bool>(
      valueListenable: SessionManager.isLoggedIn,
      builder: (context, isLoggedIn, child) {
        if (!isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!SessionManager.isLoggedIn.value && mounted) {
              context.push('/login');
            }
          });
          return const GuestProfilePage();
        }
        return const ProfilePage();
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Ambil safe area bawah (home indicator iPhone) secara eksplisit
    final double bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    // Tinggi konten navbar (background + notch)
    const double navContentHeight = 72.0;
    final double totalNavHeight = navContentHeight + bottomPadding;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeModeNotifier,
      builder: (context, currentMode, _) {
        final bool isDark = ThemeManager.isDark(context);
        final Color navBgColor = isDark ? const Color(0xFF161F2E) : Colors.white;

        return Scaffold(
          backgroundColor: isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA),
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: _pages[_currentIndex],
          bottomNavigationBar: SizedBox(
            height: totalNavHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background dengan lekukan kustom (hanya area navbar, tidak termasuk safe area)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: CustomPaint(
                    size: Size(screenWidth, navContentHeight),
                    painter: BNBCustomPainter(
                      primaryColor: _primaryBlue,
                      backgroundColor: navBgColor,
                    ),
                  ),
                ),
                // Area safe (bawah) — menutup home indicator
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: bottomPadding,
                  child: ColoredBox(color: navBgColor),
                ),
            // Tombol Ikon Navigasi (kiri & kanan)
            Positioned(
              left: 12,
              right: 12,
              top: 8,
              height: navContentHeight - 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kiri: Beranda & Shop
                  SizedBox(
                    width: (screenWidth - 80) / 2 - 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          0,
                          Icons.home_filled,
                          Icons.home_outlined,
                          "Beranda",
                          isDark,
                        ),
                        _buildNavItem(
                          1,
                          Icons.storefront_rounded,
                          Icons.storefront_outlined,
                          "Shop",
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  // Spacer untuk tab tengah Belajar
                  const SizedBox(width: 80),
                  // Kanan: Informasi & Akun
                  SizedBox(
                    width: (screenWidth - 80) / 2 - 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          3,
                          Icons.info_rounded,
                          Icons.info_outline_rounded,
                          "Informasi",
                          isDark,
                        ),
                        _buildNavItem(
                          4,
                          Icons.person_rounded,
                          Icons.person_outline_rounded,
                          "Akun",
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tombol Belajar tengah yang melayang (di atas notch)
            Positioned(
              top: -28,
              left: screenWidth / 2 - 30,
              child: _buildCenterBelajarItem(isDark),
            ),
            // Label Belajar di bawah tombol floating
            Positioned(
              top: navContentHeight - 18,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  if (!SessionManager.isLoggedIn.value) {
                    context.push('/login');
                  } else {
                    SessionManager.currentTabIndex.value = 2;
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Text(
                    "Belajar",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: _currentIndex == 2
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _currentIndex == 2
                          ? (isDark ? const Color(0xFF60A5FA) : _primaryBlue)
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildCenterBelajarItem(bool isDark) {
    bool isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () {
        if (!SessionManager.isLoggedIn.value) {
          context.push('/login');
        } else {
          SessionManager.currentTabIndex.value = 2;
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [const Color(0xFF1B4F9B), const Color(0xFF3B7ED9)]
                : (isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFEFF6FF), Colors.white]),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _primaryBlue.withValues(alpha: isSelected ? 0.4 : 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF60A5FA) : Colors.white)
                : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
            width: 3.5,
          ),
        ),
        child: Icon(
          Icons.school_rounded,
          color: isSelected
              ? Colors.white
              : (isDark ? const Color(0xFF60A5FA) : _primaryBlue),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    bool isDark,
  ) {
    bool isSelected = _currentIndex == index;
    final Color activeColor = isDark ? const Color(0xFF60A5FA) : _primaryBlue;
    final Color inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return GestureDetector(
      onTap: () {
        if ((index == 4 || index == 3) && !SessionManager.isLoggedIn.value) {
          // Tab Akun (4) dan Forum (3) berkaitan dengan identitas/anggota -> langsung ke /login
          context.push('/login');
        } else {
          SessionManager.currentTabIndex.value = index;
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 66,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.2 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 24,
                ),
                // Notif titik kuning memancar seperti sinyal jika data profile bertanda * belum lengkap
                if (index == 4)
                  ValueListenableBuilder<bool>(
                    valueListenable: SessionManager.isProfileCompleteNotifier,
                    builder: (context, isComplete, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: SessionManager.isLoggedIn,
                        builder: (context, isLoggedIn, _) {
                          if (isLoggedIn && !isComplete) {
                            return const Positioned(
                              top: -4,
                              right: -4,
                              child: PulsingSignalDot(size: 8.0),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;

  BNBCustomPainter({
    required this.primaryColor,
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    Path path = Path();
    double radius = 42.0; // Radius notch lekukan tengah
    double centerX = size.width / 2;

    path.moveTo(0, 16);
    path.quadraticBezierTo(0, 0, 16, 0);

    // Sisi Kiri
    path.lineTo(centerX - radius - 12, 0);

    // Lekukan Kurva Notch
    path.quadraticBezierTo(centerX - radius, 0, centerX - radius, 8);
    path.arcToPoint(
      Offset(centerX + radius, 8),
      radius: const Radius.circular(42),
      clockwise: false,
    );
    path.quadraticBezierTo(centerX + radius, 0, centerX + radius + 12, 0);

    // Sisi Kanan
    path.lineTo(size.width - 16, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 16);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BNBCustomPainter oldDelegate) => true;
}
