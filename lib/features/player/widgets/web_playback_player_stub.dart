import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/features/player/widgets/native_spotify_player.dart';
import 'package:music_player/features/player/widgets/web_playback_player.dart';

/// Non-web implementation of WebPlaybackPlayerWeb.
/// Uses Native Spotify SDK on mobile (Android/iOS).
/// Uses InAppWebView-based Web Playback SDK on desktop (macOS/Windows/Linux).
class WebPlaybackPlayerWeb extends StatelessWidget {
  final String trackUri;
  final VoidCallback? onReady;

  const WebPlaybackPlayerWeb({
    super.key,
    required this.trackUri,
    this.onReady,
  });

  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    // Use native Spotify SDK on mobile for full playback support
    if (_isMobile) {
      return NativeSpotifyPlayer(
        key: key,
        trackUri: trackUri,
        onReady: onReady,
      );
    }
    
    // Use InAppWebView-based Web Playback SDK on desktop
    return WebPlaybackPlayer(
      key: key,
      trackUri: trackUri,
      onReady: onReady,
    );
  }
}
