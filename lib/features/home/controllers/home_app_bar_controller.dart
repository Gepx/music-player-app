import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeAppBarController extends GetxController {
  static HomeAppBarController get instance => Get.find();

  // Handle notification button tap
  void onNotificationTap() {
    debugPrint('Notification button tapped');
  }

  // Handle settings button tap
  void onSettingsTap() {
    debugPrint('Settings button tapped');
  }

  // Get greeting message based on time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
