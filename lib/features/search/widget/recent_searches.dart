import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({super.key});

  @override
  Widget build(BuildContext context) {
    final recentSearches = [
      'Liked Songs',
      'Rock Classics',
      'Ed Sheeran',
      'Chill Vibes',
    ];

    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent searches',
          style: TextStyle(
            color: FColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        ...recentSearches.map((search) => _buildRecentSearchItem(search)),
      ],
    );
  }

  Widget _buildRecentSearchItem(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: FColors.linearGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Iconsax.music,
              color: FColors.textWhite,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: FColors.textWhite,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Remove from recent searches
            },
            icon: Icon(
              Iconsax.close_circle,
              color: FColors.textWhite.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
