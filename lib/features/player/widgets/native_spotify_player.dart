import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/data/services/spotify/spotify_premium_auth_service.dart';

/// Native Spotify SDK player for mobile platforms (Android/iOS)
class NativeSpotifyPlayer extends StatefulWidget {
  final String trackUri;
  final VoidCallback? onReady;

  const NativeSpotifyPlayer({
    super.key,
    required this.trackUri,
    this.onReady,
  });

  @override
  State<NativeSpotifyPlayer> createState() => _NativeSpotifyPlayerState();
}

class _NativeSpotifyPlayerState extends State<NativeSpotifyPlayer> {
  final WebPlaybackSDKService _sdkService = WebPlaybackSDKService.instance;
  StreamSubscription? _playerStateSubscription;

  // #region agent log
  void _debugLog(String loc, String msg, Map<String, dynamic> data, String hypId) {
    final payload = {'location': loc, 'message': msg, 'data': data, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'sessionId': 'debug-session', 'hypothesisId': hypId};
    try { File('/Users/vin/Code/music-player-app/.cursor/debug.log').writeAsStringSync('${payload.toString().replaceAll("'", '"')}\n', mode: FileMode.append); } catch (_) {}
  }
  // #endregion

  @override
  void initState() {
    super.initState();
    // #region agent log
    _debugLog('native_spotify_player.dart:initState', 'NativeSpotifyPlayer init', {'trackUri': widget.trackUri}, 'SDK');
    // #endregion
    _connectToSpotify();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _connectToSpotify() async {
    try {
      // #region agent log
      _debugLog('native_spotify_player.dart:_connectToSpotify', 'Attempting to connect to Spotify', {}, 'SDK');
      // #endregion

      final clientId = SpotifyPremiumAuthService.instance.clientId;
      final redirectUri = SpotifyPremiumAuthService.instance.redirectUri;

      if (clientId == null || redirectUri == null) {
        // #region agent log
        _debugLog('native_spotify_player.dart:_connectToSpotify', 'Missing clientId or redirectUri', {'hasClientId': clientId != null, 'hasRedirectUri': redirectUri != null}, 'SDK');
        // #endregion
        debugPrint('❌ Spotify credentials not configured');
        return;
      }

      debugPrint('🎵 Connecting to Spotify with clientId: ${clientId.substring(0, 8)}...');

      final result = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUri,
      );

      // #region agent log
      _debugLog('native_spotify_player.dart:_connectToSpotify', 'Connection result', {'connected': result}, 'SDK');
      // #endregion

      if (result) {
        debugPrint('✅ Connected to Spotify');
        
        // Set up player controls
        _setupPlayerControls();
        
        // Listen to player state changes
        _listenToPlayerState();
        
        // Notify ready
        widget.onReady?.call();
        _sdkService.setDeviceId('native-spotify-sdk');
      } else {
        debugPrint('❌ Failed to connect to Spotify');
      }
    } catch (e) {
      // #region agent log
      _debugLog('native_spotify_player.dart:_connectToSpotify', 'Connection error', {'error': e.toString()}, 'SDK');
      // #endregion
      debugPrint('❌ Spotify connection error: $e');
    }
  }

  void _setupPlayerControls() {
    _sdkService.setPlayerControls(
      onTogglePlayPause: () async {
        try {
          final state = await SpotifySdk.getPlayerState();
          if (state?.isPaused ?? true) {
            await SpotifySdk.resume();
          } else {
            await SpotifySdk.pause();
          }
        } catch (e) {
          debugPrint('❌ Toggle play/pause error: $e');
        }
      },
      onPause: () async {
        try {
          await SpotifySdk.pause();
        } catch (e) {
          debugPrint('❌ Pause error: $e');
        }
      },
      onResume: () async {
        try {
          await SpotifySdk.resume();
        } catch (e) {
          debugPrint('❌ Resume error: $e');
        }
      },
      onPlayNext: () async {
        try {
          await SpotifySdk.skipNext();
        } catch (e) {
          debugPrint('❌ Skip next error: $e');
        }
      },
      onPlayPrevious: () async {
        try {
          await SpotifySdk.skipPrevious();
        } catch (e) {
          debugPrint('❌ Skip previous error: $e');
        }
      },
      onPlayUri: (uri) async {
        try {
          // #region agent log
          _debugLog('native_spotify_player.dart:onPlayUri', 'Playing track', {'uri': uri}, 'SDK');
          // #endregion
          await SpotifySdk.play(spotifyUri: uri);
        } catch (e) {
          debugPrint('❌ Play URI error: $e');
        }
      },
      onSeek: (positionMs) async {
        try {
          await SpotifySdk.seekTo(positionedMilliseconds: positionMs);
        } catch (e) {
          debugPrint('❌ Seek error: $e');
        }
      },
    );
  }

  void _listenToPlayerState() {
    _playerStateSubscription = SpotifySdk.subscribePlayerState().listen(
      (playerState) {
        if (playerState.track != null) {
          _sdkService.updatePosition(
            Duration(milliseconds: playerState.playbackPosition),
          );
          _sdkService.updatePlayingState(!playerState.isPaused);
          
          // Update duration if available
          if (playerState.track?.duration != null) {
            _sdkService.updateTotalDuration(
              Duration(milliseconds: playerState.track!.duration),
            );
          }
        }
      },
      onError: (e) {
        debugPrint('❌ Player state stream error: $e');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget doesn't render anything visible
    // It just manages the native Spotify SDK connection
    return const SizedBox.shrink();
  }
}
