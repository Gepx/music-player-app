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
  final Map<String, String> _imageCache = {};

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
      end: 108.0, // Increased to accommodate progress bar and time without overflow
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Listen to both services
    _embedService.addListener(_onStateChanged);
    _webPlaybackService.addListener(_onStateChanged);
    
    // Show if there's already a track
    if (_getCurrentTrack() != null) {
      _animationController.forward();
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
    _embedService.removeListener(_onStateChanged);
    _webPlaybackService.removeListener(_onStateChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final track = _getCurrentTrack();
    if (track != null && !_animationController.isCompleted) {
      _animationController.forward();
    } else if (track == null && _animationController.isCompleted) {
      _animationController.reverse();
    }
    if (mounted) {
      setState(() {});
      // Try to fetch album image if missing
      _ensureImage(track);
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
      // For mobile embed player, open the full Now Playing page
      // since we can't control the iframe directly
      _openNowPlayingPage();
    } else {
      _webPlaybackService.togglePlayPause();
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

  @override
  Widget build(BuildContext context) {
    final track = _getCurrentTrack();
    if (track == null) {
      return const SizedBox.shrink();
    }

    final isPlaying = _getIsPlaying();
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
        return SizedBox(
          height: _heightAnimation.value,
          child: _heightAnimation.value > 0 ? child : null,
        );
      },
      child: GestureDetector(
        onTap: _openNowPlayingPage,
        child: Container(
          decoration: const BoxDecoration(
            color: FColors.darkContainer,
            border: Border(
              top: BorderSide(color: FColors.darkerGrey, width: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main row with album art, info, and controls
                Row(
                  children: [
                    // Album art
                    if (imageUrl != null)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [FColors.primary, FColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(Iconsax.music, color: FColors.textWhite, size: 24),
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
                        IconButton(
                          icon: const Icon(Iconsax.previous, size: 20),
                          color: FColors.textWhite,
                          onPressed: _playPrevious,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isPlaying ? Iconsax.pause : Iconsax.play,
                            size: 24,
                          ),
                          color: FColors.primary,
                          onPressed: _togglePlayPause,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.next, size: 20),
                          color: FColors.textWhite,
                          onPressed: _playNext,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
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
                        const SizedBox(height: 5),
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
                            onChanged: !_isMobilePlatform
                                ? (value) {
                                    final newPosition = Duration(
                                      milliseconds: (value * totalDuration.inMilliseconds).round(),
                                    );
                                    _seekTo(newPosition);
                                  }
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, left: 4.0, right: 4.0),
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
    );
  }

  Future<void> _ensureImage(SpotifyTrack? track) async {
    if (track == null) return;
    if (_imageCache.containsKey(track.id)) return;
    if (track.album?.images.isNotEmpty == true) return;
    try {
      final full = await _spotify.getTrack(track.id);
      if (full.album != null && full.album!.images.isNotEmpty) {
        _imageCache[track.id] = full.album!.images.first.url;
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }
}
