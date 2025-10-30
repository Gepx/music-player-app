import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/features/home/screen/home_page.dart';
import 'package:music_player/features/search/search_page.dart';
import 'package:music_player/common/navigation/screens/placeholder_pages.dart';

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();

  final RxInt currentIndex = 0.obs;

  // Navigation pages
  final List<Widget> pages = [
    const HomePage(),
    const SearchPage(),
    const LibraryPage(),
    const PremiumPage(),
    const ProfilePage(),
  ];

  void changePage(int index) {
    if (index < pages.length) {
      currentIndex.value = index;
    }
  }

  Widget get currentPage => pages[currentIndex.value];
}
