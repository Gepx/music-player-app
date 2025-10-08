import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/constants/text_strings.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/utils/theme/custom_themes/text_theme.dart';

class FSignupForm extends StatelessWidget {
  const FSignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Form(
      child: Column(
        children: [
          /// Username
          TextFormField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.user),
              labelText: FTexts.username,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          /// Email
          TextFormField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.direct_right),
              labelText: FTexts.email,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          /// Password
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.password_check),
              labelText: FTexts.password,
              suffixIcon: Icon(Iconsax.eye_slash),
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwSections),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(value: true, onChanged: (value) {}),
              ),
              const SizedBox(width: FSizes.spaceBtwItems),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${FTexts.iAgreeTo} ',
                        style:
                            dark
                                ? FTextTheme.lightTextTheme.bodySmall
                                : FTextTheme.darkTextTheme.bodySmall,
                      ),
                      TextSpan(
                        text: FTexts.privacyPolicy,
                        style: FTextTheme.darkTextTheme.bodyMedium!.apply(
                          color: dark ? FColors.white : FColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              dark ? FColors.white : FColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: ' ${FTexts.and} ',
                        style:
                            dark
                                ? FTextTheme.lightTextTheme.bodySmall
                                : FTextTheme.darkTextTheme.bodySmall,
                      ),
                      TextSpan(
                        text: FTexts.termsOfUse,
                        style: FTextTheme.darkTextTheme.bodyMedium!.apply(
                          color: dark ? FColors.white : FColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              dark ? FColors.white : FColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwSections),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(FTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
