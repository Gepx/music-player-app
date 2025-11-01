import 'package:flutter/material.dart';
import 'package:music_player/data/models/app/app_models.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/features/profile/widget/playlist_card.dart';

class PlaylistsSection extends StatelessWidget {
  const PlaylistsSection({
    super.key,
    required this.playlists,
    required this.isLoading,
    required this.onSeeAll,
  });

  final List<PlaylistModel> playlists;
  final bool isLoading;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator(color: FColors.primary)),
      );
    }

    if (playlists.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Your Playlists',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: FColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No playlists yet',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: FColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final displayPlaylists = playlists.take(6).toList();
    final hasMorePlaylists = playlists.length > 6;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Playlists',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: FColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasMorePlaylists)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    'See All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: FColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: displayPlaylists.length,
            itemBuilder: (context, index) {
              return PlaylistCard(playlist: displayPlaylists[index]);
            },
          ),
          if (hasMorePlaylists)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSeeAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.darkerGrey,
                    foregroundColor: FColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'See All ${playlists.length} Playlists',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
