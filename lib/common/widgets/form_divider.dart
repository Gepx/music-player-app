import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';
import 'package:music_player/utils/theme/custom_themes/text_theme.dart';

class FFormDivider extends StatelessWidget {
  const FFormDivider({super.key, required this.dividerText});

  final String dividerText;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Divider(
            color: dark ? FColors.darkGrey : FColors.grey,
            thickness: 0.5,
            indent: 60,
            endIndent: 5,
          ),
        ),
        Text(
          dividerText,
          style:
              dark
                  ? FTextTheme.lightTextTheme.labelMedium
                  : FTextTheme.darkTextTheme.labelMedium,
        ),
        Flexible(
          child: Divider(
            color: dark ? FColors.darkGrey : FColors.grey,
            thickness: 0.5,
            indent: 60,
            endIndent: 5,
          ),
        ),
      ],
    );
  }
}
