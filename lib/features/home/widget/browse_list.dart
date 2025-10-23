import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class BrowseList extends StatelessWidget {
  const BrowseList({super.key});

  @override
  Widget build(BuildContext context) {
    final browseItems = [
      {'title': 'New Releases', 'subtitle': 'The latest music'},
      {'title': 'Charts', 'subtitle': 'Top songs and albums'},
      {'title': 'Genres & Moods', 'subtitle': 'Find your vibe'},
      {'title': 'Podcasts', 'subtitle': 'Discover podcasts'},
    ];

    return Column(
      children:
          browseItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                subtitle: Text(
                  item['subtitle'] as String,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                trailing: const Icon(
                  Iconsax.arrow_right_3,
                  color: Colors.white,
                  size: 20,
                ),
                onTap: () {},
              ),
            );
          }).toList(),
    );
  }
}
