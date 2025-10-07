import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';
import 'package:music_player/utils/theme/custom_themes/text_theme.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  final String image, title, subTitle;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      child: Column(
        children: [
          Image(
            width: FHelperFunctions.screenWidth() * 0.8,
            height: FHelperFunctions.screenHeight() * 0.6,
            image: AssetImage(image),
          ),
          Text(
            title,
            style:
                dark
                    ? FTextTheme.lightTextTheme.headlineMedium
                    : FTextTheme.darkTextTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          Text(
            subTitle,
            style:
                dark
                    ? FTextTheme.lightTextTheme.bodyMedium
                    : FTextTheme.darkTextTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
