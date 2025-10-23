import '../models/spotify/spotify_models.dart';
import '../models/app/app_models.dart';
import 'package:uuid/uuid.dart';

/// Spotify to App Mapper
/// Converts Spotify API models to app's internal models
class SpotifyToAppMapper {
  SpotifyToAppMapper._();
  
  static const _uuid = Uuid();

  // -------------------- Track Mapping -------------------- //

  /// Convert Spotify track to app track model
  static TrackModel trackFromSpotify(SpotifyTrack spotifyTrack) {
    return TrackModel(
      id: _generateAppId(),
      spotifyId: spotifyTrack.id,
      title: spotifyTrack.name,
      artistName: spotifyTrack.artists.isNotEmpty 
          ? spotifyTrack.artists.first.name 
          : 'Unknown Artist',
      artistId: spotifyTrack.artists.isNotEmpty 
          ? spotifyTrack.artists.first.id 
          : null,
      albumName: spotifyTrack.album?.name ?? 'Unknown Album',
      albumId: spotifyTrack.album?.id,
      albumArtUrl: _getImageUrl(spotifyTrack.album?.images),
      durationMs: spotifyTrack.durationMs,
      streamUrl: spotifyTrack.previewUrl,
      isFavorite: false,
      addedAt: DateTime.now(),
      playCount: 0,
      isDownloaded: false,
      localPath: null,
      popularity: spotifyTrack.popularity,
      explicit: spotifyTrack.explicit,
      uri: spotifyTrack.uri,
    );
  }

  /// Convert list of Spotify tracks
  static List<TrackModel> tracksFromSpotify(List<SpotifyTrack> spotifyTracks) {
    return spotifyTracks.map(trackFromSpotify).toList();
  }

  // -------------------- Album Mapping -------------------- //

  /// Convert Spotify album to app album model
  static AlbumModel albumFromSpotify(SpotifyAlbum spotifyAlbum) {
    return AlbumModel(
      id: _generateAppId(),
      spotifyId: spotifyAlbum.id,
      title: spotifyAlbum.name,
      artistName: spotifyAlbum.artists.isNotEmpty 
          ? spotifyAlbum.artists.first.name 
          : 'Unknown Artist',
      artistId: spotifyAlbum.artists.isNotEmpty 
          ? spotifyAlbum.artists.first.id 
          : null,
      coverArtUrl: _getImageUrl(spotifyAlbum.images),
      releaseDate: _parseReleaseDate(
        spotifyAlbum.releaseDate, 
        spotifyAlbum.releaseDatePrecision,
      ),
      totalTracks: spotifyAlbum.totalTracks,
      trackIds: [],
      isSaved: false,
      albumType: spotifyAlbum.albumType,
      uri: spotifyAlbum.uri,
    );
  }

  /// Convert list of Spotify albums
  static List<AlbumModel> albumsFromSpotify(List<SpotifyAlbum> spotifyAlbums) {
    return spotifyAlbums.map(albumFromSpotify).toList();
  }

  // -------------------- Artist Mapping -------------------- //

  /// Convert Spotify artist to app artist model
  static ArtistModel artistFromSpotify(SpotifyArtist spotifyArtist) {
    return ArtistModel(
      id: _generateAppId(),
      spotifyId: spotifyArtist.id,
      name: spotifyArtist.name,
      imageUrl: _getImageUrl(spotifyArtist.images),
      genres: spotifyArtist.genres ?? [],
      isFollowing: false,
      trackCount: 0,
      albumCount: 0,
      popularity: spotifyArtist.popularity,
      followers: spotifyArtist.followers?.total,
      uri: spotifyArtist.uri,
    );
  }

  /// Convert list of Spotify artists
  static List<ArtistModel> artistsFromSpotify(List<SpotifyArtist> spotifyArtists) {
    return spotifyArtists.map(artistFromSpotify).toList();
  }

  // -------------------- Playlist Mapping -------------------- //

  /// Convert Spotify playlist to app playlist model
  static PlaylistModel playlistFromSpotify(SpotifyPlaylist spotifyPlaylist) {
    return PlaylistModel(
      id: _generateAppId(),
      spotifyId: spotifyPlaylist.id,
      name: spotifyPlaylist.name,
      description: spotifyPlaylist.description,
      coverUrl: _getImageUrl(spotifyPlaylist.images),
      ownerId: spotifyPlaylist.owner.id,
      ownerName: spotifyPlaylist.owner.displayName ?? spotifyPlaylist.owner.id,
      trackIds: [],
      isPublic: spotifyPlaylist.public ?? false,
      isCollaborative: spotifyPlaylist.collaborative ?? false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFromSpotify: true,
      uri: spotifyPlaylist.uri,
    );
  }

  /// Convert list of Spotify playlists
  static List<PlaylistModel> playlistsFromSpotify(List<SpotifyPlaylist> spotifyPlaylists) {
    return spotifyPlaylists.map(playlistFromSpotify).toList();
  }

  // -------------------- Helper Methods -------------------- //

  /// Generate unique app ID
  static String _generateAppId() {
    return _uuid.v4();
  }

  /// Get best quality image URL from list
  static String? _getImageUrl(List<SpotifyImage>? images) {
    if (images == null || images.isEmpty) return null;
    
    // Sort by size (largest first) and return URL
    final sortedImages = List<SpotifyImage>.from(images)
      ..sort((a, b) {
        final aSize = (a.height ?? 0) * (a.width ?? 0);
        final bSize = (b.height ?? 0) * (b.width ?? 0);
        return bSize.compareTo(aSize);
      });
    
    return sortedImages.first.url;
  }

  /// Parse release date with precision handling
  static DateTime _parseReleaseDate(String releaseDate, String precision) {
    try {
      switch (precision) {
        case 'year':
          return DateTime(int.parse(releaseDate), 1, 1);
        case 'month':
          final parts = releaseDate.split('-');
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
        case 'day':
        default:
          return DateTime.parse(releaseDate);
      }
    } catch (e) {
      // Fallback to current date if parsing fails
      return DateTime.now();
    }
  }

  // -------------------- Reverse Mapping (App to Spotify URI) -------------------- //

  /// Get Spotify URI from track model
  static String? getTrackUri(TrackModel track) {
    return track.uri ?? (track.spotifyId != null ? 'spotify:track:${track.spotifyId}' : null);
  }

  /// Get Spotify URI from album model
  static String? getAlbumUri(AlbumModel album) {
    return album.uri ?? (album.spotifyId != null ? 'spotify:album:${album.spotifyId}' : null);
  }

  /// Get Spotify URI from artist model
  static String? getArtistUri(ArtistModel artist) {
    return artist.uri ?? (artist.spotifyId != null ? 'spotify:artist:${artist.spotifyId}' : null);
  }

  /// Get Spotify URI from playlist model
  static String? getPlaylistUri(PlaylistModel playlist) {
    return playlist.uri ?? (playlist.spotifyId != null ? 'spotify:playlist:${playlist.spotifyId}' : null);
  }
}

