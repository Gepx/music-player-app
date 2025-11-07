import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_models.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/features/search/widget/subwidget/album_item.dart';
import 'package:music_player/utils/constants/colors.dart';

class NewReleasesPage extends StatefulWidget {
  const NewReleasesPage({super.key});

  @override
  State<NewReleasesPage> createState() => _NewReleasesPageState();
}

class _NewReleasesPageState extends State<NewReleasesPage> {
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  List<SpotifyAlbum> _albums = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final albums = await _spotify.getNewReleases(limit: 30);
      if (!mounted) return;
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load new releases';
        _isLoading = false;
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
        title: const Text(
          'New Releases',
          style: TextStyle(color: FColors.textWhite, fontFamily: 'Poppins'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: FColors.primary))
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: FColors.textWhite, fontFamily: 'Poppins'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _albums.length,
                  itemBuilder: (context, index) => AlbumItem(album: _albums[index]),
                ),
    );
  }
}


