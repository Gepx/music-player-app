import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/common/navigation/screens/main_navigation.dart';
import 'package:music_player/data/repositories/repositories.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/constants/text_strings.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';
import 'package:music_player/utils/theme/custom_themes/text_theme.dart';

class FSignupForm extends StatefulWidget {
  const FSignupForm({super.key});

  @override
  State<FSignupForm> createState() => _FSignupFormState();
}

class _FSignupFormState extends State<FSignupForm> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _agree = false;
  bool _submitting = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
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
      child: Column(
        children: [
          // First & Last name
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstName,
                  style: TextStyle(color: dark ? FColors.white : FColors.black),
                  cursorColor: dark ? FColors.white : FColors.black,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: FTexts.firstName,
                    hintStyle: TextStyle(color: FColors.grey),
                    hintText: '${FTexts.enterYour} ${FTexts.firstName}',
                  ),
                  validator: (v) => _req(v, FTexts.firstName),
                ),
              ),
              const SizedBox(width: FSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  controller: _lastName,
                  style: TextStyle(color: dark ? FColors.white : FColors.black),
                  cursorColor: dark ? FColors.white : FColors.black,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: FTexts.lastName,
                    hintStyle: TextStyle(color: FColors.grey),
                    hintText: '${FTexts.enterYour} ${FTexts.lastName}',
                  ),
                  validator: (v) => _req(v, FTexts.lastName),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

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
                icon: Icon(_passwordVisible ? Iconsax.eye : Iconsax.eye_slash),
              ),
            ),
            validator: (v) => _req(v, FTexts.password),
          ),

          const SizedBox(height: FSizes.spaceBtwSections),

          // Terms
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agree,
                  onChanged: (v) => setState(() => _agree = v ?? false),
                ),
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

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _submitting
                      ? null
                      : () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (!_agree) {
                          FHelperFunctions.showSnackBar(
                            'Please agree to the Terms and Privacy Policy.',
                          );
                          return;
                        }

                        setState(() => _submitting = true);
                        final repo = UserRepository();
                        final displayName =
                            '${_firstName.text} ${_lastName.text}'.trim();

                        final res = await repo.registerWithEmail(
                          email: _email.text.trim(),
                          password: _password.text,
                          displayName: displayName,
                        );
                        
                        if (mounted) {
                          setState(() => _submitting = false);
                        }

                        if (res.success) {
                          FHelperFunctions.showSnackBar(
                            FTexts.accountCreatedSuccessfully,
                          );
                          Get.offAll(MainNavigation());
                        } else {
                          FHelperFunctions.showSnackBar(
                            res.message ?? FTexts.errorOccurred,
                          );
                        }
                      },
              child:
                  _submitting
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text(FTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
