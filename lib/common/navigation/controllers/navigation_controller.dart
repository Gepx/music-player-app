import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/features/home/screen/home_page.dart';
import 'package:music_player/features/search/search_page.dart';
import 'package:music_player/features/library/library_page.dart' as feature_library;
import 'package:music_player/features/premium/premium_page.dart';
import 'package:music_player/features/profile/profile_page.dart';
import 'package:music_player/data/services/music/recent_plays_service.dart';
import 'package:music_player/data/services/ads/interstitial_ad_manager.dart';

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();

  final RxInt currentIndex = 0.obs;
  int _navigationCount = 0;

  // Navigation pages
  final List<Widget> pages = [
    const HomePage(),
    const SearchPage(),
    const feature_library.LibraryPage(),
    const PremiumPage(),
    const ProfilePage(),
  ];

  @override
  void onInit() {
    super.onInit();
    // After login, pull cloud listening history into local cache so
    // "Recently Played" stays consistent across devices.
    // ignore: unawaited_futures
    RecentPlaysService.instance.syncFromCloud().catchError((_) {});
  }

  void changePage(int index) {
    if (index < pages.length) {
      if (index == currentIndex.value) return;
      currentIndex.value = index;

      // Show an interstitial every 4th navigation (CP5a).
      _navigationCount++;
      if (_navigationCount % 4 == 0) {
        // ignore: unawaited_futures
        InterstitialAdManager.instance.showIfReady().catchError((_) {});
      }
    }
  }

  Widget get currentPage => pages[currentIndex.value];
}
