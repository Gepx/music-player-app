import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'spotify_image.dart';
import 'spotify_user.dart';
import 'spotify_external_urls.dart';
import 'spotify_followers.dart';

part 'spotify_playlist.g.dart';

/// Spotify Playlist Model
/// Represents a playlist from Spotify API
@JsonSerializable()
class SpotifyPlaylist extends Equatable {
  /// The Spotify ID for the playlist
  final String id;

  /// The name of the playlist
  final String name;

  /// The playlist description
  final String? description;

  /// The Spotify URI for the playlist
  final String uri;

  /// The user who owns the playlist
  final SpotifyUser owner;

  /// Images for the playlist
  final List<SpotifyImage>? images;

  /// Whether the playlist is public
  final bool? public;

  /// Whether the owner allows other users to modify the playlist
  final bool? collaborative;

  /// Known external URLs for this playlist
  @JsonKey(name: 'external_urls')
  final SpotifyExternalUrls? externalUrls;

  /// A link to the Web API endpoint providing full details
  final String? href;

  /// Information about followers
  final SpotifyFollowers? followers;

  /// The version identifier for the current playlist
  @JsonKey(name: 'snapshot_id')
  final String snapshotId;

  /// The object type (playlist)
  final String? type;

  /// Information about the tracks of the playlist
  final PlaylistTracks? tracks;

  const SpotifyPlaylist({
    required this.id,
    required this.name,
    this.description,
    required this.uri,
    required this.owner,
    required this.snapshotId,
    this.images,
    this.public,
    this.collaborative,
    this.externalUrls,
    this.href,
    this.followers,
    this.type,
    this.tracks,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) =>
      _$SpotifyPlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyPlaylistToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        uri,
        owner,
        images,
        public,
        collaborative,
        externalUrls,
        href,
        followers,
        snapshotId,
        type,
        tracks,
      ];
}

/// Playlist Tracks Information
@JsonSerializable()
class PlaylistTracks extends Equatable {
  /// A link to the Web API endpoint
  final String? href;

  /// The total number of tracks
  final int total;

  const PlaylistTracks({
    this.href,
    required this.total,
  });

  factory PlaylistTracks.fromJson(Map<String, dynamic> json) =>
      _$PlaylistTracksFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistTracksToJson(this);

  @override
  List<Object?> get props => [href, total];
}

