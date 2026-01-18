import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_track.dart';
import 'package:music_player/data/services/playback/spotify_embed_service.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/features/player/now_playing_page.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/utils/formatters/number_formatter.dart';
import 'package:music_player/data/services/liked/liked_tracks_service.dart';

/// Mini player that floats at the bottom of the screen
/// Appears when a song is playing
class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {
  late bool _isMobilePlatform;
  late final SpotifyEmbedService _embedService;
  late final WebPlaybackSDKService _webPlaybackService;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  final LikedTracksService _likedService = LikedTracksService.instance;
  final Map<String, String> _imageCache = {};
  final Set<String> _imageFetchInFlight = <String>{};
  Timer? _positionUpdateTimer;

  @override
  void initState() {
    super.initState();
    _checkPlatform();
    
    _embedService = SpotifyEmbedService.instance;
    _webPlaybackService = WebPlaybackSDKService.instance;
    
    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 120.0, // Increased to accommodate all content without overflow
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Listen to both services
    _embedService.addListener(_onStateChanged);
    _webPlaybackService.addListener(_onStateChanged);
    _likedService.addListener(_onStateChanged);
    
    // Show if there's already a track
    if (_getCurrentTrack() != null) {
      _animationController.forward();
    }
    
    // Start position update timer for dynamic time updates
    _startPositionUpdateTimer();

    // Ensure likes are loaded so the heart state is correct
    _likedService.loadLikedTracks();
  }
  
