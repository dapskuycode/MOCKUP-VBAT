import 'package:go_router/go_router.dart';

// Pages Import
import 'package:vbat_ponsel/features/onboarding/presentation/pages/splash_page.dart';
import 'package:vbat_ponsel/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:vbat_ponsel/features/auth/presentation/pages/login_page.dart';
import 'package:vbat_ponsel/features/auth/presentation/pages/register_page.dart';
import 'package:vbat_ponsel/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:vbat_ponsel/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:vbat_ponsel/features/auth/presentation/pages/reset_password_page.dart';
import 'package:vbat_ponsel/features/main_navigation/presentation/pages/main_scaffold.dart';
import 'package:vbat_ponsel/features/home/presentation/pages/global_search_page.dart';
import 'package:vbat_ponsel/features/belajar/presentation/pages/course_detail_page.dart';
import 'package:vbat_ponsel/features/belajar/presentation/pages/course_syllabus_page.dart';
import 'package:vbat_ponsel/features/belajar/presentation/pages/pricelist_page.dart';
import 'package:vbat_ponsel/features/belajar/presentation/pages/hardware_solution_page.dart';
import 'package:vbat_ponsel/features/belajar/presentation/pages/video_player_page.dart';
import 'package:vbat_ponsel/features/belajar/presentation/pages/learning_dashboard_page.dart';
import 'package:vbat_ponsel/features/belajar/presentation/pages/certificate_page.dart';
import 'package:vbat_ponsel/features/belajar/presentation/pages/quiz_page.dart';
import 'package:vbat_ponsel/features/forum/presentation/pages/forum_page.dart';
import 'package:vbat_ponsel/features/forum/presentation/pages/forum_detail_page.dart';
import 'package:vbat_ponsel/features/forum/presentation/pages/create_thread_page.dart';
import 'package:vbat_ponsel/features/notifikasi/presentation/pages/notification_page.dart';
import 'package:vbat_ponsel/features/shop/presentation/pages/brand_detail_page.dart';
import 'package:vbat_ponsel/features/shop/presentation/pages/product_detail_page.dart';
import 'package:vbat_ponsel/features/shop/presentation/pages/wishlist_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/settings_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/subscription_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/learning_history_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/transaction_history_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/help_center_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/about_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/language_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/theme_settings_page.dart';
import 'package:vbat_ponsel/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:vbat_ponsel/features/forum/presentation/pages/forum_search_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) => const OtpVerificationPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainScaffold(),
      ),
      GoRoute(
        path: '/global-search',
        builder: (context, state) => const GlobalSearchPage(),
      ),
      GoRoute(
        path: '/pricelist',
        builder: (context, state) => const PricelistPage(),
      ),
      GoRoute(
        path: '/course-syllabus',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CourseSyllabusPage(category: extra?['category'] ?? 'Course');
        },
      ),
      GoRoute(
        path: '/hardware-solution',
        builder: (context, state) => const HardwareSolutionPage(),
      ),
      GoRoute(
        path: '/course-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CourseDetailPage(
            module: extra?['module'] ?? 'Modul',
            category: extra?['category'] ?? 'Category',
          );
        },
      ),
      GoRoute(
        path: '/video-player',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final title = extra?['title'] ?? extra?['name'] ?? "Mastering iPhone 13 Screen Repair";
          return VideoPlayerPage(title: title.toString());
        },
      ),
      GoRoute(
        path: '/learning-dashboard',
        builder: (context, state) => const LearningDashboardPage(),
      ),
      GoRoute(
        path: '/certificate',
        builder: (context, state) => const CertificatePage(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizPage(),
      ),
      GoRoute(
        path: '/forum',
        builder: (context, state) => const ForumPage(),
      ),
      GoRoute(
        path: '/forum-detail',
        builder: (context, state) => const ForumDetailPage(),
      ),
      GoRoute(
        path: '/create-thread',
        builder: (context, state) => const CreateThreadPage(),
      ),
      GoRoute(
        path: '/notification',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/brand-detail/:brandName',
        builder: (context, state) {
          final brandName = state.pathParameters['brandName'] ?? 'Detail Brand';
          return BrandDetailPage(brandName: brandName);
        },
      ),
      GoRoute(
        path: '/product-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProductDetailPage(productData: extra);
        },
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionPage(),
      ),
      GoRoute(
        path: '/learning-dashboard',
        builder: (context, state) => const LearningDashboardPage(),
      ),
      GoRoute(
        path: '/learning-history',
        builder: (context, state) => const LearningHistoryPage(),
      ),
      GoRoute(
        path: '/certificate',
        builder: (context, state) => const CertificatePage(),
      ),
      GoRoute(
        path: '/transaction-history',
        builder: (context, state) => const TransactionHistoryPage(),
      ),
      GoRoute(
        path: '/help-center',
        builder: (context, state) => const HelpCenterPage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguagePage(),
      ),
      GoRoute(
        path: '/theme-settings',
        builder: (context, state) => const ThemeSettingsPage(),
      ),
      GoRoute(
        path: '/forum-search',
        builder: (context, state) => const ForumSearchPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
    ],
  );
}
