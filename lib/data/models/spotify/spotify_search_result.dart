import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../dto/paging_dto.dart';
import 'spotify_track.dart';
import 'spotify_album.dart';
import 'spotify_artist.dart';
import 'spotify_playlist.dart';

part 'spotify_search_result.g.dart';

/// Spotify Search Result
/// Contains search results for tracks, albums, artists, and playlists
@JsonSerializable()
class SpotifySearchResult extends Equatable {
  /// Paged set of tracks
  final PagingDto<SpotifyTrack>? tracks;

  /// Paged set of albums
  final PagingDto<SpotifyAlbum>? albums;

  /// Paged set of artists
  final PagingDto<SpotifyArtist>? artists;

  /// Paged set of playlists
  final PagingDto<SpotifyPlaylist>? playlists;

  const SpotifySearchResult({
    this.tracks,
    this.albums,
    this.artists,
    this.playlists,
  });

  factory SpotifySearchResult.fromJson(Map<String, dynamic> json) =>
      _$SpotifySearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifySearchResultToJson(this);

  @override
  List<Object?> get props => [tracks, albums, artists, playlists];
}

/// Search Type Enum
enum SpotifySearchType {
  track,
  album,
  artist,
  playlist,
  all;

  String get apiValue {
    switch (this) {
      case SpotifySearchType.track:
        return 'track';
      case SpotifySearchType.album:
        return 'album';
      case SpotifySearchType.artist:
        return 'artist';
      case SpotifySearchType.playlist:
        return 'playlist';
      case SpotifySearchType.all:
        return 'track,album,artist,playlist';
    }
  }
}

