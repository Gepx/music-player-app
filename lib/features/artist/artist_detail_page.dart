import 'package:flutter/material.dart';
import 'package:music_player/data/models/spotify/spotify_artist.dart';
import 'package:music_player/data/models/spotify/spotify_track.dart';
import 'package:music_player/data/models/spotify/spotify_album.dart';
import 'package:music_player/data/services/spotify/spotify_services.dart';
import 'package:music_player/data/services/playback/web_playback_sdk_service.dart';
import 'package:music_player/features/album/album_detail_page.dart';
import 'package:music_player/features/home/widget/mini_player.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/utils/formatters/number_formatter.dart';

class ArtistDetailPage extends StatefulWidget {
  final SpotifyArtist artist;

  const ArtistDetailPage({
    super.key,
    required this.artist,
  });

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  final SpotifyApiService _spotifyApi = SpotifyApiService.instance;
  List<SpotifyTrack>? _topTracks;
  List<SpotifyAlbum>? _albums;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArtistData();
  }

  Future<void> _loadArtistData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final topTracks = await _spotifyApi.getArtistTopTracks(widget.artist.id);
      final albums = await _spotifyApi.getArtistAlbums(widget.artist.id, limit: 10);

      setState(() {
        _topTracks = topTracks;
        _albums = albums.items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading artist data: $e');
      setState(() {
        _errorMessage = 'Failed to load artist data';
        _isLoading = false;
      });
    }
  }

  String? _getImageUrl() {
    if (widget.artist.images != null && widget.artist.images!.isNotEmpty) {
      return widget.artist.images!.first.url;
    }
    return null;
  }

  String _getFollowersText() {
    if (widget.artist.followers == null) return '';
    return FNumberFormatter.formatFollowers(widget.artist.followers!.total);
  }

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();

    return Scaffold(
      backgroundColor: FColors.black,
      body: CustomScrollView(
        slivers: [
          // Hero Header with Artist Image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: FColors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: FColors.textWhite),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Artist Image with Gradient
                  if (imageUrl != null)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: FColors.darkerGrey,
                          child: const Icon(
                            Icons.person,
                            size: 100,
                            color: FColors.darkGrey,
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: FColors.darkerGrey,
                      child: const Icon(
                        Icons.person,
                        size: 100,
                        color: FColors.darkGrey,
                      ),
                    ),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          FColors.black.withValues(alpha: 0.7),
                          FColors.black,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                  
                  // Artist Info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.artist.name,
                          style: const TextStyle(
                            color: FColors.textWhite,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (widget.artist.followers != null)
                          Text(
                            _getFollowersText(),
                            style: TextStyle(
                              color: FColors.textWhite.withValues(alpha: 0.8),
                              fontSize: 16,
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

          // Content
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: FColors.primary),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: FColors.textWhite,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadArtistData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FColors.primary,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Popular Tracks
                          if (_topTracks != null && _topTracks!.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'Popular',
                                style: TextStyle(
                                  color: FColors.textWhite,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _topTracks!.length,
                              itemBuilder: (context, index) {
                                final track = _topTracks![index];
                                return _buildTrackItem(track, index + 1);
                              },
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Albums
                          if (_albums != null && _albums!.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'Albums',
                                style: TextStyle(
                                  color: FColors.textWhite,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 220,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _albums!.length,
                                itemBuilder: (context, index) {
                                  return _buildAlbumCard(_albums![index]);
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ],
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _buildTrackItem(SpotifyTrack track, int index) {
    final imageUrl = track.album?.images.isNotEmpty == true
        ? track.album!.images.first.url
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: FColors.darkContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            WebPlaybackSDKService.instance.playTrack(
              track,
              playlist: _topTracks,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Track Number
                SizedBox(
                  width: 30,
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: FColors.textWhite.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),

                // Album Art
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48,
                          height: 48,
                          color: FColors.darkerGrey,
                          child: const Icon(Icons.music_note, color: FColors.darkGrey),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 12),

                // Track Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.name,
                        style: const TextStyle(
                          color: FColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (track.album != null)
                        Text(
                          track.album!.name,
                          style: TextStyle(
                            color: FColors.textWhite.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                // Duration
                Text(
                  _formatDuration(track.durationMs),
                  style: TextStyle(
                    color: FColors.textWhite.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 8),

                // More Options
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: FColors.textWhite.withValues(alpha: 0.6),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumCard(SpotifyAlbum album) {
    final imageUrl = album.images.isNotEmpty ? album.images.first.url : null;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
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
              // Album Art
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    imageUrl != null
                        ? Image.network(
                          imageUrl,
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 160,
                              height: 160,
                              color: FColors.darkerGrey,
                              child: const Icon(
                                Icons.album,
                                size: 60,
                                color: FColors.darkGrey,
                              ),
                            );
                          },
                        )
                        : Container(
                          width: 160,
                          height: 160,
                          color: FColors.darkerGrey,
                          child: const Icon(
                            Icons.album,
                            size: 60,
                            color: FColors.darkGrey,
                          ),
                        ),
              ),
              const SizedBox(height: 8),

              // Album Info
              Text(
                album.name,
                style: const TextStyle(
                  color: FColors.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                album.releaseDate.split('-').first,
                style: TextStyle(
                  color: FColors.textWhite.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

