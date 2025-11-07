import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/data/models/spotify/spotify_models.dart';
import 'package:music_player/features/album/album_detail_page.dart';

class MadeForYouList extends StatefulWidget {
  const MadeForYouList({super.key});

  @override
  State<MadeForYouList> createState() => _MadeForYouListState();
}

class _MadeForYouListState extends State<MadeForYouList> {
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  final List<String> _albumQueries = const [
    'The 1975 - Being Funny in Foreign Language',
    'Lany - XXL',
    'Ed Sheeran - (Divide)',
    'The 1975 - The 1975',
  ];

  bool _isLoading = true;
  String? _error;
  List<SpotifyAlbum> _albums = const [];

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    try {
      final List<SpotifyAlbum> fetched = [];
      for (final query in _albumQueries) {
        final result = await _spotify.search(
          query: query,
          type: SpotifySearchType.album,
          limit: 1,
        );
        final first = result.albums?.items.isNotEmpty == true
            ? result.albums!.items.first
            : null;
        if (first != null) {
          fetched.add(first);
        }
      }

      if (!mounted) return;
      setState(() {
        _albums = fetched;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load albums';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: FColors.primary),
        ),
      );
    }

    if (_error != null || _albums.isEmpty) {
      // Fallback to a minimal empty state
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No albums found',
            style: TextStyle(color: FColors.textWhite, fontFamily: 'Poppins'),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          final album = _albums[index];
          final imageUrl = album.images.isNotEmpty ? album.images.first.url : null;
          final artistNames = album.artists.map((a) => a.name).join(', ');

          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: FColors.darkContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlbumDetailPage(album: album),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: imageUrl == null
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [FColors.primary, FColors.secondary],
                          )
                        : null,
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: FColors.textWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            artistNames,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: FColors.textWhite.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
