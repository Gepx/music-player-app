import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../utils/constants/colors.dart';
import '../../../data/models/user/playlist.dart';
import '../../../data/services/spotify/spotify_api_service.dart';
import '../../../data/models/spotify/spotify_track.dart';

/// Playlist Cover Widget
/// Displays 2x2 grid of album covers (4+ tracks) or single cover (1-3 tracks)
class PlaylistCover extends StatefulWidget {
  final Playlist playlist;

  const PlaylistCover({
    super.key,
    required this.playlist,
  });

  @override
  State<PlaylistCover> createState() => _PlaylistCoverState();
}

class _PlaylistCoverState extends State<PlaylistCover> {
  final SpotifyApiService _spotify = SpotifyApiService.instance;
  List<SpotifyTrack>? _tracks;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    if (widget.playlist.trackIds.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    try {
      // Load only the tracks needed for cover (max 4)
      final trackIds = widget.playlist.coverTrackIds;
      if (trackIds.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      final tracks = await Future.wait(
        trackIds.map((id) => _spotify.getTrack(id)),
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: FColors.darkContainer,
        child: const Center(
          child: CircularProgressIndicator(
            color: FColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (widget.playlist.coverType == 'placeholder' || _tracks == null || _tracks!.isEmpty) {
      return _buildPlaceholder();
    }

    if (widget.playlist.coverType == 'grid') {
      return _buildGridCover();
    }

    return _buildSingleCover();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FColors.primary.withOpacity(0.6),
            FColors.secondary.withOpacity(0.6),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Iconsax.music,
          size: 48,
          color: FColors.textWhite,
        ),
      ),
    );
  }

  Widget _buildSingleCover() {
    final track = _tracks!.first;
    final imageUrl = track.album?.images.isNotEmpty == true
        ? track.album!.images.first.url
        : null;

    if (imageUrl == null) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildGridCover() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            GridView.builder(
              padding: EdgeInsets.zero,
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                childAspectRatio: 1,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                if (index >= _tracks!.length) {
                  return _buildGridPlaceholder();
                }

                final track = _tracks![index];
                final imageUrl = track.album?.images.isNotEmpty == true
                    ? track.album!.images.first.url
                    : null;

                if (imageUrl == null) {
                  return _buildGridPlaceholder();
                }

                return Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildGridPlaceholder(),
                );
              },
            ),

            // Subtle dividers to make the collage feel intentional (doesn't change 25% image sizing)
            Positioned(
              left: 0,
              right: 0,
              top: (constraints.maxHeight / 2) - 0.5,
              height: 1,
              child: Container(color: FColors.black.withOpacity(0.25)),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: (constraints.maxWidth / 2) - 0.5,
              width: 1,
              child: Container(color: FColors.black.withOpacity(0.25)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FColors.primary.withOpacity(0.4),
            FColors.secondary.withOpacity(0.4),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Iconsax.music,
          size: 24,
          color: FColors.textWhite,
        ),
      ),
    );
  }
}

