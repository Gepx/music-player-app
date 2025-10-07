import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/image_strings.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/constants/text_strings.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';
import 'package:music_player/utils/theme/custom_themes/text_theme.dart';

class FLoginHeader extends StatelessWidget {
  const FLoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image(
            height: 150,
            image: AssetImage(
              dark ? FImages.lightAppLogo : FImages.darkAppLogo,
            ),
          ),
          Text(
            FTexts.loginTitle,
            style:
                dark
                    ? FTextTheme.lightTextTheme.headlineMedium
                    : FTextTheme.darkTextTheme.headlineMedium,
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            FTexts.loginSubTitle,
            style:
                dark
                    ? FTextTheme.lightTextTheme.bodyMedium
                    : FTextTheme.darkTextTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
