import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_search_result.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'track_item.dart';
import 'album_item.dart';
import 'artist_item.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    super.key,
    required this.searchResult,
  });

  final SpotifySearchResult searchResult;

  @override
  Widget build(BuildContext context) {
    final tracks = searchResult.tracks?.items ?? [];
    final albums = searchResult.albums?.items ?? [];
    final artists = searchResult.artists?.items ?? [];

    if (tracks.isEmpty && albums.isEmpty && artists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: FColors.textWhite.withValues(alpha: 0.54),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                color: FColors.textWhite.withValues(alpha: 0.54),
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Artists Section
        if (artists.isNotEmpty) ...[
          const Text(
            'Artists',
            style: TextStyle(
              color: FColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          ...artists.map((artist) => ArtistItem(artist: artist)),
          const SizedBox(height: 24),
        ],

        // Tracks Section
        if (tracks.isNotEmpty) ...[
          const Text(
            'Songs',
            style: TextStyle(
              color: FColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          ...tracks.map((track) => TrackItem(track: track)),
          const SizedBox(height: 24),
        ],

        // Albums Section
        if (albums.isNotEmpty) ...[
          const Text(
            'Albums',
            style: TextStyle(
              color: FColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          ...albums.map((album) => AlbumItem(album: album)),
        ],
      ],
    );
  }
}

