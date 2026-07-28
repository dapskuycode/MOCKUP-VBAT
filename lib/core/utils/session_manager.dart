import 'package:flutter/material.dart';

class SessionManager {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<int> currentTabIndex = ValueNotifier<int>(0);

  static void login() {
    isLoggedIn.value = true;
  }

  static void logout() {
    isLoggedIn.value = false;
  }
}
