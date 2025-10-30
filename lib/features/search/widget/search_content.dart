import 'package:flutter/material.dart';
import 'package:music_player/features/search/widget/browse_categories.dart';
import 'package:music_player/features/search/widget/recent_searches.dart';

class SearchContent extends StatelessWidget {
  const SearchContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          const RecentSearches(),
          const SizedBox(height: 32),

          // Browse All Section
          const BrowseCategories(),

          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }
}
