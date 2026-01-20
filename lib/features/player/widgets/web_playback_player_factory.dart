import 'package:flutter/material.dart';
import 'web_playback_player_stub.dart'
    if (dart.library.html) 'web_playback_player_web.dart';

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
    return WebPlaybackPlayerWeb(
      key: key,
      trackUri: trackUri,
      onReady: onReady,
    );
  }
}

