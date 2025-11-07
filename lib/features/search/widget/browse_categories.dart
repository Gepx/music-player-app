import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/features/search/widget/subwidget/category_card.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'genre_results_page.dart';

class BrowseCategories extends StatelessWidget {
  const BrowseCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      CategoryItem('Pop', FColors.accent, Iconsax.music_circle),
      CategoryItem('Hip-Hop', FColors.warning, Iconsax.microphone_2),
      CategoryItem('Rock', FColors.error, Iconsax.music_library_2),
      CategoryItem('Jazz', FColors.info, Iconsax.music_filter),
      CategoryItem('Electronic', FColors.success, Iconsax.sound),
      CategoryItem('Classical', FColors.primary, Iconsax.music_library_2),
      CategoryItem('Country', FColors.warning, Iconsax.music_play),
      CategoryItem('R&B', FColors.secondary, Iconsax.heart),
      CategoryItem(
        'Indie',
        FColors.accent.withValues(alpha: 0.8),
        Iconsax.music_dashboard,
      ),
      CategoryItem('Folk', FColors.darkGrey, Iconsax.music_play),
      CategoryItem(
        'Reggae',
        FColors.success.withValues(alpha: 0.7),
        Iconsax.music_square,
      ),
      CategoryItem(
        'Blues',
        FColors.secondary.withValues(alpha: 0.8),
        Iconsax.music_square_add,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Browse all',
          style: TextStyle(
            color: FColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(
              category: category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenreResultsPage(title: category.name),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
