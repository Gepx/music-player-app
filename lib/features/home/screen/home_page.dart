import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/features/home/controllers/home_controller.dart';
import 'package:music_player/features/home/widget/home_app_bar.dart';
import 'package:music_player/features/home/widget/home_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Get.put(HomeController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Obx(
        () => CustomScrollView(
          controller: controller.scrollController,
          slivers: [
            // Custom App Bar
            HomeAppBar(showAppBar: controller.showAppBar.value),

            // Content
            const HomeContent(),
          ],
        ),
      ),
    );
  }
}