  void _startPositionUpdateTimer() {
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _getCurrentTrack() != null) {
        // Always update UI to reflect position changes from player_state_changed listener
        // Position updates come from the Web Playback SDK's player_state_changed event
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
    _embedService.removeListener(_onStateChanged);
    _webPlaybackService.removeListener(_onStateChanged);
    _likedService.removeListener(_onStateChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final track = _getCurrentTrack();
    if (track != null && !_animationController.isCompleted) {
      _animationController.forward();
      _startPositionUpdateTimer(); // Restart timer when track starts
    } else if (track == null && _animationController.isCompleted) {
      _animationController.reverse();
      _positionUpdateTimer?.cancel(); // Stop timer when no track
    }
    if (mounted) {
      // Defer setState to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
          // Try to fetch album image if missing
          _ensureImage(track);
        }
      });
    }
  }

  SpotifyTrack? _getCurrentTrack() {
    return _isMobilePlatform
        ? _embedService.currentTrack
        : _webPlaybackService.currentTrack;
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
    final track = _getCurrentTrack();
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

  void _togglePlayPause() {
    if (_isMobilePlatform) {
      // For mobile embed player, we can't control the iframe directly
      // But we can still toggle by opening/closing the Now Playing page
      // However, since user wants it to work directly, we'll just open the page
      // where they can control playback
      _openNowPlayingPage();
    } else {
      _webPlaybackService.togglePlayPause();
      setState(() {}); // Update UI immediately
    }
  }

  void _playNext() {
    if (_isMobilePlatform) {
      _embedService.playNext();
    } else {
      _webPlaybackService.playNext();
    }
  }

  void _playPrevious() {
    if (_isMobilePlatform) {
      _embedService.playPrevious();
    } else {
      _webPlaybackService.playPrevious();
    }
  }

  void _openNowPlayingPage() {
    final track = _getCurrentTrack();
    if (track != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NowPlayingPage(
            track: track,
            playlist: _isMobilePlatform
                ? _embedService.queue
                : _webPlaybackService.queue,
          ),
        ),
      );
    }
  }

  Future<void> _toggleLikeCurrentTrack() async {
    final track = _getCurrentTrack();
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

  @override
  Widget build(BuildContext context) {
    final track = _getCurrentTrack();
    if (track == null) {
      return const SizedBox.shrink();
    }

    final isPlaying = _getIsPlaying();
    final isLiked = _likedService.isLiked(track.id);
    final imageUrl = track.album?.images.isNotEmpty == true
        ? track.album!.images.first.url
        : (_imageCache[track.id]);

    if (imageUrl == null) {
      // Fire and forget fetch
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureImage(track));
    }

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        if (_heightAnimation.value <= 0) {
          return const SizedBox.shrink();
        }
        final maxHeight = _heightAnimation.value;
        // Slide up as it expands (CP4a animation requirement).
        return Transform.translate(
          offset: Offset(0, 120.0 - maxHeight),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              minHeight: 0,
            ),
            child: SizedBox(
              height: maxHeight,
              child: ClipRect(
                child: child,
              ),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: _openNowPlayingPage,
        child: Semantics(
          container: true,
          button: true,
          label: 'Mini player. Now playing ${track.name} by ${track.artists.map((a) => a.name).join(', ')}.',
          child: Container(
          decoration: const BoxDecoration(
            color: FColors.darkContainer,
            border: Border(
              top: BorderSide(color: FColors.darkerGrey, width: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main row with album art, info, and controls
                Row(
                  children: [
                    // Album art
                    Hero(
                      tag: 'hero-album-${track.id}',
                      child: imageUrl != null
                          ? Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [FColors.primary, FColors.secondary],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Iconsax.music,
                                  color: FColors.textWhite,
                                  size: 22,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),

                    // Track info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            track.name,
                            style: const TextStyle(
                              color: FColors.textWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artists.map((a) => a.name).join(', '),
                            style: const TextStyle(
                              color: FColors.darkGrey,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          button: true,
                          label: isLiked ? 'Remove from favorites' : 'Add to favorites',
                          child: IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Iconsax.heart,
                              size: 18,
                            ),
                            color: isLiked ? FColors.primary : FColors.textWhite,
                            onPressed: _toggleLikeCurrentTrack,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Previous track',
                          child: IconButton(
                            icon: const Icon(Iconsax.previous, size: 18),
                            color: FColors.textWhite,
                            onPressed: _playPrevious,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: isPlaying ? 'Pause' : 'Play',
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Iconsax.pause : Iconsax.play,
                              size: 22,
                            ),
                            color: FColors.primary,
                            onPressed: _togglePlayPause,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Next track',
                          child: IconButton(
                            icon: const Icon(Iconsax.next, size: 18),
                            color: FColors.textWhite,
                            onPressed: _playNext,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Progress bar and time
                Builder(
                  builder: (context) {
                    final currentPosition = _getCurrentPosition();
                    final totalDuration = _getTotalDuration();
                    final progress = totalDuration.inMilliseconds > 0
                        ? currentPosition.inMilliseconds / totalDuration.inMilliseconds
                        : 0.0;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 8.0),
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
                          padding: const EdgeInsets.only(top: 1.0, left: 4.0, right: 4.0, bottom: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                FNumberFormatter.formatDurationFromDuration(currentPosition),
                                style: TextStyle(
                                  color: FColors.textWhite.withValues(alpha: 0.6),
                                  fontSize: 10,
                                  fontFamily: 'Poppins',
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                FNumberFormatter.formatDurationFromDuration(totalDuration),
                                style: TextStyle(
                                  color: FColors.textWhite.withValues(alpha: 0.6),
                                  fontSize: 10,
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
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Future<void> _ensureImage(SpotifyTrack? track) async {
    if (track == null) return;
    if (_imageCache.containsKey(track.id)) return;
    if (track.album?.images.isNotEmpty == true) return;
    if (_imageFetchInFlight.contains(track.id)) return;
    _imageFetchInFlight.add(track.id);
    try {
      final full = await _spotify.getTrack(track.id);
      if (full.album != null && full.album!.images.isNotEmpty) {
        _imageCache[track.id] = full.album!.images.first.url;
        if (mounted) setState(() {});
      }
    } catch (_) {}
    finally {
      _imageFetchInFlight.remove(track.id);
    }
  }
}
