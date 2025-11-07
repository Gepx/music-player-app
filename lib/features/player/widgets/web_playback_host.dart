import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/features/player/widgets/web_playback_player_factory.dart';

/// Keeps a single Web Playback SDK instance mounted for the whole app (web/desktop).
/// This prevents controls from breaking when the NowPlaying page is closed.
class WebPlaybackHost extends StatefulWidget {
  const WebPlaybackHost({super.key});

  @override
  State<WebPlaybackHost> createState() => _WebPlaybackHostState();
}

class _WebPlaybackHostState extends State<WebPlaybackHost> {
  final WebPlaybackSDKService _sdk = WebPlaybackSDKService.instance;

  @override
  void initState() {
    super.initState();
    _sdk.addListener(_onChanged);
  }

  @override
  void dispose() {
    _sdk.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    // Avoid setState during build by scheduling after this frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    final track = _sdk.currentTrack;
    if (track == null) return const SizedBox.shrink();

    // Keep the player mounted but visually unobtrusive
    // Use key to force rebuild when track changes (important for hot reload)
    return Offstage(
      offstage: false,
      child: SizedBox(
        height: 0,
        width: 0,
        child: WebPlaybackPlayerFactory(
          key: ValueKey('player_${track.id}'), // Force rebuild on track change
          trackUri: 'spotify:track:${track.id}',
        ),
      ),
    );
  }
}


