import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'spotify_artist.dart';
import 'spotify_album.dart';
import 'spotify_external_urls.dart';

part 'spotify_track.g.dart';

/// Spotify Track Model
/// Represents a track from Spotify API
@JsonSerializable()
class SpotifyTrack extends Equatable {
  /// The Spotify ID for the track
  final String id;

  /// The name of the track
  final String name;

  /// The Spotify URI for the track
  final String uri;

  /// The artists who performed the track
  final List<SpotifyArtist> artists;

  /// The album on which the track appears
  final SpotifyAlbum? album;

  /// The track length in milliseconds
  @JsonKey(name: 'duration_ms')
  final int durationMs;

  /// Whether or not the track has explicit lyrics
  final bool explicit;

  /// Known external URLs for this track
  @JsonKey(name: 'external_urls')
  final SpotifyExternalUrls? externalUrls;

  /// A link to the Web API endpoint providing full details
  final String? href;

  /// The popularity of the track (0-100)
  final int? popularity;

  /// A link to a 30 second preview (MP3 format) of the track
  @JsonKey(name: 'preview_url')
  final String? previewUrl;

  /// The number of the track
  @JsonKey(name: 'track_number')
  final int? trackNumber;

  /// The object type (track)
  final String? type;

  /// Whether or not the track is from a local file
  @JsonKey(name: 'is_local')
  final bool? isLocal;

  /// Part of the response when Track Relinking is applied
  @JsonKey(name: 'is_playable')
  final bool? isPlayable;

  /// The disc number (usually 1)
  @JsonKey(name: 'disc_number')
  final int? discNumber;

  const SpotifyTrack({
    required this.id,
    required this.name,
    required this.uri,
    required this.artists,
    required this.durationMs,
    required this.explicit,
    this.album,
    this.externalUrls,
    this.href,
    this.popularity,
    this.previewUrl,
    this.trackNumber,
    this.type,
    this.isLocal,
    this.isPlayable,
    this.discNumber,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) =>
      _$SpotifyTrackFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyTrackToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        uri,
        artists,
        album,
        durationMs,
        explicit,
        externalUrls,
        href,
        popularity,
        previewUrl,
        trackNumber,
        type,
        isLocal,
        isPlayable,
        discNumber,
      ];
}

