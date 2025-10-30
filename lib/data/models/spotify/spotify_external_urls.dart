import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'spotify_external_urls.g.dart';

/// Spotify External URLs
/// Known external URLs for a Spotify object
@JsonSerializable()
class SpotifyExternalUrls extends Equatable {
  /// The Spotify URL for the object
  final String? spotify;

  const SpotifyExternalUrls({this.spotify});

  factory SpotifyExternalUrls.fromJson(Map<String, dynamic> json) =>
      _$SpotifyExternalUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyExternalUrlsToJson(this);

  @override
  List<Object?> get props => [spotify];
}

