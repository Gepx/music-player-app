import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_album.dart';
import 'package:music_player/data/models/spotify/spotify_track.dart';
import 'package:music_player/data/models/dto/paging_dto.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/data/services/playback/spotify_embed_service.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/features/home/widget/mini_player.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AlbumDetailPage extends StatefulWidget {
  final SpotifyAlbum album;

  const AlbumDetailPage({
    super.key,
    required this.album,
  });

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  final SpotifyApiService _spotifyApi = SpotifyApiService.instance;
  List<SpotifyTrack>? _tracks;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAlbumTracks();
  }

  Future<void> _loadAlbumTracks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final PagingDto<SpotifyTrack> result = await _spotifyApi.getAlbumTracks(
        widget.album.id,
        limit: 50,
      );

      setState(() {
        _tracks = result.items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading album tracks: $e');
      setState(() {
        _errorMessage = 'Failed to load album tracks';
        _isLoading = false;
      });
    }
  }

  String? _getImageUrl() {
    if (widget.album.images.isNotEmpty) {
      return widget.album.images.first.url;
    }
    return null;
  }

  String _getArtistNames() {
    return widget.album.artists.map((artist) => artist.name).join(', ');
  }

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _getTotalDuration() {
    if (_tracks == null) return '';
    final totalMs = _tracks!.fold<int>(0, (sum, track) => sum + track.durationMs);
    final duration = Duration(milliseconds: totalMs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();

    return Scaffold(
      backgroundColor: FColors.black,
      body: CustomScrollView(
        slivers: [
          // Hero Header with Album Art
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: FColors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: FColors.textWhite),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Album Art with Gradient
                  if (imageUrl != null)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: FColors.darkerGrey,
                          child: const Icon(
                            Icons.album,
                            size: 100,
                            color: FColors.darkGrey,
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: FColors.darkerGrey,
                      child: const Icon(
                        Icons.album,
                        size: 100,
                        color: FColors.darkGrey,
                      ),
                    ),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          FColors.black.withValues(alpha: 0.7),
                          FColors.black,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                  
                  // Album Info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: FColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.album.albumType.toUpperCase(),
                            style: const TextStyle(
                              color: FColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.album.name,
                          style: const TextStyle(
                            color: FColors.textWhite,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getArtistNames(),
                          style: TextStyle(
                            color: FColors.textWhite.withValues(alpha: 0.8),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.album.releaseDate.split('-').first} • ${widget.album.totalTracks} tracks',
                          style: TextStyle(
                            color: FColors.textWhite.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Play Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _tracks != null && _tracks!.isNotEmpty
                          ? () {
                              final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
                              if (isMobile) {
                                SpotifyEmbedService.instance.loadTrack(
                                  _tracks!.first,
                                  playlist: _tracks,
                                );
                              } else {
                                WebPlaybackSDKService.instance.playTrack(
                                  _tracks!.first,
                                  playlist: _tracks,
                                );
                              }
                            }
                          : null,
                      icon: const Icon(Iconsax.play_circle, size: 24),
                      label: const Text(
                        'Play',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FColors.primary,
                        foregroundColor: FColors.textWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Favorite Button
                  Container(
                    decoration: BoxDecoration(
                      color: FColors.darkContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        debugPrint('Favorite album: ${widget.album.name}');
                      },
                      icon: const Icon(Iconsax.heart),
                      color: FColors.textWhite,
                      iconSize: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // More Options Button
                  Container(
                    decoration: BoxDecoration(
                      color: FColors.darkContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        debugPrint('More options: ${widget.album.name}');
                      },
                      icon: const Icon(Icons.more_vert),
                      color: FColors.textWhite,
                      iconSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: FColors.primary),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: FColors.textWhite,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadAlbumTracks,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FColors.primary,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Track Count and Duration
                          if (_tracks != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                _getTotalDuration(),
                                style: TextStyle(
                                  color: FColors.textWhite.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Tracks List
                          if (_tracks != null)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _tracks!.length,
                              itemBuilder: (context, index) {
                                final track = _tracks![index];
                                return _buildTrackItem(track, index + 1);
                              },
                            ),
                          const SizedBox(height: 32),
                        ],
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _buildTrackItem(SpotifyTrack track, int trackNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: FColors.darkContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
            if (isMobile) {
              SpotifyEmbedService.instance.loadTrack(
                track,
                playlist: _tracks,
              );
            } else {
              WebPlaybackSDKService.instance.playTrack(
                track,
                playlist: _tracks,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Track Number
                SizedBox(
                  width: 30,
                  child: Text(
                    '$trackNumber',
                    style: TextStyle(
                      color: FColors.textWhite.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                      Text(
                        track.artists.map((a) => a.name).join(', '),
                        style: TextStyle(
                          color: FColors.textWhite.withValues(alpha: 0.6),
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
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

