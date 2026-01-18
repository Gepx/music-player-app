import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../utils/constants/colors.dart';
import '../../data/services/liked/liked_tracks_service.dart';
import '../../data/models/user/liked_track.dart';
import '../../data/services/spotify/spotify_api_service.dart';
import '../../data/models/spotify/spotify_track.dart';
import '../../data/services/playback/spotify_embed_service.dart';
import '../../data/services/playback/web_playback_sdk_service.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../../utils/formatters/number_formatter.dart';

/// Liked Songs Page
/// Displays all tracks the user has liked
class LikedSongsPage extends StatefulWidget {
  const LikedSongsPage({super.key});

  @override
  State<LikedSongsPage> createState() => _LikedSongsPageState();
}

class _LikedSongsPageState extends State<LikedSongsPage> {
  final LikedTracksService _likedService = LikedTracksService.instance;
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  final SpotifyEmbedService _embedService = SpotifyEmbedService.instance;
  final WebPlaybackSDKService _webPlaybackService = WebPlaybackSDKService.instance;

  List<LikedTrack> _displayedTracks = [];
  List<SpotifyTrack> _spotifyTracks = [];
  bool _loading = true;
  String _sortBy = 'recent'; // recent, name, artist
  late bool _isMobilePlatform;
  final Map<String, SpotifyTrack> _trackCache = {};

  @override
  void initState() {
    super.initState();
    _isMobilePlatform = kIsWeb ? false : (Platform.isAndroid || Platform.isIOS);
    _initialLoad();
    _likedService.addListener(_onLikedTracksChanged);
  }

  @override
  void dispose() {
    _likedService.removeListener(_onLikedTracksChanged);
    super.dispose();
  }

  void _onLikedTracksChanged() {
    if (mounted) {
      // IMPORTANT: Do NOT call _likedService.loadLikedTracks() here.
      // loadLikedTracks() notifies listeners; calling it from a listener creates a loop
      // that can freeze/crash (especially on web).
      _refreshFromService(fetchNewSpotifyTracks: true);
    }
  }

