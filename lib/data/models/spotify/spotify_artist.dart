import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'spotify_image.dart';
import 'spotify_external_urls.dart';
import 'spotify_followers.dart';

part 'spotify_artist.g.dart';

/// Spotify Artist Model
/// Represents an artist from Spotify API
@JsonSerializable()
class SpotifyArtist extends Equatable {
  /// The Spotify ID for the artist
  final String id;

  /// The name of the artist
  final String name;

  /// The Spotify URI for the artist
  final String uri;

  /// Known external URLs for this artist
  @JsonKey(name: 'external_urls')
  final SpotifyExternalUrls? externalUrls;

  /// A link to the Web API endpoint providing full details
  final String? href;

  /// The object type (artist)
  final String? type;

  /// A list of genres the artist is associated with
  final List<String>? genres;

  /// Images of the artist in various sizes
  final List<SpotifyImage>? images;

  /// The popularity of the artist (0-100)
  final int? popularity;

  /// Information about followers
  final SpotifyFollowers? followers;

  const SpotifyArtist({
    required this.id,
    required this.name,
    required this.uri,
    this.externalUrls,
    this.href,
    this.type,
    this.genres,
    this.images,
    this.popularity,
    this.followers,
  });

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) =>
      _$SpotifyArtistFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyArtistToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        uri,
        externalUrls,
        href,
        type,
        genres,
        images,
        popularity,
        followers,
      ];
}

