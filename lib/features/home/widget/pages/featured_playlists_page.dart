import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_models.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/utils/constants/colors.dart';

class FeaturedPlaylistsPage extends StatefulWidget {
  const FeaturedPlaylistsPage({super.key, this.title, this.categoryId});

  final String? title;
  final String? categoryId; // if provided, load playlists for this category (e.g., 'toplists')

  @override
  State<FeaturedPlaylistsPage> createState() => _FeaturedPlaylistsPageState();
}

class _FeaturedPlaylistsPageState extends State<FeaturedPlaylistsPage> {
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  List<SpotifyPlaylist> _playlists = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      List<SpotifyPlaylist> playlists = const [];

      if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
        playlists = await _spotify.getCategoryPlaylists(widget.categoryId!, limit: 30);
      }

      // Fallback to featured if category has no items
      if (playlists.isEmpty) {
        playlists = await _spotify.getFeaturedPlaylists(limit: 30);
      }
      if (!mounted) return;
      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load playlists';
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
        title: Text(
          widget.title ?? 'Charts',
          style: const TextStyle(color: FColors.textWhite, fontFamily: 'Poppins'),
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
                  itemCount: _playlists.length,
                  itemBuilder: (context, index) {
                    final p = _playlists[index];
                    final imageUrl = (p.images != null && p.images!.isNotEmpty)
                        ? p.images!.first.url
                        : null;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: FColors.darkContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl != null
                              ? Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                              : Container(
                                  width: 56,
                                  height: 56,
                                  color: FColors.darkerGrey,
                                ),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            color: FColors.textWhite,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          p.description ?? '',
                          style: TextStyle(
                            color: FColors.textWhite.withValues(alpha: 0.7),
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                ),
    );
  }
}


