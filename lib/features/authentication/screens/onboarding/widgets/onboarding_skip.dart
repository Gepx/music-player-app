import 'package:flutter/material.dart';
import 'package:music_player/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/device/device_utility.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: FDeviceUtils.getAppBarHeight(),
      right: FSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnBoardingController.instance.skipPage(),
        child: const Text("Skip"),
      ),
    );
  }
}
