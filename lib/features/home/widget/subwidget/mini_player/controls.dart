import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/data/services/playback/playback_service.dart';

class FControls extends StatelessWidget {
  const FControls({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = PlaybackService.instance;
    return Row(
      children: [
        IconButton(
          onPressed: playback.hasPrevious ? playback.playPrevious : null,
          icon: const Icon(
            Iconsax.previous,
            color: FColors.textWhite,
            size: 20,
          ),
        ),
        IconButton(
          onPressed: playback.togglePlayPause,
          icon: const Icon(Iconsax.play, color: FColors.textWhite, size: 24),
        ),
        IconButton(
          onPressed: playback.hasNext ? playback.playNext : null,
          icon: const Icon(Iconsax.next, color: FColors.textWhite, size: 20),
        ),
      ],
    );
  }
}
