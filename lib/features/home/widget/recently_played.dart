import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/data/services/music/recent_plays_service.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/data/services/playback/spotify_embed_service.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:music_player/features/home/widget/section_title.dart';

class RecentlyPlayedGrid extends StatefulWidget {
  const RecentlyPlayedGrid({super.key});

  @override
  State<RecentlyPlayedGrid> createState() => _RecentlyPlayedGridState();
}

class _RecentlyPlayedGridState extends State<RecentlyPlayedGrid> {
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  late final SpotifyApiService _spotify;
  late final SpotifyEmbedService _embed;
  late final WebPlaybackSDKService _web;
  late final bool _isMobilePlatform;

  @override
  void initState() {
    super.initState();
    _spotify = SpotifyApiService.instance;
    _embed = SpotifyEmbedService.instance;
    _web = WebPlaybackSDKService.instance;
    _isMobilePlatform = kIsWeb ? false : (Platform.isAndroid || Platform.isIOS);
    _load();
    // Refresh when playback changes (new song played)
    _embed.addListener(_onPlaybackChange);
    _web.addListener(_onPlaybackChange);
  }

  Future<void> _load() async {
    final rows = await RecentPlaysService.instance.getRecent(limit: 8);
    if (!mounted) return;
    setState(() {
      _items = rows;
      _loading = false;
    });
  }

  void _onPlaybackChange() {
    // Requery recent plays after frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _embed.removeListener(_onPlaybackChange);
    _web.removeListener(_onPlaybackChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Do not render at all when loading or empty
    if (_loading || _items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Recently Played'),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _items.length,
            itemBuilder: (context, index) {
        final item = _items[index];
        final title = item['name'] as String? ?? '';
        final subtitle = item['artist'] as String? ?? '';
        final imageUrl = item['imageUrl'] as String?;

        return GestureDetector(
          onTap: () async {
            final trackId = item['id'] as String?;
            if (trackId == null) return;
            try {
              final track = await _spotify.getTrack(trackId);
              if (_isMobilePlatform) {
                _embed.loadTrack(track, playlist: [track]);
              } else {
                await _web.playTrack(track, playlist: [track]);
              }
              await RecentPlaysService.instance.addRecent(track);
              if (mounted) _load();
            } catch (_) {}
          },
          child: Container(
          width: 160,
          margin: EdgeInsets.only(right: index == _items.length - 1 ? 0 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: imageUrl == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [FColors.primary, FColors.secondary.withOpacity(0.8)],
                  )
                : null,
            image: imageUrl != null
                ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, FColors.black.withValues(alpha: 0.6)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: FColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: FColors.textWhite.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
            },
          ),
        ),
      ],
    );
  }
}
