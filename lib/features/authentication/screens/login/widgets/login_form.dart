import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/data/repositories/user_repository.dart';
import 'package:music_player/features/authentication/screens/signup/signup.dart';
import 'package:music_player/common/navigation/screens/main_navigation.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/constants/text_strings.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';

class FLoginForm extends StatefulWidget {
  const FLoginForm({super.key});

  @override
  State<FLoginForm> createState() => _FLoginFormState();
}

class _FLoginFormState extends State<FLoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _rememberMe = false;
  bool _submitting = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _req(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FSizes.spaceBtwSections),
        child: Column(
          // Email
          children: [
            TextFormField(
              controller: _email,
              style: TextStyle(color: dark ? FColors.white : FColors.black),
              cursorColor: dark ? FColors.white : FColors.black,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: FTexts.email,
                hintStyle: TextStyle(color: FColors.grey),
                hintText: '${FTexts.enterYour} ${FTexts.email}',
              ),
              validator: (v) => _req(v, FTexts.email),
            ),
            const SizedBox(height: FSizes.spaceBtwInputFields),

            // Password
            TextFormField(
              controller: _password,
              style: TextStyle(color: dark ? FColors.white : FColors.black),
              cursorColor: dark ? FColors.white : FColors.black,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.password_check),
                labelText: FTexts.password,
                hintStyle: const TextStyle(color: FColors.grey),
                hintText: '${FTexts.enterYour} ${FTexts.password}',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  icon: Icon(
                    _passwordVisible ? Iconsax.eye : Iconsax.eye_slash,
                  ),
                ),
              ),
              validator: (v) => _req(v, FTexts.password),
            ),
            const SizedBox(height: FSizes.spaceBtwInputFields / 2),

            // Remember Me and Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember Me
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
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
                onPressed:
                    _submitting
                        ? null
                        : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _submitting = true);
                          final repo = UserRepository();
                          final res = await repo.signInWithEmail(
                            email: _email.text.trim(),
                            password: _password.text.trim(),
                          );

                          if (mounted) {
                            setState(() => _submitting = false);
                          }

                          if (res.success) {
                            FHelperFunctions.showSnackBar(FTexts.signInSuccess);
                            Get.offAll(MainNavigation());
                          } else {
                            FHelperFunctions.showSnackBar(
                              res.message ?? FTexts.errorOccurred,
                            );
                          }
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
