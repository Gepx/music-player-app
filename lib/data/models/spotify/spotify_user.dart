import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'spotify_image.dart';
import 'spotify_external_urls.dart';
import 'spotify_followers.dart';

part 'spotify_user.g.dart';

/// Spotify User Model
/// Represents a Spotify user
@JsonSerializable()
class SpotifyUser extends Equatable {
  /// The Spotify user ID
  final String id;

  /// The name displayed on the user's profile
  @JsonKey(name: 'display_name')
  final String? displayName;

  /// The Spotify URI for the user
  final String uri;

  /// Known external URLs for this user
  @JsonKey(name: 'external_urls')
  final SpotifyExternalUrls? externalUrls;

  /// Information about the followers of the user
  final SpotifyFollowers? followers;

  /// A link to the Web API endpoint for this user
  final String? href;

  /// The user's profile image
  final List<SpotifyImage>? images;

  /// The object type (user)
  final String? type;

  /// The Spotify subscription level (premium, free, etc.)
  final String? product;

  /// The country of the user
  final String? country;

  /// The user's email address
  final String? email;

  const SpotifyUser({
    required this.id,
    this.displayName,
    required this.uri,
    this.externalUrls,
    this.followers,
    this.href,
    this.images,
    this.type,
    this.product,
    this.country,
    this.email,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) =>
      _$SpotifyUserFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyUserToJson(this);

  @override
  List<Object?> get props => [
        id,
        displayName,
        uri,
        externalUrls,
        followers,
        href,
        images,
        type,
        product,
        country,
        email,
      ];
}

