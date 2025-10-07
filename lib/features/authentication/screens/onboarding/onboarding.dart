import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:music_player/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:music_player/features/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:music_player/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:music_player/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:music_player/utils/constants/image_strings.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/constants/text_strings.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: FSizes.appBarHeight),
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.updatePageIndicator,
              children: const <Widget>[
                OnBoardingPage(
                  image: FImages.onBoardingImage1,
                  title: FTexts.onBoardingTitle1,
                  subTitle: FTexts.onBoardingSubTitle1,
                ),
                OnBoardingPage(
                  image: FImages.onBoardingImage2,
                  title: FTexts.onBoardingTitle2,
                  subTitle: FTexts.onBoardingSubTitle2,
                ),
                OnBoardingPage(
                  image: FImages.onBoardingImage3,
                  title: FTexts.onBoardingTitle3,
                  subTitle: FTexts.onBoardingSubTitle3,
                ),
              ],
            ),
          ),

          const OnBoardingSkip(),

          const OnBoardingDotNavigation(),

          const OnBoardingNextButton(),
        ],
      ),
    );
  }
}
