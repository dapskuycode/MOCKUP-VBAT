import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SessionManager {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isPremium = ValueNotifier<bool>(true);
  static final ValueNotifier<int> currentTabIndex = ValueNotifier<int>(0);

  // Demographic & Profile state for admin analytics
  static final ValueNotifier<String> userNameNotifier = ValueNotifier<String>("Andi Teknisi");
  static String get userName => userNameNotifier.value;
  static set userName(String? val) {
    if (val != null && val.isNotEmpty) {
      userNameNotifier.value = val;
    }
  }

  static DateTime? birthDate = DateTime(2004, 3, 15);
  static String? gender = "Laki-laki";
  static String? province = "DKI Jakarta";
  static String? city = "Jakarta Pusat";
  static bool profileCompleted = true;

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

  static void login() {
    isLoggedIn.value = true;
  }

  static void logout() {
    isLoggedIn.value = false;
  }

  /// Sync data demografi ke Laravel Web Database (API endpoint)
  static Future<void> syncProfileToBackend({
    String? name,
    DateTime? birthDate,
    String? gender,
    String? province,
    String? city,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api/v1',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final dateStr = birthDate != null
          ? "${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}"
          : null;

      await dio.post('/user/demographics', data: {
        'name': name ?? userName,
        'birth_date': dateStr,
        'gender': gender,
        'city_name': city,
        'user_id': 4,
      });
      debugPrint("Demographics successfully synced to web backend!");
    } catch (e) {
      debugPrint("Demographics sync notice: $e");
    }
  }
}

