import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/data/services/services.dart';
import 'package:music_player/features/authentication/screens/auth_wrapper.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  void updatePageIndicator(index) {
    currentPageIndex.value = index;
  }

  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  void nextPage() async {
    if (currentPageIndex.value == 2) {
      await PreferencesService.instance.setOnboardingCompleted(true);

      Get.offAll(() => const AuthWrapper());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() async {
    await PreferencesService.instance.setOnboardingCompleted(true);

    Get.offAll(() => const AuthWrapper());
  }
}
