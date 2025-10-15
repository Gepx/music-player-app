import 'package:flutter/material.dart';

class RecentlyPlayedGrid extends StatelessWidget {
  const RecentlyPlayedGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final recentlyPlayed = [
      {
        'title': 'Liked Songs',
        'subtitle': 'Playlist • 47 songs',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Chill Vibes',
        'subtitle': 'Playlist • 23 songs',
        'color': const Color(0xFF7C3AED),
      },
      {
        'title': 'Workout Mix',
        'subtitle': 'Playlist • 31 songs',
        'color': const Color(0xFF6D28D9),
      },
      {
        'title': 'Study Focus',
        'subtitle': 'Playlist • 19 songs',
        'color': const Color(0xFF5B21B6),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: recentlyPlayed.length,
      itemBuilder: (context, index) {
        final item = recentlyPlayed[index];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item['color'] as Color,
                (item['color'] as Color).withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'] as String,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
