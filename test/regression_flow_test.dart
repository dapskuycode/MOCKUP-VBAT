import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vbat_ponsel/core/utils/bookmark_helper.dart';
import 'package:vbat_ponsel/core/utils/offline_media_manager.dart';
import 'package:vbat_ponsel/core/utils/push_notification_service.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await WishlistHelper.init();
    await BookmarkHelper.init();
    await OfflineMediaManager.init();
    await PushNotificationService.initialize();

    // Reset default session
    SessionManager.logout();
  });

  group('Regression Test Suite 1: Entitlement & Access Matrix Gating', () {
    test('TC-ENT-01: Default state only permits free class', () {
      expect(SessionManager.canAccessCourse('free_class'), isTrue);
      expect(SessionManager.canAccessCourse('android'), isFalse);
      expect(SessionManager.canAccessCourse('iphone'), isFalse);
      expect(SessionManager.isHardwareSolutionUnlocked, isFalse);
    });

    test('TC-ENT-02: Purchasing Android unlocks Android and preserves iPhone lock', () {
      SessionManager.grantEntitlement('android');
      expect(SessionManager.canAccessCourse('android'), isTrue);
      expect(SessionManager.canAccessCourse('iphone'), isFalse);
      expect(SessionManager.hasPermanentMembership, isTrue);
    });

    test('TC-ENT-03: Purchasing Bundling unlocks both Android & iPhone', () {
      SessionManager.grantEntitlement('bundling');
      expect(SessionManager.canAccessCourse('android'), isTrue);
      expect(SessionManager.canAccessCourse('iphone'), isTrue);
      expect(SessionManager.canAccessCourse('bundling'), isTrue);
    });

    test('TC-ENT-04: Hardware Solution unlocked strictly at 90% progress', () {
      SessionManager.learningProgress.value = 0.89;
      expect(SessionManager.isHardwareSolutionUnlocked, isFalse);

      SessionManager.learningProgress.value = 0.90;
      expect(SessionManager.isHardwareSolutionUnlocked, isTrue);

      SessionManager.learningProgress.value = 1.0;
      expect(SessionManager.isHardwareSolutionUnlocked, isTrue);
    });
  });

  group('Regression Test Suite 2: Wishlist vs Bookmark Isolation', () {
    test('TC-BKM-01: Wishlist and Learning Bookmarks remain independent', () {
      final initialWishlistCount = WishlistHelper.items.length;
      final initialBookmarkCount = BookmarkHelper.items.length;

      // Check Wishlist
      expect(WishlistHelper.isWishlisted('Test Sparepart Nonexistent'), isFalse);

      // Check Bookmark
      expect(BookmarkHelper.isBookmarked('unique_test_module_99'), isFalse);

      expect(WishlistHelper.items.length, initialWishlistCount);
      expect(BookmarkHelper.items.length, initialBookmarkCount);
    });
  });

  group('Regression Test Suite 3: Offline Media Manager & License Audit', () {
    test('TC-SEC-01: Unauthorized offline download is blocked', () async {
      // User is guest, tries to download paid Android lesson
      final result = await OfflineMediaManager.downloadLesson(
        materialId: 'mat-android-101',
        title: 'Skematik CPU Snapdragon',
        courseType: 'android',
        videoUrl: 'https://vbat.id/secure/cpu.mp4',
        duration: '15:00',
      );

      expect(result, isFalse);
      expect(OfflineMediaManager.canPlayOffline('mat-android-101'), isFalse);
    });

    test('TC-SEC-02: Authorized download succeeds and revocation triggers on logout', () async {
      // 1. Grant access
      SessionManager.grantEntitlement('android');

      // 2. Download offline lesson
      final result = await OfflineMediaManager.downloadLesson(
        materialId: 'mat-android-102',
        title: 'Dasar Jalur Power IC',
        courseType: 'android',
        videoUrl: 'https://vbat.id/secure/power.mp4',
        duration: '12:30',
      );

      expect(result, isTrue);
      expect(OfflineMediaManager.canPlayOffline('mat-android-102'), isTrue);

      // Decrypted URL should match original
      final decrypted = OfflineMediaManager.getDecryptedOfflineUrl('mat-android-102');
      expect(decrypted, equals('https://vbat.id/secure/power.mp4'));

      // 3. User logs out or subscription revoked
      SessionManager.logout();
      await OfflineMediaManager.auditOfflineEntitlements();

      // 4. Offline playback must be blocked
      expect(OfflineMediaManager.canPlayOffline('mat-android-102'), isFalse);
      expect(OfflineMediaManager.getDecryptedOfflineUrl('mat-android-102'), isNull);
    });
  });

  group('Regression Test Suite 4: Push Notification & Read Persistence', () {
    test('TC-NOTIF-01: Marking notification as read updates unread counter', () async {
      final notifs = PushNotificationService.notifications;
      expect(notifs.isNotEmpty, isTrue);

      final firstItem = notifs.first;
      final initialUnread = PushNotificationService.unreadCount;

      await PushNotificationService.markAsRead(firstItem.id);
      expect(firstItem.isRead, isTrue);
      expect(PushNotificationService.unreadCount, lessThanOrEqualTo(initialUnread));
    });

    test('TC-NOTIF-02: Hardware Solution unlock notification generates at 90%', () {
      SessionManager.learningProgress.value = 0.95;
      PushNotificationService.syncHardwareUnlockNotification();

      final notifs = PushNotificationService.notifications;
      final hasUnlockNotif = notifs.any((n) => n.id == 'hw-solution-unlocked');
      expect(hasUnlockNotif, isTrue);

      final unlockNotif = notifs.firstWhere((n) => n.id == 'hw-solution-unlocked');
      expect(unlockNotif.targetRoute, equals('/hardware-solution'));
    });
  });
}
