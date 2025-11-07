import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'web_playback_player_web.dart';

/// Factory widget that selects the appropriate Web Playback Player
/// based on the platform
class WebPlaybackPlayerFactory extends StatelessWidget {
  final String trackUri;
  final VoidCallback? onReady;

  const WebPlaybackPlayerFactory({
    super.key,
    required this.trackUri,
    this.onReady,
  });

  @override
  Widget build(BuildContext context) {
    // On web platform, use the web-specific implementation
    if (kIsWeb) {
      return WebPlaybackPlayerWeb(
        key: key,
        trackUri: trackUri,
        onReady: onReady,
      );
    }
    
    // On other platforms, this shouldn't be called
    // (mobile uses SpotifyEmbedPlayer instead)
    return const Center(
      child: Text('Web Playback SDK is only available on web platform'),
    );
  }
}

