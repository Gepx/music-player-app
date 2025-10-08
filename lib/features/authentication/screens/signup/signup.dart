import 'package:flutter/material.dart';
import 'package:music_player/common/widgets/form_divider.dart';
import 'package:music_player/common/widgets/social_buttons.dart';
import 'package:music_player/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/constants/text_strings.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';
import 'package:music_player/utils/theme/custom_themes/text_theme.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Signup Screen')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FTexts.signUpTitle,
                style:
                    dark
                        ? FTextTheme.lightTextTheme.headlineMedium
                        : FTextTheme.darkTextTheme.headlineMedium,
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              /// Form
              FSignupForm(),
              const SizedBox(height: FSizes.spaceBtwSections),

              /// Divider
              FFormDivider(dividerText: FTexts.orSignInWith.toCapitalized()),
              const SizedBox(height: FSizes.spaceBtwSections),

              /// Social Buttons
              const FSocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
