import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_track.dart';
import 'package:music_player/data/services/playback/spotify_embed_service.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/features/player/now_playing_page.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TrackItem extends StatelessWidget {
  const TrackItem({
    super.key,
    required this.track,
    this.playlist,
  });

  final SpotifyTrack track;
  final List<SpotifyTrack>? playlist;

  String _getArtistNames() {
    return track.artists.map((artist) => artist.name).join(', ');
  }

  String? _getImageUrl() {
    if (track.album?.images != null && track.album!.images.isNotEmpty) {
      return track.album!.images.first.url;
    }
    return null;
  }

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
                builder: (context) => NowPlayingPage(
                  track: track,
                  playlist: playlist,
                ),
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
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                          : _buildPlaceholder(),
                ),
                const SizedBox(width: 12),

                // Track Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.name,
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
                    ],
                  ),
                ),

                // Duration
                Text(
                  _formatDuration(track.durationMs),
                  style: TextStyle(
                    color: FColors.textWhite.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 8),

                // More Options
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: FColors.textWhite.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    _showTrackOptions(context);
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
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: FColors.darkerGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.music_note,
        color: FColors.textWhite.withValues(alpha: 0.3),
      ),
    );
  }

  void _showTrackOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FColors.darkContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FColors.darkGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Iconsax.play_add, color: FColors.textWhite),
              title: const Text(
                'Play Next',
                style: TextStyle(
                  color: FColors.textWhite,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () {
                final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
                if (isMobile) {
                  SpotifyEmbedService.instance.addPlayNext(track);
                } else {
                  WebPlaybackSDKService.instance.addPlayNext(track);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${track.name} will play next'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: FColors.primary,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.music_playlist, color: FColors.textWhite),
              title: const Text(
                'Add to Queue',
                style: TextStyle(
                  color: FColors.textWhite,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () {
                final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
                if (isMobile) {
                  SpotifyEmbedService.instance.addToQueue(track);
                } else {
                  WebPlaybackSDKService.instance.addToQueue(track);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${track.name} added to queue'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: FColors.primary,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.heart, color: FColors.textWhite),
              title: const Text(
                'Add to Favorites',
                style: TextStyle(
                  color: FColors.textWhite,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement add to favorites
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.add_circle, color: FColors.textWhite),
              title: const Text(
                'Add to Playlist',
                style: TextStyle(
                  color: FColors.textWhite,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement add to playlist
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

