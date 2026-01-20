import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/data/repositories/user_repository.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/utils/constants/text_strings.dart';
import 'package:music_player/utils/helpers/helper_functions.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _submitting = false;
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  @override
  void initState() {
    super.initState();
    _email.text = widget.initialEmail ?? '';
  }

  @override
  void dispose() {
    _email.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _req(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final repo = UserRepository();
    final res = await repo.updatePasswordDirect(
      email: _email.text.trim(),
      newPassword: _newPassword.text.trim(),
    );

    if (mounted) {
      setState(() => _submitting = false);
    }

    if (res.success) {
      FHelperFunctions.showSnackBar(
        res.message ?? 'Password updated',
      );
      if (mounted) Get.back();
    } else {
      FHelperFunctions.showSnackBar(
        res.message ?? FTexts.errorOccurred,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: FColors.dark,
      appBar: AppBar(
        backgroundColor: FColors.dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FColors.textWhite),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          FTexts.resetPassword,
          style: TextStyle(
            color: FColors.textWhite,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email and new password to update it.',
              style: TextStyle(
                color: FColors.textWhite,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),
            Form(
              key: _formKey,
              child: Column(
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
                  TextFormField(
                    controller: _newPassword,
                    style: TextStyle(color: dark ? FColors.white : FColors.black),
                    cursorColor: dark ? FColors.white : FColors.black,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.password_check),
                      labelText: FTexts.newPassword,
                      hintStyle: const TextStyle(color: FColors.grey),
                      hintText: '${FTexts.enterYour} ${FTexts.newPassword}',
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
                    validator: (v) {
                      final required = _req(v, FTexts.newPassword);
                      if (required != null) return required;
                      if (v != null && v.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: FSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: _confirmPassword,
                    style: TextStyle(color: dark ? FColors.white : FColors.black),
                    cursorColor: dark ? FColors.white : FColors.black,
                    obscureText: !_confirmVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.password_check),
                      labelText: FTexts.confirmPassword,
                      hintStyle: const TextStyle(color: FColors.grey),
                      hintText: '${FTexts.enterYour} ${FTexts.confirmPassword}',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _confirmVisible = !_confirmVisible;
                          });
                        },
                        icon: Icon(
                          _confirmVisible ? Iconsax.eye : Iconsax.eye_slash,
                        ),
                      ),
                    ),
                    validator: (v) {
                      final required = _req(v, FTexts.confirmPassword);
                      if (required != null) return required;
                      if (v != _newPassword.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? 'Updating...' : 'Update password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
