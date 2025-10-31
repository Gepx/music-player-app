import 'package:flutter/material.dart';
import 'package:music_player/data/services/services.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/utils/constants/image_strings.dart';
import 'package:music_player/utils/constants/sizes.dart';

class FSocialButtons extends StatelessWidget {
  const FSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: FColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () async {
              await AuthService.instance.signInWithGoogle();
            },
            icon: const Image(
              image: AssetImage(FImages.google),
              width: FSizes.iconMd,
              height: FSizes.iconMd,
            ),
          ),
        ),
        const SizedBox(width: FSizes.spaceBtwItems),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: FColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Image(
              image: AssetImage(FImages.facebook),
              width: FSizes.iconMd,
              height: FSizes.iconMd,
            ),
          ),
        ),
      ],
    );
  }
}
