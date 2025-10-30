import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';

class SearchResultsEmpty extends StatelessWidget {
  const SearchResultsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_normal_1,
            color: FColors.textWhite.withValues(alpha: 0.54),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for artists, songs, or podcasts',
            style: TextStyle(
              color: FColors.textWhite.withValues(alpha: 0.54),
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
