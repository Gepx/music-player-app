import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/image_strings.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/constants/text_strings.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';

class FLoginHeader extends StatelessWidget {
  const FLoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image(
          height: 150,
          image: AssetImage(dark ? FImages.lightAppLogo : FImages.darkAppLogo),
        ),
        Text(
          FTexts.loginTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: FSizes.sm),
        Text(
          FTexts.loginSubTitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
