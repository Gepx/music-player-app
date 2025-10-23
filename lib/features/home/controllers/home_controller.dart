import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final ScrollController scrollController = ScrollController();
  final RxBool showAppBar = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.offset > 100) {
      if (!showAppBar.value) {
        showAppBar.value = true;
      }
    } else {
      if (showAppBar.value) {
        showAppBar.value = false;
      }
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
