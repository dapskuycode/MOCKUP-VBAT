import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vbat_ponsel/core/config/app_config.dart';
import 'package:vbat_ponsel/core/utils/wishlist_helper.dart';

class SessionManager {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isPremium = ValueNotifier<bool>(true);
  static final ValueNotifier<int> currentTabIndex = ValueNotifier<int>(0);

  // Storage Keys for persistent auth
  static const String _tokenKey = 'vbat_auth_token';
  static const String _userEmailKey = 'vbat_user_email';
  static const String _userNameKey = 'vbat_user_name';
  static const String _userIdKey = 'vbat_user_id';
  static const String _userRoleKey = 'vbat_user_role';

  // In-memory active session tokens & details
  static String? currentToken;
  static final ValueNotifier<String> userEmailNotifier = ValueNotifier<String>("");
  static String get userEmail => userEmailNotifier.value;
  static set userEmail(String? val) {
    userEmailNotifier.value = val ?? "";
  }
  static int? userId;
  static String? userRole;

  // Demographic & Profile state for admin analytics
  static final ValueNotifier<String> userNameNotifier = ValueNotifier<String>("Andi Teknisi");
  static String get userName => userNameNotifier.value;
  static set userName(String? val) {
    if (val != null && val.isNotEmpty) {
      userNameNotifier.value = val;
    }
  }

  static DateTime? birthDate;
  static String? gender;
  static String? phone;
  static String? whatsapp;
  static String? address;
  static String? province;
  static String? city;
  static String? district;
  static String? village;
  static String? instagram;
  static String? facebook;
  static String? tiktok;
  static String? youtube;

  static final ValueNotifier<bool> isProfileCompleteNotifier = ValueNotifier<bool>(false);

  static bool get isProfileComplete {
    final hasName = userName.trim().isNotEmpty;
    final hasBirth = birthDate != null;
    final hasGender = gender != null && gender!.trim().isNotEmpty;
    final hasPhone = phone != null && phone!.trim().isNotEmpty;
    final hasWa = whatsapp != null && whatsapp!.trim().isNotEmpty;
    final hasAddress = address != null && address!.trim().isNotEmpty;
    final hasProv = province != null && province!.trim().isNotEmpty;
    final hasCity = city != null && city!.trim().isNotEmpty;

    return hasName &&
        hasBirth &&
        hasGender &&
        hasPhone &&
        hasWa &&
        hasAddress &&
        hasProv &&
        hasCity;
  }

  static void checkAndNotifyProfileComplete() {
    isProfileCompleteNotifier.value = isProfileComplete;
  }

  static bool get profileCompleted => isProfileComplete;
  static set profileCompleted(bool val) {
    checkAndNotifyProfileComplete();
  }

