import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/features/home/presentation/pages/home_page.dart';
import 'package:vbat_ponsel/features/shop/presentation/pages/shop_page.dart';
import 'package:vbat_ponsel/features/forum/presentation/pages/forum_page.dart';
import 'package:vbat_ponsel/features/belajar/presentation/pages/learning_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/profile_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/guest_profile_page.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

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
  }

  @override
  void dispose() {
    SessionManager.currentTabIndex.removeListener(_onTabChangedExternally);
    super.dispose();
  }

  void _onTabChangedExternally() {
    if (mounted) {
      setState(() {
        _currentIndex = SessionManager.currentTabIndex.value;
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
        return isLoggedIn ? const ProfilePage() : const GuestProfilePage();
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 84,
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background dengan lekukan kustom
            CustomPaint(
              size: Size(screenWidth, 84),
              painter: BNBCustomPainter(primaryColor: _primaryBlue),
            ),
            // Tombol Ikon Navigasi (kiri & kanan)
            Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            ),
                            _buildNavItem(
                              1,
                              Icons.storefront_rounded,
                              Icons.storefront_outlined,
                              "Shop",
                            ),
                          ],
                        ),
                      ),
                      // Spacer untuk tab tengah Belajar
                      const SizedBox(width: 80),
                      // Kanan: Forum & Akun
                      SizedBox(
                        width: (screenWidth - 80) / 2 - 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(
                              3,
                              Icons.forum_rounded,
                              Icons.forum_outlined,
                              "Forum",
                            ),
                            _buildNavItem(
                              4,
                              Icons.person_rounded,
                              Icons.person_outline_rounded,
                              "Akun",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Tombol Belajar tengah yang melayang
            Positioned(
              top: -24,
              left: screenWidth / 2 - 32,
              child: _buildCenterBelajarItem(),
            ),
            // Label Belajar di bawah, sejajar dengan label nav lain
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: SafeArea(
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
                        fontWeight: _currentIndex == 2 ? FontWeight.w700 : FontWeight.w500,
                        color: _currentIndex == 2 ? _primaryBlue : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterBelajarItem() {
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
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [const Color(0xFF1B4F9B), const Color(0xFF3B7ED9)]
                : [const Color(0xFFEFF6FF), Colors.white],
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
            color: isSelected ? Colors.white : Colors.grey.shade300,
            width: 3.5,
          ),
        ),
        child: Icon(
          Icons.school_rounded,
          color: isSelected ? Colors.white : _primaryBlue,
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
  ) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if ((index == 3) && !SessionManager.isLoggedIn.value) {
          // Forum memerlukan login
          context.push('/login');
        } else {
          SessionManager.currentTabIndex.value = index;
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? _primaryBlue.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? _primaryBlue : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _primaryBlue : Colors.grey.shade500,
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

  BNBCustomPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    Path path = Path();
    double radius = 42.0; // Radius notch lekukan tengah
    double centerX = size.width / 2;

    path.moveTo(0, 16);
    path.quadraticBezierTo(0, 0, 16, 0);

    // Sisi Kiri
    path.lineTo(centerX - radius - 12, 0);

    // Lekukan Kurva Notch
    path.quadraticBezierTo(
      centerX - radius,
      0,
      centerX - radius,
      8,
    );
    path.arcToPoint(
      Offset(centerX + radius, 8),
      radius: const Radius.circular(42),
      clockwise: false,
    );
    path.quadraticBezierTo(
      centerX + radius,
      0,
      centerX + radius + 12,
      0,
    );

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
