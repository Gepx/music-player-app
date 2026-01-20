import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/data/models/spotify/spotify_search_result.dart';
import 'package:music_player/data/services/spotify/spotify_cache_service.dart';
import 'package:music_player/features/album/album_detail_page.dart';
import 'package:music_player/features/artist/artist_detail_page.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';

class RecentSearches extends StatefulWidget {
  const RecentSearches({super.key});

  @override
  State<RecentSearches> createState() => _RecentSearchesState();
}

class _RecentSearchesState extends State<RecentSearches> {
  final SpotifyCacheService _cache = SpotifyCacheService.instance;
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  final WebPlaybackSDKService _web = WebPlaybackSDKService.instance;
  List<String> _queries = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _cache.getSearchHistory(limit: 10);
    if (!mounted) return;
    setState(() => _queries = list);
  }

  Future<void> _playFromQuery(String query) async {
    try {
      final result = await _spotify.search(query: query, type: SpotifySearchType.all, limit: 5);
      // Prefer tracks; else go to album; else artist page
      if ((result.tracks?.items.isNotEmpty ?? false)) {
        final track = result.tracks!.items.first;
        await _web.playTrack(track, playlist: [track]);
        return;
      }
      if ((result.albums?.items.isNotEmpty ?? false)) {
        final album = result.albums!.items.first;
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlbumDetailPage(album: album)),
        );
        return;
      }
      if ((result.artists?.items.isNotEmpty ?? false)) {
        final artist = result.artists!.items.first;
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArtistDetailPage(artist: artist)),
        );
        return;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_queries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent searches',
          style: TextStyle(
            color: FColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        ..._queries.map((q) => _buildRecentSearchItem(q)),
      ],
    );
  }

  Widget _buildRecentSearchItem(String title) {
    return InkWell(
      onTap: () => _playFromQuery(title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: FColors.linearGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Iconsax.music,
                color: FColors.textWhite,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: FColors.textWhite,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                await _cache.removeSearchQuery(title);
                if (mounted) _load();
              },
              icon: Icon(
                Iconsax.close_circle,
                color: FColors.textWhite.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
