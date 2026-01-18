import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../utils/constants/colors.dart';
import '../../../data/services/playlist/playlist_service.dart';
import '../../../data/models/spotify/spotify_track.dart';

/// Select Playlist Dialog
/// Allows user to select which playlist(s) to add a track to
class SelectPlaylistDialog extends StatefulWidget {
  final SpotifyTrack track;

  const SelectPlaylistDialog({
    super.key,
    required this.track,
  });

  @override
  State<SelectPlaylistDialog> createState() => _SelectPlaylistDialogState();
}

class _SelectPlaylistDialogState extends State<SelectPlaylistDialog> {
  late final PlaylistService _playlistService;

  @override
  void initState() {
    super.initState();
    _playlistService = PlaylistService.instance;
    _playlistService.addListener(_onPlaylistsChanged);
    _playlistService.loadPlaylists();
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: FColors.darkContainer,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Icon(Iconsax.music_library_2, color: FColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add to Playlist',
                    style: TextStyle(
                      color: FColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: FColors.textWhite),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Playlists List
          Flexible(
            child: Builder(
              builder: (context) {
                if (_playlistService.loading) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: CircularProgressIndicator(color: FColors.primary),
                    ),
                  );
                }

                final playlists = _playlistService.playlists;

                if (playlists.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.music_library_2,
                          size: 64,
                          color: FColors.textWhite.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No playlists yet',
                          style: TextStyle(
                            color: FColors.textWhite.withOpacity(0.6),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final isTrackInPlaylist = playlist.trackIds.contains(widget.track.id);

                    return ListTile(
                      enabled: !isTrackInPlaylist,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [FColors.primary, FColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Iconsax.music_library_2,
                          color: FColors.textWhite,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        playlist.name,
                        style: TextStyle(
                          color: isTrackInPlaylist
                              ? FColors.textWhite.withOpacity(0.4)
                              : FColors.textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: isTrackInPlaylist
                          ? Text(
                              'Already in playlist',
                              style: TextStyle(
                                color: FColors.primary.withOpacity(0.7),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            )
                          : Text(
                              '${playlist.trackCount} ${playlist.trackCount == 1 ? 'track' : 'tracks'}',
                              style: TextStyle(
                                color: FColors.textWhite.withOpacity(0.6),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              ),
                            ),
                      trailing: isTrackInPlaylist
                          ? Icon(
                              Icons.check_circle,
                              color: FColors.primary.withOpacity(0.5),
                            )
                          : const Icon(
                              Icons.arrow_forward_ios,
                              color: FColors.textWhite,
                              size: 16,
                            ),
                      onTap: isTrackInPlaylist
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await _playlistService.addTrackToPlaylist(playlist.id, widget.track);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added "${widget.track.name}" to "${playlist.name}"',
                                      style: const TextStyle(fontFamily: 'Poppins'),
                                    ),
                                    backgroundColor: FColors.primary,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

