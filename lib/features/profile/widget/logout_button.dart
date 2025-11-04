import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/data/services/auth/auth_service.dart';
import 'package:music_player/features/authentication/screens/login/login.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _handleLogout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: FColors.darkerGrey,
        title: const Text(
          'Log Out',
          style: TextStyle(color: FColors.textWhite),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: FColors.textWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: FColors.textWhite),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: FColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AuthService.instance.signOut();
        Get.offAll(() => const LoginScreen());
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to log out. Please try again.',
          backgroundColor: FColors.error,
          colorText: FColors.textWhite,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: _handleLogout,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: FColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: FColors.error.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.logout_1, color: FColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Log Out',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: FColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
