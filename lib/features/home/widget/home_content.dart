import 'package:flutter/material.dart';
import 'package:music_player/features/home/widget/browse_list.dart';
import 'package:music_player/features/home/widget/made_for_you.dart';
import 'package:music_player/features/home/widget/quick_access.dart';
import 'package:music_player/features/home/widget/recently_played.dart';
import 'package:music_player/features/home/widget/section_title.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recently Played Section (conditionally renders title + grid inside)
            const RecentlyPlayedGrid(),
            const SizedBox(height: 32),

            // Made for You Section
            const SectionTitle(title: 'Made for You'),
            const SizedBox(height: 16),
            const MadeForYouList(),
            const SizedBox(height: 32),

            // Quick Access Section
            const SectionTitle(title: 'Quick Access'),
            const SizedBox(height: 16),
            const QuickAccessGrid(),
            const SizedBox(height: 32),

            // Browse Section
            const SectionTitle(title: 'Browse'),
            const SizedBox(height: 16),
            const BrowseList(),
            const SizedBox(height: 100), // Bottom padding for mini player
          ],
        ),
      ),
    );
  }
}
