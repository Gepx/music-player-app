import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_track.dart';
import 'package:music_player/data/services/playback/spotify_embed_service.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/features/player/widgets/queue_sheet.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/utils/formatters/number_formatter.dart';
import 'package:music_player/data/services/liked/liked_tracks_service.dart';
import 'package:music_player/data/services/playlist/playlist_service.dart';
import 'package:music_player/features/library/widgets/select_playlist_dialog.dart';

class NowPlayingPage extends StatefulWidget {
  final SpotifyTrack track;
  final List<SpotifyTrack>? playlist;

  const NowPlayingPage({
    super.key,
    required this.track,
    this.playlist,
  });

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  final SpotifyEmbedService _embedService = SpotifyEmbedService.instance;
  final WebPlaybackSDKService _webPlaybackService = WebPlaybackSDKService.instance;
  late bool _isMobilePlatform;
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  final LikedTracksService _likedService = LikedTracksService.instance;
  final PlaylistService _playlistService = PlaylistService.instance;
  String? _fetchedImageUrl;
  bool _imageFetchInFlight = false;
  Timer? _positionUpdateTimer;

  @override
  void initState() {
    super.initState();
    _checkPlatform();
    
    // Listen to service changes
    if (_isMobilePlatform) {
      _embedService.addListener(_onStateChanged);
    } else {
      _webPlaybackService.addListener(_onStateChanged);
    }
    
    // Only load track if it's different from what's currently playing
    // This prevents restarting playback when navigating from mini player
    final currentTrack = _isMobilePlatform 
        ? _embedService.currentTrack 
        : _webPlaybackService.currentTrack;
    
    if (currentTrack?.id != widget.track.id) {
      // Track is different, load it
      if (_isMobilePlatform) {
        _embedService.loadTrack(widget.track, playlist: widget.playlist);
      } else {
        _webPlaybackService.playTrack(widget.track, playlist: widget.playlist);
      }
    } else {
      // Same track is already playing - don't restart!
      // Just update the queue silently if playlist is provided and different
      if (widget.playlist != null && widget.playlist!.isNotEmpty) {
        final currentQueue = _isMobilePlatform 
            ? _embedService.queue 
            : _webPlaybackService.queue;
        
        // Only update if queue is different
        if (currentQueue.length != widget.playlist!.length ||
            !currentQueue.every((t) => widget.playlist!.any((p) => p.id == t.id))) {
          // Queue is different, update it (this will still restart, but it's a different queue)
          if (_isMobilePlatform) {
            _embedService.loadTrack(widget.track, playlist: widget.playlist);
          } else {
            _webPlaybackService.playTrack(widget.track, playlist: widget.playlist);
          }
        }
        // If queue is the same, do nothing - track continues playing
      }
      // If no playlist provided and track is same, do nothing - track continues playing
    }
    
    // Start position update timer
    _startPositionUpdateTimer();

    // Keep UI in sync with likes/playlists updates
    _likedService.addListener(_onStateChanged);
    _playlistService.addListener(_onStateChanged);

    // Ensure initial load so heart state is correct
    _likedService.loadLikedTracks();
    _playlistService.loadPlaylists();
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
    _positionUpdateTimer?.cancel();
    if (_isMobilePlatform) {
      _embedService.removeListener(_onStateChanged);
    } else {
      _webPlaybackService.removeListener(_onStateChanged);
    }
    _likedService.removeListener(_onStateChanged);
    _playlistService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _startPositionUpdateTimer() {
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _currentTrack != null) {
        if (!_isMobilePlatform) {
          // For web, position is updated by player_state_changed listener
          // Timer just triggers UI refresh
          setState(() {});
        } else if (_isMobilePlatform && _embedService.currentTrack != null) {
          // For mobile, we can't get real-time position, but we can still update UI
          setState(() {});
        }
      }
    });
  }

  void _onStateChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
      _maybeFetchImage();
    });
  }

  SpotifyTrack? get _currentTrack => _isMobilePlatform 
      ? _embedService.currentTrack 
      : _webPlaybackService.currentTrack;

  String? _getImageUrl() {
    final track = _currentTrack;
    if (track?.album?.images != null && track!.album!.images.isNotEmpty) {
      return track.album!.images.first.url;
    }
    return _fetchedImageUrl;
  }

  Future<void> _maybeFetchImage() async {
    final track = _currentTrack;
    if (track == null) return;
    if (track.album?.images.isNotEmpty == true) return;
    if (_fetchedImageUrl != null) return;
    if (_imageFetchInFlight) return;
    _imageFetchInFlight = true;
    try {
      final full = await _spotify.getTrack(track.id);
      if (full.album != null && full.album!.images.isNotEmpty && mounted) {
        setState(() {
          _fetchedImageUrl = full.album!.images.first.url;
        });
      }
    } catch (_) {}
    finally {
      _imageFetchInFlight = false;
    }
  }

  String _getArtistNames() {
    final track = _currentTrack;
    if (track == null) return '';
    return track.artists.map((artist) => artist.name).join(', ');
  }

  bool _getIsPlaying() {
    // For embed service (mobile), we can't access playing state from iframe
    // Always show as "playing" if there's a track
    return _isMobilePlatform
        ? (_embedService.currentTrack != null)
        : _webPlaybackService.isPlaying;
  }

  Duration _getCurrentPosition() {
    return _isMobilePlatform
        ? Duration.zero // Embed service doesn't provide position
        : _webPlaybackService.currentPosition;
  }

  Duration _getTotalDuration() {
    final track = _currentTrack;
    if (track == null) return Duration.zero;
    
    return _isMobilePlatform
        ? Duration(milliseconds: track.durationMs)
        : _webPlaybackService.totalDuration;
  }

  void _seekTo(Duration position) {
    if (!_isMobilePlatform) {
      _webPlaybackService.seekTo(position);
    }
  }

  void _showQueueSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const QueueSheet(),
    );
  }

  void _showTrackOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: FColors.darkContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildOptionsSheet(),
    );
  }

  Future<void> _toggleLikeCurrentTrack() async {
    final track = _currentTrack;
    if (track == null) return;
    try {
      await _likedService.toggleLike(track);
      if (!mounted) return;
      final isLiked = _likedService.isLiked(track.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLiked ? 'Added to Favorites' : 'Removed from Favorites',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: FColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update favorites: $e',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addCurrentTrackToPlaylist() async {
    final track = _currentTrack;
    if (track == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => SelectPlaylistDialog(track: track),
    );
  }

  Widget _buildOptionsSheet() {
    final track = _currentTrack;
    if (track == null) return const SizedBox();
    final isLiked = _likedService.isLiked(track.id);

    return SafeArea(
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
          
          // Track Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _getImageUrl() != null
                      ? Image.network(
                          _getImageUrl()!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: FColors.darkerGrey,
                          child: const Icon(Icons.music_note),
                        ),
                ),
                const SizedBox(width: 12),
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
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Options
          _buildOption(
            icon: isLiked ? Iconsax.heart : Iconsax.heart,
            title: isLiked ? 'Remove from Favorites' : 'Add to Favorites',
            onTap: () {
              Navigator.pop(context);
              _toggleLikeCurrentTrack();
            },
          ),
          _buildOption(
            icon: Iconsax.add_circle,
            title: 'Add to Playlist',
            onTap: () {
              Navigator.pop(context);
              _addCurrentTrackToPlaylist();
            },
          ),
          _buildOption(
            icon: Iconsax.user,
            title: 'Go to Artist',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to artist page
            },
          ),
          _buildOption(
            icon: Iconsax.music_dashboard,
            title: 'Go to Album',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to album page
            },
          ),
          _buildOption(
            icon: Iconsax.share,
            title: 'Share',
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement share
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: FColors.textWhite),
      title: Text(
        title,
        style: const TextStyle(
          color: FColors.textWhite,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final track = _currentTrack;
    if (track == null) {
      return Scaffold(
        backgroundColor: FColors.black,
        body: const Center(
          child: Text(
            'No track playing',
            style: TextStyle(color: FColors.textWhite),
          ),
        ),
      );
    }

    final imageUrl = _getImageUrl();
    // Ensure we try to fetch if missing once page builds
    if (imageUrl == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeFetchImage());
    }

    return Scaffold(
      backgroundColor: FColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Close now playing',
                    child: IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: FColors.textWhite,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Center title should flex and ellipsize to avoid overflow
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'PLAYING FROM',
                          style: TextStyle(
                            color: FColors.darkGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          track.album?.name ?? 'Track',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: FColors.textWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Track options',
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, color: FColors.textWhite),
                      onPressed: _showTrackOptions,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Album Art
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Hero(
                tag: 'hero-album-${track.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width - 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.width - 64,
                              color: FColors.darkerGrey,
                              child: const Icon(
                                Icons.music_note,
                                size: 100,
                                color: FColors.darkGrey,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width - 64,
                          color: FColors.darkerGrey,
                          child: const Icon(
                            Icons.music_note,
                            size: 100,
                            color: FColors.darkGrey,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Mobile embed playback is hosted globally (see SpotifyEmbedHost)
            // to avoid multiple hidden embeds stacking in the navigation stack.

            // Progress bar and time display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Builder(
                builder: (context) {
                  final currentPosition = _getCurrentPosition();
                  final totalDuration = _getTotalDuration();
                  final progress = totalDuration.inMilliseconds > 0
                      ? currentPosition.inMilliseconds / totalDuration.inMilliseconds
                      : 0.0;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                          activeTrackColor: FColors.primary,
                          inactiveTrackColor: FColors.darkerGrey,
                          thumbColor: FColors.primary,
                          overlayColor: FColors.primary.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChangeStart: !_isMobilePlatform
                              ? (value) {
                                  // Pause updates while dragging
                                  _positionUpdateTimer?.cancel();
                                }
                              : null,
                          onChanged: !_isMobilePlatform
                              ? (value) {
                                  final newPosition = Duration(
                                    milliseconds: (value * totalDuration.inMilliseconds).round(),
                                  );
                                  _seekTo(newPosition);
                                  // Update UI immediately while dragging
                                  setState(() {});
                                }
                              : null,
                          onChangeEnd: !_isMobilePlatform
                              ? (value) {
                                  // Resume updates after dragging
                                  _startPositionUpdateTimer();
                                }
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              FNumberFormatter.formatDurationFromDuration(currentPosition),
                              style: TextStyle(
                                color: FColors.textWhite.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                height: 1.0,
                              ),
                            ),
                            Text(
                              FNumberFormatter.formatDurationFromDuration(totalDuration),
                              style: TextStyle(
                                color: FColors.textWhite.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Track Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.name,
                              style: const TextStyle(
                                color: FColors.textWhite,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getArtistNames(),
                              style: TextStyle(
                                color: FColors.textWhite.withValues(alpha: 0.7),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: _likedService.isLiked(track.id)
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        child: IconButton(
                          icon: Icon(
                            _likedService.isLiked(track.id)
                                ? Icons.favorite
                                : Iconsax.heart,
                            color: _likedService.isLiked(track.id)
                                ? FColors.primary
                                : FColors.textWhite,
                          ),
                          iconSize: 28,
                          onPressed: () {
                            _toggleLikeCurrentTrack();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Playback Controls (Previous / Play-Pause / Next)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous
                      Semantics(
                        button: true,
                        label: 'Previous track',
                        child: IconButton(
                          icon: Icon(
                            Iconsax.previous,
                            color: (_isMobilePlatform
                                        ? _embedService.hasPrevious
                                        : _webPlaybackService.hasPrevious)
                                    ? FColors.textWhite
                                    : FColors.textWhite.withValues(alpha: 0.3),
                          ),
                          iconSize: 32,
                          onPressed: (_isMobilePlatform
                                      ? _embedService.hasPrevious
                                      : _webPlaybackService.hasPrevious)
                                  ? () {
                                      if (_isMobilePlatform) {
                                        _embedService.playPrevious();
                                      } else {
                                        _webPlaybackService.playPrevious();
                                      }
                                    }
                                  : null,
                        ),
                      ),

                      const SizedBox(width: 28),

                      // Play / Pause
                      Container(
                        decoration: BoxDecoration(
                          color: FColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: FColors.primary.withValues(alpha: 0.35),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Semantics(
                          button: true,
                          label: _getIsPlaying() ? 'Pause' : 'Play',
                          child: IconButton(
                            icon: Icon(
                              _getIsPlaying() ? Iconsax.pause : Iconsax.play,
                              color: Colors.white,
                            ),
                            iconSize: 36,
                            onPressed: () {
                              if (_isMobilePlatform) {
                                // For mobile, we can't control the embed iframe directly
                                // The embed player handles its own controls
                                // But we can still update the UI state
                                setState(() {});
                              } else {
                                _webPlaybackService.togglePlayPause();
                                setState(() {}); // Update UI immediately
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 28),

                      // Next
                      Semantics(
                        button: true,
                        label: 'Next track',
                        child: IconButton(
                          icon: Icon(
                            Iconsax.next,
                            color: (_isMobilePlatform
                                        ? _embedService.hasNext
                                        : _webPlaybackService.hasNext)
                                    ? FColors.textWhite
                                    : FColors.textWhite.withValues(alpha: 0.3),
                          ),
                          iconSize: 32,
                          onPressed: (_isMobilePlatform
                                      ? _embedService.hasNext
                                      : _webPlaybackService.hasNext)
                                  ? () {
                                      if (_isMobilePlatform) {
                                        _embedService.playNext();
                                      } else {
                                        _webPlaybackService.playNext();
                                      }
                                    }
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Queue Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showQueueSheet,
                      icon: const Icon(Iconsax.music_playlist),
                      label: Text(
                        'Queue (${_isMobilePlatform ? _embedService.queue.length : _webPlaybackService.queue.length})',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FColors.textWhite,
                        side: BorderSide(color: FColors.darkGrey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
            ),
          ),
        ),
      ),
    );
  }

}

