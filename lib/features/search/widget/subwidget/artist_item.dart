import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_artist.dart';
import 'package:music_player/features/artist/artist_detail_page.dart';
import 'package:music_player/utils/constants/colors.dart';

class ArtistItem extends StatelessWidget {
  const ArtistItem({
    super.key,
    required this.artist,
  });

  final SpotifyArtist artist;

  String? _getImageUrl() {
    if (artist.images != null && artist.images!.isNotEmpty) {
      return artist.images!.first.url;
    }
    return null;
  }

  String _getFollowersText() {
    if (artist.followers == null) return '';
    
    final count = artist.followers!.total;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M followers';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K followers';
    }
    return '$count followers';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FColors.darkContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtistDetailPage(artist: artist),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Artist Image (Circular)
                ClipOval(
                  child:
                      imageUrl != null
                          ? Image.network(
                            imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                          : _buildPlaceholder(),
                ),
                const SizedBox(width: 12),

                // Artist Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist.name,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: FColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ARTIST',
                          style: TextStyle(
                            color: FColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      if (artist.followers != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _getFollowersText(),
                          style: TextStyle(
                            color: FColors.textWhite.withValues(alpha: 0.6),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // More Options
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: FColors.textWhite.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    // TODO: Show more options
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: FColors.darkerGrey,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: FColors.textWhite.withValues(alpha: 0.3),
        size: 32,
      ),
    );
  }
}

