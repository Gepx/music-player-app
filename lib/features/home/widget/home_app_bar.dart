import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/features/home/controllers/home_app_bar_controller.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.showAppBar});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeAppBarController());

    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF000000),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title:
            showAppBar
                ? const Text(
                  'Music',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                )
                : null,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1a0033), Color(0xFF000000)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.getGreeting(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: controller.onNotificationTap,
                            icon: const Icon(
                              Iconsax.notification,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          IconButton(
                            onPressed: controller.onSettingsTap,
                            icon: const Icon(
                              Iconsax.setting_2,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
