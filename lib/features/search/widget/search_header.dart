import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.isSearching,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isSearching;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search',
            style: TextStyle(
              color: FColors.textWhite,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: FColors.darkContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    searchFocusNode.hasFocus
                        ? FColors.primary
                        : FColors.darkerGrey,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              style: const TextStyle(
                color: FColors.textWhite,
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Artists, songs, or podcasts',
                hintStyle: TextStyle(
                  color: FColors.textWhite.withValues(alpha: 0.6),
                  fontFamily: 'Poppins',
                ),
                prefixIcon: Icon(
                  Iconsax.search_normal_1,
                  color: FColors.textWhite.withValues(alpha: 0.6),
                ),
                suffixIcon:
                    isSearching
                        ? IconButton(
                          onPressed: onClearSearch,
                          icon: Icon(
                            Iconsax.close_circle,
                            color: FColors.textWhite.withValues(alpha: 0.6),
                          ),
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
