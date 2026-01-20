import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/features/player/widgets/web_playback_player_factory.dart';

/// Keeps a single Web Playback SDK instance mounted for the whole app.
/// This prevents controls from breaking when the NowPlaying page is closed.
class WebPlaybackHost extends StatefulWidget {
  const WebPlaybackHost({super.key});

  @override
  State<WebPlaybackHost> createState() => _WebPlaybackHostState();
}

class _WebPlaybackHostState extends State<WebPlaybackHost> {
  final WebPlaybackSDKService _sdk = WebPlaybackSDKService.instance;

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
    _debugLog('web_playback_host.dart:initState', 'WebPlaybackHost initState called', {}, 'A');
    // #endregion
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
    final track = _sdk.currentTrack;
    // #region agent log
    _debugLog('web_playback_host.dart:build', 'WebPlaybackHost build', {'trackIsNull': track == null, 'trackId': track?.id}, 'A');
    // #endregion
    if (track == null) return const SizedBox.shrink();

    // Keep the player mounted but visually unobtrusive
    return Offstage(
      offstage: false,
      child: SizedBox(
        height: 1,
        width: 1,
        child: WebPlaybackPlayerFactory(
          trackUri: 'spotify:track:${track.id}',
        ),
      ),
    );
  }
}


