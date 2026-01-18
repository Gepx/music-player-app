import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/data/services/playback/spotify_embed_service.dart';
import 'package:music_player/features/player/widgets/spotify_embed_player.dart';

/// Keeps a single Spotify Embed WebView mounted for the whole app (mobile).
/// This prevents multiple hidden embeds from stacking when pushing NowPlayingPage.
class SpotifyEmbedHost extends StatefulWidget {
  const SpotifyEmbedHost({super.key});

  @override
  State<SpotifyEmbedHost> createState() => _SpotifyEmbedHostState();
}

class _SpotifyEmbedHostState extends State<SpotifyEmbedHost> {
  final SpotifyEmbedService _embed = SpotifyEmbedService.instance;
  late final bool _isMobile;

  @override
  void initState() {
    super.initState();
    _isMobile = kIsWeb ? false : (Platform.isAndroid || Platform.isIOS);
    _embed.addListener(_onChanged);
  }

  @override
  void dispose() {
    _embed.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMobile) return const SizedBox.shrink();

    final track = _embed.currentTrack;
    if (track == null) return const SizedBox.shrink();

    // Keep mounted but visually hidden.
    return Offstage(
      offstage: false,
      child: SizedBox(
        width: 1,
        height: 1,
        child: SpotifyEmbedPlayer(
          key: ValueKey(track.id),
          trackId: track.id,
        ),
      ),
    );
  }
}

