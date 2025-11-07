import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/widgets/bottom_navigation_bar.dart';
import 'package:music_player/common/navigation/controllers/navigation_controller.dart';
import 'package:music_player/features/home/widget/mini_player.dart';
import 'package:music_player/features/player/widgets/web_playback_host.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      body: Stack(
        children: [
          Obx(() => controller.currentPage),
          // Global hidden Web Playback SDK host (web/desktop)
          const Positioned.fill(
            child: IgnorePointer(child: WebPlaybackHost()),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          Obx(
            () => FBottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changePage,
            ),
          ),
        ],
      ),
    );
  }
}