  Future<void> _initialLoad() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
    });
    try {
      await _likedService.loadLikedTracks();
      await _refreshFromService(fetchNewSpotifyTracks: true);
    } catch (e) {
      debugPrint('❌ Error initial loading liked tracks: $e');
      if (mounted) {
        setState(() {
          _spotifyTracks = [];
          _displayedTracks = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _refreshFromService({required bool fetchNewSpotifyTracks}) async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
    });
    
    try {
      // Sort the tracks
      _displayedTracks = _likedService.sortLikedTracks(_sortBy);
      
      debugPrint('📖 Loading ${_displayedTracks.length} liked tracks');
      
      // Incrementally fetch Spotify tracks (avoid refetching everything on every like/unlike)
      final desiredIds = _displayedTracks.map((t) => t.trackId).toList();

      if (fetchNewSpotifyTracks) {
        for (final id in desiredIds) {
          if (!mounted) break;
          if (_trackCache.containsKey(id)) continue;
          try {
            final track = await _spotify.getTrack(id);
            _trackCache[id] = track;
          } catch (e) {
            debugPrint('⚠️ Error loading track $id: $e');
            // Keep going; we'll just omit tracks we can't load
          }
        }
      }

      final tempTracks = <SpotifyTrack>[];
      for (final id in desiredIds) {
        final t = _trackCache[id];
        if (t != null) tempTracks.add(t);
      }
      
      if (mounted) {
        setState(() {
          _spotifyTracks = tempTracks;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading liked tracks: $e');
      if (mounted) {
        setState(() {
          _spotifyTracks = [];
          _displayedTracks = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _playAll() async {
    if (_spotifyTracks.isEmpty) return;

    if (_isMobilePlatform) {
      _embedService.loadTrack(_spotifyTracks.first, playlist: _spotifyTracks);
    } else {
      await _webPlaybackService.playTrack(_spotifyTracks.first, playlist: _spotifyTracks);
    }
  }

  Future<void> _playTrack(SpotifyTrack track) async {
    if (_isMobilePlatform) {
      _embedService.loadTrack(track, playlist: _spotifyTracks);
    } else {
      await _webPlaybackService.playTrack(track, playlist: _spotifyTracks);
    }
  }

  Future<void> _unlikeTrack(String trackId) async {
    await _likedService.unlikeTrack(trackId);
  }

  void _changeSortBy(String newSortBy) {
    try {
      setState(() {
        _sortBy = newSortBy;
        _displayedTracks = _likedService.sortLikedTracks(_sortBy);
      });
      // Rebuild spotifyTracks ordering without re-fetching
      _refreshFromService(fetchNewSpotifyTracks: false);
    } catch (e) {
      debugPrint('❌ Error changing sort: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    try {
      if (_loading) {
        return const Center(
          child: CircularProgressIndicator(color: FColors.primary),
        );
      }

      if (_displayedTracks.isEmpty || _spotifyTracks.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: [
          // Header with sort and play all
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Sort dropdown
                DropdownButton<String>(
                  value: _sortBy,
                  dropdownColor: FColors.darkContainer,
                  style: const TextStyle(
                    color: FColors.textWhite,
                    fontFamily: 'Poppins',
                  ),
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, color: FColors.textWhite),
                  items: const [
                    DropdownMenuItem(value: 'recent', child: Text('Recently Added')),
                    DropdownMenuItem(value: 'name', child: Text('Song Name')),
                    DropdownMenuItem(value: 'artist', child: Text('Artist')),
                  ],
                  onChanged: (value) {
                    if (value != null) _changeSortBy(value);
                  },
                ),
                const Spacer(),
                // Play all button
                ElevatedButton.icon(
                  onPressed: _playAll,
                  icon: const Icon(Iconsax.play, size: 16),
                  label: const Text(
                    'Play All',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    foregroundColor: FColors.textWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tracks count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_spotifyTracks.length} ${_spotifyTracks.length == 1 ? 'song' : 'songs'}',
                style: TextStyle(
                  color: FColors.textWhite.withOpacity(0.6),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tracks list
          Expanded(
            child: ListView.builder(
              itemCount: _spotifyTracks.length,
              itemBuilder: (context, index) {
                try {
                  if (index >= _spotifyTracks.length) return const SizedBox.shrink();
                  final track = _spotifyTracks[index];
                  return _buildTrackItem(track);
                } catch (e) {
                  debugPrint('❌ Error building track item at index $index: $e');
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      );
    } catch (e) {
      debugPrint('❌ Error building liked songs content: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading liked songs',
              style: TextStyle(
                color: FColors.textWhite,
                fontSize: 18,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              e.toString(),
              style: TextStyle(
                color: FColors.textWhite.withOpacity(0.6),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initialLoad,
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.primary,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTrackItem(SpotifyTrack track) {
    try {
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
          child: const Icon(Iconsax.heart, color: FColors.textWhite),
        ),
        confirmDismiss: (direction) async {
          try {
            await _unlikeTrack(track.id);
            return true;
          } catch (e) {
            debugPrint('❌ Error unliking track: $e');
            return false;
          }
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FNumberFormatter.formatDuration(track.durationMs),
                style: TextStyle(
                  color: FColors.textWhite.withOpacity(0.5),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.favorite,
                size: 20,
                color: FColors.primary,
              ),
            ],
          ),
          onTap: () {
            try {
              _playTrack(track);
            } catch (e) {
              debugPrint('❌ Error playing track: $e');
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Error building track item: $e');
      return const SizedBox.shrink();
    }
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

  Widget _buildEmptyState() {
    try {
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
              'No Liked Songs',
              style: TextStyle(
                color: FColors.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start liking songs to see them here',
              style: TextStyle(
                color: FColors.textWhite.withOpacity(0.6),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ Error building empty state: $e');
      return const Center(
        child: Text(
          'No liked songs',
          style: TextStyle(
            color: FColors.textWhite,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }
  }
}

