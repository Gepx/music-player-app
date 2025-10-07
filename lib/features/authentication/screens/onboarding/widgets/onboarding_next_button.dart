import 'package:flutter/material.dart';
import 'package:music_player/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/device/device_utility.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({super.key});
  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    return Positioned(
      bottom: FSizes.defaultSpace + 30,
      right: FDeviceUtils.getBottomNavigationBarHeight() - 15,
      child: ElevatedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: dark ? FColors.primary : FColors.black,
          side: BorderSide.none,
        ),
        child: const Icon(Iconsax.arrow_right_1_copy),
      ),
    );
  }
}
