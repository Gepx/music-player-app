import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../utils/constants/colors.dart';
import '../../data/models/user/playlist.dart';
import '../../data/models/spotify/spotify_track.dart';
import '../../data/services/playlist/playlist_service.dart';
import '../../data/services/spotify/spotify_api_service.dart';
import '../../data/services/liked/liked_playlists_service.dart';
import '../../data/services/playback/web_playback_sdk_service.dart';
import '../home/widget/mini_player.dart';
import 'widgets/playlist_dialog.dart';
import 'widgets/playlist_cover.dart';
import 'widgets/add_songs_dialog.dart';
import '../../utils/formatters/number_formatter.dart';

/// Playlist Detail Page
/// Shows all tracks in a playlist with playback and management options
class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({
    super.key,
    required this.playlist,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final PlaylistService _playlistService = PlaylistService.instance;
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  final WebPlaybackSDKService _webPlaybackService = WebPlaybackSDKService.instance;
  final LikedPlaylistsService _likedPlaylists = LikedPlaylistsService.instance;

  List<SpotifyTrack> _tracks = [];
  bool _loading = true;
  late Playlist _currentPlaylist;

  @override
  void initState() {
    super.initState();
    _currentPlaylist = widget.playlist;
    _loadTracks();
    _playlistService.addListener(_onPlaylistChanged);
    _likedPlaylists.addListener(_onLikedChanged);
    _likedPlaylists.loadLikedPlaylists();
  }

  @override
  void dispose() {
    _playlistService.removeListener(_onPlaylistChanged);
    _likedPlaylists.removeListener(_onLikedChanged);
    super.dispose();
  }

  void _onLikedChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onPlaylistChanged() {
    final updated = _playlistService.getPlaylist(_currentPlaylist.id);
    if (updated != null && mounted) {
      setState(() {
        _currentPlaylist = updated;
      });
      _loadTracks();
    }
  }

  Future<void> _loadTracks() async {
    if (_currentPlaylist.trackIds.isEmpty) {
      setState(() {
        _tracks = [];
        _loading = false;
      });
      return;
    }

    try {
      final tracks = await Future.wait(
        _currentPlaylist.trackIds.map((id) => _spotify.getTrack(id)),
      );

      if (mounted) {
        setState(() {
          _tracks = tracks;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _playAll() async {
    if (_tracks.isEmpty) return;

    await _webPlaybackService.playTrack(_tracks.first, playlist: _tracks);
  }

  Future<void> _playTrack(SpotifyTrack track) async {
    await _webPlaybackService.playTrack(track, playlist: _tracks);
  }

  Future<void> _editPlaylist() async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => PlaylistDialog(playlist: _currentPlaylist),
    );

    if (result != null && mounted) {
      await _playlistService.updatePlaylist(
        playlistId: _currentPlaylist.id,
        name: result['name'],
        description: result['description'],
      );
    }
  }

  Future<void> _deletePlaylist() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FColors.darkContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Playlist?',
          style: TextStyle(color: FColors.textWhite, fontFamily: 'Poppins'),
        ),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(
            color: FColors.textWhite.withOpacity(0.7),
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _playlistService.deletePlaylist(_currentPlaylist.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _removeTrack(String trackId) async {
    await _playlistService.removeTrackFromPlaylist(_currentPlaylist.id, trackId);
  }

  Future<void> _showAddSongsDialog() async {
    final tracks = await showDialog<List<SpotifyTrack>>(
      context: context,
      builder: (context) => AddSongsDialog(
        playlistId: _currentPlaylist.id,
        existingTrackIds: _currentPlaylist.trackIds,
      ),
    );

    if (tracks != null && tracks.isNotEmpty && mounted) {
      for (final track in tracks) {
        await _playlistService.addTrackToPlaylist(_currentPlaylist.id, track);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added ${tracks.length} ${tracks.length == 1 ? 'song' : 'songs'} to playlist',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: FColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = _likedPlaylists.isLiked(_currentPlaylist.id);
    return Scaffold(
      backgroundColor: FColors.dark,
      body: CustomScrollView(
        slivers: [
          // App Bar with Cover
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: FColors.dark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: FColors.textWhite),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Iconsax.heart,
                  color: isLiked ? FColors.primary : FColors.textWhite,
                ),
                onPressed: () async {
                  try {
                    await _likedPlaylists.toggleLike(_currentPlaylist);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to update playlist like: $e',
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Iconsax.edit, color: FColors.textWhite),
                onPressed: _editPlaylist,
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, color: Colors.red),
                onPressed: _deletePlaylist,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      FColors.primary.withOpacity(0.3),
                      FColors.dark,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      // Cover
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: FColors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: PlaylistCover(playlist: _currentPlaylist),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Playlist Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentPlaylist.name,
                    style: const TextStyle(
                      color: FColors.textWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (_currentPlaylist.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _currentPlaylist.description!,
                      style: TextStyle(
                        color: FColors.textWhite.withOpacity(0.7),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${_currentPlaylist.trackCount} ${_currentPlaylist.trackCount == 1 ? 'track' : 'tracks'}',
                    style: TextStyle(
                      color: FColors.textWhite.withOpacity(0.6),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      // Play All Button
                      if (_tracks.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _playAll,
                            icon: const Icon(Iconsax.play, color: FColors.textWhite),
                            label: const Text(
                              'Play All',
                              style: TextStyle(
                                color: FColors.textWhite,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      
                      if (_tracks.isNotEmpty) const SizedBox(width: 12),
                      
                      // Add Songs Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showAddSongsDialog,
                          icon: const Icon(Iconsax.add, color: FColors.textWhite),
                          label: const Text(
                            'Add Songs',
                            style: TextStyle(
                              color: FColors.textWhite,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FColors.darkContainer,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tracks List
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: FColors.primary),
              ),
            )
          else if (_tracks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.music,
                      size: 64,
                      color: FColors.textWhite.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tracks yet',
                      style: TextStyle(
                        color: FColors.textWhite.withOpacity(0.6),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = _tracks[index];
                  return _buildTrackItem(track, index);
                },
                childCount: _tracks.length,
              ),
            ),

          // Bottom padding for mini player
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _buildTrackItem(SpotifyTrack track, int index) {
    final imageUrl = track.album?.images.isNotEmpty == true
        ? track.album!.images.first.url
        : null;

    return Dismissible(
      key: Key(track.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Iconsax.trash, color: FColors.textWhite),
      ),
      confirmDismiss: (direction) async {
        await _removeTrack(track.id);
        return true;
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
        title: Text(
          track.name,
          style: const TextStyle(
            color: FColors.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          track.artists.map((a) => a.name).join(', '),
          style: TextStyle(
            color: FColors.textWhite.withOpacity(0.6),
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          FNumberFormatter.formatDuration(track.durationMs),
          style: TextStyle(
            color: FColors.textWhite.withOpacity(0.5),
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
        ),
        onTap: () => _playTrack(track),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: FColors.darkerGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note, color: FColors.darkGrey),
    );
  }
}

