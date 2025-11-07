import 'package:flutter/material.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/data/models/spotify/spotify_search_result.dart';
import 'package:music_player/features/search/widget/subwidget/track_item.dart';
import 'package:music_player/features/search/widget/subwidget/album_item.dart';
import 'package:music_player/features/search/widget/subwidget/artist_item.dart';
import 'package:music_player/utils/constants/colors.dart';

class GenreResultsPage extends StatefulWidget {
  const GenreResultsPage({super.key, required this.title});

  final String title;

  @override
  State<GenreResultsPage> createState() => _GenreResultsPageState();
}

class _GenreResultsPageState extends State<GenreResultsPage> {
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  SpotifySearchResult? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Prototype: search by the genre title; later we can use categories endpoint
      final res = await _spotify.search(query: widget.title, type: SpotifySearchType.all, limit: 10);
      if (!mounted) return;
      setState(() {
        _result = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load results';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FColors.black,
      appBar: AppBar(
        backgroundColor: FColors.black,
        iconTheme: const IconThemeData(color: FColors.textWhite),
        title: Text(widget.title, style: const TextStyle(color: FColors.textWhite, fontFamily: 'Poppins')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: FColors.primary))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: FColors.textWhite)))
              : ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    if (_result?.tracks?.items.isNotEmpty ?? false) ...[
                      const Text('Songs', style: TextStyle(color: FColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      const SizedBox(height: 12),
                      ..._result!.tracks!.items.map((t) => TrackItem(track: t)),
                      const SizedBox(height: 24),
                    ],
                    if (_result?.albums?.items.isNotEmpty ?? false) ...[
                      const Text('Albums', style: TextStyle(color: FColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      const SizedBox(height: 12),
                      ..._result!.albums!.items.map((a) => AlbumItem(album: a)),
                      const SizedBox(height: 24),
                    ],
                    if (_result?.artists?.items.isNotEmpty ?? false) ...[
                      const Text('Artists', style: TextStyle(color: FColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      const SizedBox(height: 12),
                      ..._result!.artists!.items.map((ar) => ArtistItem(artist: ar)),
                    ],
                  ],
                ),
    );
  }
}


