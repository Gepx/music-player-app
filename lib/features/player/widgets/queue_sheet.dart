import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_track.dart';
import 'package:music_player/data/services/playback/spotify_embed_service.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class QueueSheet extends StatefulWidget {
  const QueueSheet({super.key});

  @override
  State<QueueSheet> createState() => _QueueSheetState();
}

class _QueueSheetState extends State<QueueSheet> {
  final SpotifyEmbedService _embedService = SpotifyEmbedService.instance;
  final WebPlaybackSDKService _webPlaybackService = WebPlaybackSDKService.instance;
  late bool _isMobilePlatform;

  @override
  void initState() {
    super.initState();
    _checkPlatform();
    if (_isMobilePlatform) {
      _embedService.addListener(_onStateChanged);
    } else {
      _webPlaybackService.addListener(_onStateChanged);
    }
  }

  void _checkPlatform() {
    if (kIsWeb) {
      _isMobilePlatform = false;
    } else {
      _isMobilePlatform = Platform.isAndroid || Platform.isIOS;
    }
  }

  @override
  void dispose() {
    if (_isMobilePlatform) {
      _embedService.removeListener(_onStateChanged);
    } else {
      _webPlaybackService.removeListener(_onStateChanged);
    }
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _getArtistNames(SpotifyTrack track) {
    return track.artists.map((artist) => artist.name).join(', ');
  }

  String? _getImageUrl(SpotifyTrack track) {
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
    final queue = _isMobilePlatform ? _embedService.queue : _webPlaybackService.queue;
    final currentIndex = _isMobilePlatform ? _embedService.currentIndex : _webPlaybackService.currentIndex;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: FColors.darkContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Queue',
                  style: TextStyle(
                    color: FColors.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                Row(
                  children: [
                    // IconButton(
                    //   icon: const Icon(Iconsax.shuffle, color: FColors.textWhite),
                    //   onPressed: () {
                    //     // Shuffle not available with embed player
                    //   },
                    // ),
                    IconButton(
                      icon: const Icon(Iconsax.trash, color: FColors.textWhite),
                      onPressed: queue.length > 1
                          ? () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: FColors.darkContainer,
                                  title: const Text(
                                    'Clear Queue?',
                                    style: TextStyle(
                                      color: FColors.textWhite,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  content: const Text(
                                    'This will remove all tracks except the currently playing track.',
                                    style: TextStyle(
                                      color: FColors.textWhite,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: FColors.darkGrey),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (_isMobilePlatform) {
                                          _embedService.clearQueue();
                                        } else {
                                          _webPlaybackService.clearQueue();
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Clear',
                                        style: TextStyle(color: FColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Queue Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Text(
                  '${queue.length} track${queue.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: FColors.textWhite.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Queue List
          Expanded(
            child: queue.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.music_playlist,
                          size: 64,
                          color: FColors.textWhite.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Queue is empty',
                          style: TextStyle(
                            color: FColors.textWhite.withValues(alpha: 0.6),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: queue.length,
                    onReorder: (oldIndex, newIndex) {
                      // Handle reordering
                      // TODO: Implement queue reordering in PlaybackService
                    },
                    itemBuilder: (context, index) {
                      final track = queue[index];
                      final isCurrentTrack = index == currentIndex;
                      final imageUrl = _getImageUrl(track);

                      return _buildQueueItem(
                        key: ValueKey(track.id + index.toString()),
                        track: track,
                        index: index,
                        isCurrentTrack: isCurrentTrack,
                        imageUrl: imageUrl,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem({
    required Key key,
    required SpotifyTrack track,
    required int index,
    required bool isCurrentTrack,
    required String? imageUrl,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentTrack
            ? FColors.primary.withValues(alpha: 0.2)
            : FColors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTrack
            ? Border.all(color: FColors.primary, width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Play/load this track
            if (_isMobilePlatform) {
              _embedService.loadTrack(track, playlist: _embedService.queue);
            } else {
              _webPlaybackService.playTrack(track, playlist: _webPlaybackService.queue);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Album Art
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child:
                          imageUrl != null
                              ? Image.network(
                                imageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder();
                                },
                              )
                              : _buildPlaceholder(),
                    ),
                    if (isCurrentTrack)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: FColors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Iconsax.play,
                            color: FColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Track Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.name,
                        style: TextStyle(
                          color: isCurrentTrack ? FColors.primary : FColors.textWhite,
                          fontSize: 15,
                          fontWeight: isCurrentTrack ? FontWeight.w600 : FontWeight.normal,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getArtistNames(track),
                        style: TextStyle(
                          color: FColors.textWhite.withValues(alpha: 0.6),
                          fontSize: 13,
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
                    color: FColors.textWhite.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 8),

                // Remove Button (not for current track)
                if (!isCurrentTrack)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        color: FColors.textWhite.withValues(alpha: 0.5),
                        size: 20,
                      ),
                      onPressed: () {
                        if (_isMobilePlatform) {
                          _embedService.removeFromQueue(index);
                        } else {
                          _webPlaybackService.removeFromQueue(index);
                        }
                      },
                    ),
                  )
                else
                  const SizedBox(width: 52), // Spacing for alignment (40 + 12 for drag handle)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: FColors.darkerGrey,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.music_note,
        color: FColors.darkGrey,
        size: 24,
      ),
    );
  }
}

