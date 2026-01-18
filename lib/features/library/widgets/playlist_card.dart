import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../utils/constants/colors.dart';
import '../../../data/models/user/playlist.dart';
import 'playlist_cover.dart';
import '../playlist_detail_page.dart';

/// Playlist Card
/// Displays a single playlist with its cover and metadata
class PlaylistCard extends StatelessWidget {
  final Playlist playlist;

  const PlaylistCard({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistDetailPage(playlist: playlist),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: FColors.darkContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist Cover
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: PlaylistCover(playlist: playlist),
              ),
            ),

            // Playlist Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      color: FColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Iconsax.music,
                        size: 12,
                        color: FColors.textWhite.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${playlist.trackCount} ${playlist.trackCount == 1 ? 'track' : 'tracks'}',
                        style: TextStyle(
                          color: FColors.textWhite.withOpacity(0.6),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

