import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/data/models/user_model.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, required this.user});

  final UserModel? user;

  Future<void> _handleShare() async {
    final displayName =
        user?.displayName ?? user?.email.split('@').first ?? 'User';
    final shareText =
        'Check out my music profile: $displayName\n\nFollow me on Flashback Music!';

    try {
      await Clipboard.setData(ClipboardData(text: shareText));
      Get.snackbar(
        'Copied!',
        'Profile link copied to clipboard',
        backgroundColor: FColors.success,
        colorText: FColors.textWhite,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share profile',
        backgroundColor: FColors.error,
        colorText: FColors.textWhite,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleShare,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: FColors.darkerGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FColors.textWhite.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.share, color: FColors.textWhite, size: 18),
            const SizedBox(width: 8),
            Text(
              'Share Profile',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: FColors.textWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
