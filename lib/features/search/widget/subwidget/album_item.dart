import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_album.dart';
import 'package:music_player/features/album/album_detail_page.dart';
import 'package:music_player/utils/constants/colors.dart';

class AlbumItem extends StatelessWidget {
  const AlbumItem({
    super.key,
    required this.album,
  });

  final SpotifyAlbum album;

  String _getArtistNames() {
    return album.artists.map((artist) => artist.name).join(', ');
  }

  String? _getImageUrl() {
    if (album.images.isNotEmpty) {
      return album.images.first.url;
    }
    return null;
  }

  String _getAlbumInfo() {
    final year = album.releaseDate.split('-').first;
    return '$year • ${album.totalTracks} tracks';
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
                builder: (context) => AlbumDetailPage(album: album),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Album Art
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      imageUrl != null
                          ? Image.network(
                            imageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                          : _buildPlaceholder(),
                ),
                const SizedBox(width: 12),

                // Album Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: FColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          album.albumType.toUpperCase(),
                          style: TextStyle(
                            color: FColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        album.name,
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
                      Text(
                        _getArtistNames(),
                        style: TextStyle(
                          color: FColors.textWhite.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getAlbumInfo(),
                        style: TextStyle(
                          color: FColors.textWhite.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
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
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: FColors.darkerGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.album,
        color: FColors.textWhite.withValues(alpha: 0.3),
        size: 32,
      ),
    );
  }
}

