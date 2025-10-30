import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';

class FControls extends StatelessWidget {
  const FControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Iconsax.previous,
            color: FColors.textWhite,
            size: 20,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.pause, color: FColors.textWhite, size: 24),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.next, color: FColors.textWhite, size: 20),
        ),
      ],
    );
  }
}
