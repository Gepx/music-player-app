import 'package:flutter/material.dart';
import 'package:music_player/common/styles/spacing_styles.dart';
import 'package:music_player/common/widgets/form_divider.dart';
import 'package:music_player/features/authentication/screens/login/widgets/login_form.dart';
import 'package:music_player/features/authentication/screens/login/widgets/login_header.dart';
import 'package:music_player/features/authentication/screens/login/widgets/login_social_buttons.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/constants/text_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: FSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              /// Logo, Title & Sub-Title
              FLoginHeader(),

              FLoginForm(),

              FFormDivider(dividerText: FTexts.orSignInWith.toCapitalized()),
              const SizedBox(height: FSizes.spaceBtwSections),

              FSocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
