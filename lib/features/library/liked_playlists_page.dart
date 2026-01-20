import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/data/models/user/playlist.dart';
import 'package:music_player/data/services/liked/liked_playlists_service.dart';
import 'package:music_player/data/services/playlist/playlist_service.dart';
import 'package:music_player/features/library/widgets/playlist_cover.dart';
import 'package:music_player/features/library/playlist_detail_page.dart';

/// Liked Playlists Page
/// Displays all playlists the user has liked
class LikedPlaylistsPage extends StatefulWidget {
  const LikedPlaylistsPage({super.key});

  @override
  State<LikedPlaylistsPage> createState() => _LikedPlaylistsPageState();
}

class _LikedPlaylistsPageState extends State<LikedPlaylistsPage> {
  final LikedPlaylistsService _likedService = LikedPlaylistsService.instance;
  final PlaylistService _playlistService = PlaylistService.instance;

  List<Playlist> _displayedPlaylists = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialLoad();
    _likedService.addListener(_onStateChanged);
    _playlistService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _likedService.removeListener(_onStateChanged);
    _playlistService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      _refreshFromServices();
    }
  }

  Future<void> _initialLoad() async {
    setState(() => _loading = true);
    await _playlistService.loadPlaylists();
    await _likedService.loadLikedPlaylists();
    _refreshFromServices();
  }

  void _refreshFromServices() {
    final liked = _likedService.likedPlaylists;
    final playlists = <Playlist>[];
    for (final item in liked) {
      final fromService = _playlistService.getPlaylist(item.playlistId);
      if (fromService != null) {
        playlists.add(fromService);
      } else {
        playlists.add(
          Playlist(
            id: item.playlistId,
            name: item.name ?? 'Untitled Playlist',
            description: item.description,
            userId: item.userId,
            trackIds: item.trackIds ?? const [],
            createdAt: item.createdAt ?? item.likedAt,
            updatedAt: item.updatedAt ?? item.likedAt,
            isPublic: item.isPublic ?? false,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _displayedPlaylists = playlists;
        _loading = false;
      });
    }
  }

  Future<void> _unlikePlaylist(String playlistId) async {
    await _likedService.unlikePlaylist(playlistId);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: FColors.primary),
      );
    }

    if (_displayedPlaylists.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _displayedPlaylists.length,
      itemBuilder: (context, index) {
        final playlist = _displayedPlaylists[index];
        return Dismissible(
          key: ValueKey('liked-playlist-${playlist.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Iconsax.heart, color: FColors.textWhite),
          ),
          confirmDismiss: (direction) async {
            await _unlikePlaylist(playlist.id);
            return true;
          },
          child: _buildPlaylistRow(playlist),
        );
      },
    );
  }

  Widget _buildPlaylistRow(Playlist playlist) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistDetailPage(playlist: playlist),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: FColors.darkContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: PlaylistCover(playlist: playlist),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      color: FColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.trackCount} ${playlist.trackCount == 1 ? 'track' : 'tracks'}',
                    style: TextStyle(
                      color: FColors.textWhite.withOpacity(0.6),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.heart, color: FColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  FColors.primary.withOpacity(0.3),
                  FColors.secondary.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Iconsax.heart,
              size: 60,
              color: FColors.textWhite,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Liked Playlists',
            style: TextStyle(
              color: FColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Like a playlist to see it here',
            style: TextStyle(
              color: FColors.textWhite.withOpacity(0.6),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
