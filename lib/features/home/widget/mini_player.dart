import 'package:flutter/material.dart';
import 'package:music_player/features/home/widget/subwidget/mini_player/controls.dart';
import 'package:music_player/features/home/widget/subwidget/mini_player/songinfo.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: FColors.darkContainer,
        border: Border(top: BorderSide(color: FColors.darkerGrey, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Album Art
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [FColors.primary, FColors.secondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Iconsax.music, color: FColors.textWhite, size: 24),
              ),
            ),
            const SizedBox(width: 12),

            // Song Info
            FSongInfo(),

            // Controls
            FControls(),
          ],
        ),
      ),
    );
  }
}
