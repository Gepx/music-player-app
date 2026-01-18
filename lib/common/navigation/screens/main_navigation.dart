import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/widgets/bottom_navigation_bar.dart';
import 'package:music_player/common/navigation/controllers/navigation_controller.dart';
import 'package:music_player/features/home/widget/mini_player.dart';
import 'package:music_player/features/player/widgets/spotify_embed_host.dart';
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
          // Mini player should sit above the nav bar (not replace it).
          const Positioned(
            left: 0,
            right: 0,
            // IMPORTANT: Positioned inside the Scaffold body. The body already
            // ends at the top of bottomNavigationBar, so `bottom: 0` makes the
            // mini player sit flush on top of the navbar (no gap).
            bottom: 0,
            child: MiniPlayer(),
          ),
          // Global hidden Spotify Embed host (mobile)
          const Positioned.fill(
            child: IgnorePointer(child: SpotifyEmbedHost()),
          ),
          // Global hidden Web Playback SDK host (web/desktop)
          const Positioned.fill(
            child: IgnorePointer(child: WebPlaybackHost()),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => FBottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
        ),
      ),
    );
  }
}
