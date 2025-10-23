import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/features/authentication/screens/signup/signup.dart';
import 'package:music_player/common/navigation/screens/main_navigation.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/constants/text_strings.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';

class FLoginForm extends StatelessWidget {
  const FLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FSizes.spaceBtwSections),
        child: Column(
          // Email
          children: [
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: FTexts.email,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwInputFields),

            // Password
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.password_check),
                labelText: FTexts.password,
                suffixIcon: Icon(Iconsax.eye_slash),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwInputFields / 2),

            // Remember Me and Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember Me
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    Text(
                      FTexts.rememberMe,
                      style: TextStyle(
                        color: dark ? FColors.white : FColors.black,
                      ),
                    ),
                  ],
                ),

                // Forget Password
                TextButton(
                  onPressed: () {},
                  child: const Text(FTexts.forgotPassword),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(() => const MainNavigation());
                },
                child: Text(FTexts.signIn),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Create Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignupScreen()),
                child: Text(FTexts.createAccount),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}
