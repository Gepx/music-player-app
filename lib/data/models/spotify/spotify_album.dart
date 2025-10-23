import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'spotify_image.dart';
import 'spotify_artist.dart';
import 'spotify_external_urls.dart';

part 'spotify_album.g.dart';

/// Spotify Album Model
/// Represents an album from Spotify API
@JsonSerializable()
class SpotifyAlbum extends Equatable {
  /// The Spotify ID for the album
  final String id;

  /// The name of the album
  final String name;

  /// The Spotify URI for the album
  final String uri;

  /// The type of the album (album, single, compilation)
  @JsonKey(name: 'album_type')
  final String albumType;

  /// The artists of the album
  final List<SpotifyArtist> artists;

  /// The markets in which the album is available
  @JsonKey(name: 'available_markets')
  final List<String>? availableMarkets;

  /// Known external URLs for this album
  @JsonKey(name: 'external_urls')
  final SpotifyExternalUrls? externalUrls;

  /// A link to the Web API endpoint providing full details
  final String? href;

  /// The cover art for the album in various sizes
  final List<SpotifyImage> images;

  /// The date the album was first released
  @JsonKey(name: 'release_date')
  final String releaseDate;

  /// The precision with which release_date value is known (year, month, day)
  @JsonKey(name: 'release_date_precision')
  final String releaseDatePrecision;

  /// The number of tracks in the album
  @JsonKey(name: 'total_tracks')
  final int totalTracks;

  /// The object type (album)
  final String? type;

  const SpotifyAlbum({
    required this.id,
    required this.name,
    required this.uri,
    required this.albumType,
    required this.artists,
    required this.images,
    required this.releaseDate,
    required this.releaseDatePrecision,
    required this.totalTracks,
    this.availableMarkets,
    this.externalUrls,
    this.href,
    this.type,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) =>
      _$SpotifyAlbumFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyAlbumToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        uri,
        albumType,
        artists,
        availableMarkets,
        externalUrls,
        href,
        images,
        releaseDate,
        releaseDatePrecision,
        totalTracks,
        type,
      ];
}

