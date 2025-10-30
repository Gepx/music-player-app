import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/colors.dart';

class FSongInfo extends StatelessWidget {
  const FSongInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Now Playing',
            style: TextStyle(
              color: FColors.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Artist Name',
            style: TextStyle(
              color: FColors.textWhite.withValues(alpha: 0.6),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
