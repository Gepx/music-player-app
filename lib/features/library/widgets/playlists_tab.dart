import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../utils/constants/colors.dart';
import '../../../data/services/playlist/playlist_service.dart';
import 'playlist_card.dart';
import 'playlist_dialog.dart';

/// Playlists Tab
/// Displays user's playlists in a grid layout
class PlaylistsTab extends StatefulWidget {
  const PlaylistsTab({super.key});

  @override
  State<PlaylistsTab> createState() => _PlaylistsTabState();
}

class _PlaylistsTabState extends State<PlaylistsTab> {
  final PlaylistService _playlistService = PlaylistService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
    _playlistService.addListener(_onPlaylistsChanged);
  }

  @override
  void dispose() {
    _playlistService.removeListener(_onPlaylistsChanged);
    super.dispose();
  }

  void _onPlaylistsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadPlaylists() async {
    await _playlistService.loadPlaylists();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreatePlaylistDialog() async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => const PlaylistDialog(),
    );

    if (result != null && mounted) {
      await _playlistService.createPlaylist(
        name: result['name']!,
        description: result['description'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: FColors.primary),
      );
    }

    final playlists = _playlistService.playlists;

    if (playlists.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      slivers: [
        // Create Playlist Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: _showCreatePlaylistDialog,
              icon: const Icon(Iconsax.add, color: FColors.textWhite),
              label: const Text(
                'Create Playlist',
                style: TextStyle(
                  color: FColors.textWhite,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        // Playlists Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PlaylistCard(playlist: playlists[index]);
              },
              childCount: playlists.length,
            ),
          ),
        ),

        // Bottom padding for mini player
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
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
              Iconsax.music_playlist,
              size: 60,
              color: FColors.textWhite,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Playlists Yet',
            style: TextStyle(
              color: FColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first playlist to get started',
            style: TextStyle(
              color: FColors.textWhite.withOpacity(0.6),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showCreatePlaylistDialog,
            icon: const Icon(Iconsax.add, color: FColors.textWhite),
            label: const Text(
              'Create Playlist',
              style: TextStyle(
                color: FColors.textWhite,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

