import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/features/home/widget/pages/new_releases_page.dart';
import 'package:music_player/features/home/widget/pages/featured_playlists_page.dart';

class BrowseList extends StatelessWidget {
  const BrowseList({super.key});

  @override
  Widget build(BuildContext context) {
    final browseItems = [
      {'title': 'New Releases', 'subtitle': 'The latest music'},
      {'title': 'Charts', 'subtitle': 'Top songs and albums'},
      {'title': 'Genres & Moods', 'subtitle': 'Find your vibe'},
    ];

    return Column(
      children:
          browseItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: FColors.darkContainer,
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
                    color: FColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                subtitle: Text(
                  item['subtitle'] as String,
                  style: TextStyle(
                    color: FColors.textWhite.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                trailing: const Icon(
                  Iconsax.arrow_right_3,
                  color: FColors.textWhite,
                  size: 20,
                ),
                onTap: () {
                  final title = item['title'] as String;
                  if (title == 'New Releases') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewReleasesPage(),
                      ),
                    );
                  } else if (title == 'Charts') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeaturedPlaylistsPage(
                          title: 'Charts',
                          categoryId: 'toplists',
                        ),
                      ),
                    );
                  } else if (title == 'Genres & Moods') {
                    // Temporary: show featured playlists; can be replaced with a categories page later
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeaturedPlaylistsPage(title: 'Genres & Moods'),
                      ),
                    );
                  }
                },
              ),
            );
          }).toList(),
    );
  }
}
