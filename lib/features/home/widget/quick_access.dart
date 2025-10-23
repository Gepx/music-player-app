import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final quickAccess = [
      {
        'title': 'Songs',
        'icon': Iconsax.music,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Artists',
        'icon': Iconsax.user,
        'color': const Color(0xFF7C3AED),
      },
      {'title': 'Albums', 'icon': Iconsax.cd, 'color': const Color(0xFF6D28D9)},
      {
        'title': 'Playlists',
        'icon': Iconsax.music_playlist,
        'color': const Color(0xFF5B21B6),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: quickAccess.length,
      itemBuilder: (context, index) {
        final item = quickAccess[index];
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