  static int? get userAge {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  static String get apiBaseUrl => AppConfig.apiBaseUrl;

  // Entitlements: 'free_class', 'android', 'iphone', 'bundling'
  static final ValueNotifier<Set<String>> activeEntitlements =
      ValueNotifier<Set<String>>({'free_class'});

  // Progress belajar keseluruhan (0.0 s/d 1.0) untuk unlock Hardware Solution (90%)
  static final ValueNotifier<double> learningProgress = ValueNotifier<double>(0.0);

  // Membership & KTA state (Permanent upon purchasing Android/iPhone/Bundling)
  static final ValueNotifier<String> membershipNumberNotifier =
      ValueNotifier<String>('');
  static String get membershipNumber => membershipNumberNotifier.value;
  static bool get hasPermanentMembership => activeEntitlements.value.any(
      (e) => ['android', 'iphone', 'bundling'].contains(e.toLowerCase()));

  // Gamification: Streak & Badges
  static final ValueNotifier<int> streakDaysNotifier = ValueNotifier<int>(5);
  static final ValueNotifier<Set<String>> unlockedBadgeCodes =
      ValueNotifier<Set<String>>({'first_login', 'lesson_complete', 'streak_7'});

  /// Inisialisasi sesi saat aplikasi startup (dari SharedPreferences / localStorage di Chrome)
  static Future<void> initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        currentToken = token;
        userEmail = prefs.getString(_userEmailKey);
        final savedName = prefs.getString(_userNameKey);
        if (savedName != null && savedName.isNotEmpty) {
          userName = savedName;
        }
        userId = prefs.getInt(_userIdKey);
        userRole = prefs.getString(_userRoleKey);
        isLoggedIn.value = true;
        debugPrint("[SessionManager] Sesi aktif ditemukan! User: $userName, Token tersimpan.");
        await fetchProfileFromBackend();
      } else {
        isLoggedIn.value = false;
        debugPrint("[SessionManager] Belum ada sesi login yang tersimpan.");
      }
    } catch (e) {
      debugPrint("[SessionManager] Error reading saved session: $e");
    }
  }

  /// Simpan sesi secara permanen ke SharedPreferences / Chrome localStorage
  static Future<void> saveSession({
    required String token,
    required String name,
    required String email,
    int? id,
    String? role,
  }) async {
    currentToken = token;
    userEmail = email;
    userId = id;
    userRole = role;
    userName = name;
    isLoggedIn.value = true;

    // Reset fields to ensure fresh load from backend
    birthDate = null;
    gender = null;
    phone = null;
    whatsapp = null;
    address = null;
    province = null;
    city = null;
    district = null;
    village = null;
    instagram = null;
    facebook = null;
    tiktok = null;
    youtube = null;
    checkAndNotifyProfileComplete();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_userEmailKey, email);
      if (id != null) await prefs.setInt(_userIdKey, id);
      if (role != null) await prefs.setString(_userRoleKey, role);
      debugPrint("[SessionManager] Token dan profil berhasil disimpan ke storage.");
      await WishlistHelper.loadForCurrentUser();
      await fetchProfileFromBackend();
    } catch (e) {
      debugPrint("[SessionManager] Error saving session to storage: $e");
    }
  }

  /// Login resmi menembak REST API Laravel (POST /api/v1/auth/login)
  static Future<Map<String, dynamic>> loginWithApi(String email, String password) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final response = await dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'] as String;
        final user = data['user'] as Map<String, dynamic>;
        final String name = user['name'] ?? email.split('@').first;
        final int? id = user['id'];
        final String? role = user['role'];

        await saveSession(
          token: token,
          name: name,
          email: email,
          id: id,
          role: role,
        );

        return {
          'success': true,
          'name': name,
          'token': token,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Login gagal',
      };
    } on DioException catch (e) {
      String errorMsg = 'Gagal terhubung ke server backend';
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          errorMsg = data['message'];
        } else if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          errorMsg = errors.values.first is List
              ? errors.values.first.first
              : errors.values.first.toString();
        }
      }
      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Registrasi akun baru menembak REST API Laravel (POST /api/v1/auth/register)
  static Future<Map<String, dynamic>> registerWithApi({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final response = await dio.post('/auth/register', data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'] as String;
        final user = data['user'] as Map<String, dynamic>;
        final String registeredName = user['name'] ?? name;
        final int? id = user['id'];
        final String? role = user['role'];

        await saveSession(
          token: token,
          name: registeredName,
          email: email,
          id: id,
          role: role,
        );

        return {
          'success': true,
          'name': registeredName,
          'token': token,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Registrasi gagal',
      };
    } on DioException catch (e) {
      String errorMsg = 'Gagal terhubung ke server backend';
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          errorMsg = data['message'];
        } else if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          errorMsg = errors.values.first is List
              ? errors.values.first.first
              : errors.values.first.toString();
        }
      }
      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  static bool canAccessCourse(String courseType) {
    final type = courseType.toLowerCase().trim();
    if (type == 'free_class' || type.contains('free')) return true;
    final entitlements = activeEntitlements.value;
    if (entitlements.contains('bundling')) return true;
    if (type.contains('android') && entitlements.contains('android')) return true;
    if (type.contains('iphone') && entitlements.contains('iphone')) return true;
    return false;
  }

  static bool get isHardwareSolutionUnlocked => learningProgress.value >= 0.90;

  static void grantEntitlement(String type) {
    final updated = Set<String>.from(activeEntitlements.value)..add(type.toLowerCase());
    activeEntitlements.value = updated;
    if (type != 'free_class') {
      isPremium.value = true;
    }
  }

  static void login() {
    isLoggedIn.value = true;
  }

  /// Logout: hapus token dari SharedPreferences dan reset status login
  static Future<void> logout() async {
    // Panggil endpoint logout Laravel jika token ada
    if (currentToken != null) {
      try {
        final dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 3),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $currentToken',
            },
          ),
        );
        await dio.post('/auth/logout');
      } catch (_) {}
    }

    currentToken = null;
    userEmail = null;
    userId = null;
    userRole = null;
    isLoggedIn.value = false;
    activeEntitlements.value = {'free_class'};
    membershipNumberNotifier.value = '';
    WishlistHelper.clear();
    learningProgress.value = 0.0;
    birthDate = null;
    gender = null;
    phone = null;
    whatsapp = null;
    address = null;
    province = null;
    city = null;
    district = null;
    village = null;
    instagram = null;
    facebook = null;
    tiktok = null;
    youtube = null;
    checkAndNotifyProfileComplete();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userRoleKey);
      debugPrint("[SessionManager] Sesi dan token berhasil dihapus dari storage.");
    } catch (e) {
      debugPrint("[SessionManager] Error clearing storage: $e");
    }
  }

  /// Ambil data profil lengkap terkini dari backend (GET /api/v1/auth/me)
  static Future<void> fetchProfileFromBackend() async {
    if (currentToken == null) return;
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 5),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $currentToken',
          },
        ),
      );

      final res = await dio.get('/auth/me');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'] as Map<String, dynamic>;
        userName = data['name'] ?? userName;
        userEmail = data['email'] ?? userEmail;
        if (data['birth_date'] != null) {
          birthDate = DateTime.tryParse(data['birth_date']);
        }
        gender = data['gender'];
        phone = data['phone'];
        whatsapp = data['whatsapp'];
        address = data['address'];
        province = data['province'];
        city = data['city'];
        district = data['district'];
        village = data['village'];
        instagram = data['instagram'];
        facebook = data['facebook'];
        tiktok = data['tiktok'];
        youtube = data['youtube'];

        // Sinkronisasi data KTA Membership dari database backend
        if (data['membership'] != null && data['membership'].toString().isNotEmpty) {
          membershipNumberNotifier.value = data['membership'].toString();
          if (data['is_active_member'] == true) {
            grantEntitlement('android');
          }
        } else {
          membershipNumberNotifier.value = '';
        }

        checkAndNotifyProfileComplete();
        debugPrint("[SessionManager] Profil berhasil dimuat dari database! Lengkap: $isProfileComplete");
      }
    } catch (e) {
      debugPrint("[SessionManager] Gagal mengambil profil dari server: $e");
    }
  }

  /// Sync data profil lengkap ke Laravel Web Database (POST /api/v1/user/demographics)
  static Future<bool> syncProfileToBackend({
    String? name,
    DateTime? birthDate,
    String? gender,
    String? phone,
    String? whatsapp,
    String? address,
    String? province,
    String? city,
    String? district,
    String? village,
    String? instagram,
    String? facebook,
    String? tiktok,
    String? youtube,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (currentToken != null) 'Authorization': 'Bearer $currentToken',
          },
        ),
      );

      final dateStr = birthDate != null
          ? "${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}"
          : null;

      final Map<String, dynamic> payload = {
        'name': name ?? userName,
        if (userEmail.isNotEmpty) 'email': userEmail,
        'birth_date': dateStr,
        'gender': gender,
        'phone': phone,
        'whatsapp': whatsapp,
        'address': address,
        'province_name': province,
        'city_name': city,
        'district': district,
        'village': village,
        'instagram': instagram,
        'facebook': facebook,
        'tiktok': tiktok,
        'youtube': youtube,
      };
      if (userId != null) {
        payload['user_id'] = userId;
      }

      final res = await dio.post('/user/demographics', data: payload);
      checkAndNotifyProfileComplete();
      debugPrint("[SessionManager] Profil berhasil disinkronkan ke backend: ${res.data}");
      return true;
    } catch (e) {
      debugPrint("[SessionManager] Profile sync notice: $e");
      return false;
    }
  }

  /// Aktivasi Membership KTA ke Database Backend Laravel (POST /api/v1/membership/activate)
  static Future<bool> activateMembershipOnBackend(String package) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (currentToken != null) 'Authorization': 'Bearer $currentToken',
          },
        ),
      );

      final payload = {
        'package': package.toLowerCase(),
        if (userEmail.isNotEmpty) 'email': userEmail,
        if (userId != null) 'user_id': userId,
      };

      final res = await dio.post('/membership/activate', data: payload);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final memberData = res.data['data'];
        if (memberData != null && memberData['membership_number'] != null) {
          membershipNumberNotifier.value = memberData['membership_number'].toString();
        }
        final pkg = package.toLowerCase();
        if (pkg.contains('bundling')) {
          grantEntitlement('bundling');
          grantEntitlement('android');
          grantEntitlement('iphone');
        } else if (pkg.contains('android')) {
          grantEntitlement('android');
        } else if (pkg.contains('iphone')) {
          grantEntitlement('iphone');
        } else {
          grantEntitlement(pkg);
        }
        debugPrint("[SessionManager] Membership KTA berhasil diaktifkan di server backend: ${memberData?['membership_number']}");
        return true;
      }
    } catch (e) {
      debugPrint("[SessionManager] Error activating membership on backend: $e");
    }

    // Fallback lokal jika offline
    final pkg = package.toLowerCase();
    if (pkg.contains('bundling')) {
      grantEntitlement('bundling');
      grantEntitlement('android');
      grantEntitlement('iphone');
    } else if (pkg.contains('android')) {
      grantEntitlement('android');
    } else if (pkg.contains('iphone')) {
      grantEntitlement('iphone');
    } else {
      grantEntitlement(pkg);
    }
    return false;
  }
}

