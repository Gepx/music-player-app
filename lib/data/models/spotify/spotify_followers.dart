import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'spotify_followers.g.dart';

/// Spotify Followers
/// Information about followers
@JsonSerializable()
class SpotifyFollowers extends Equatable {
  /// A link to the Web API endpoint providing full details (always null)
  final String? href;

  /// The total number of followers
  final int total;

  const SpotifyFollowers({
    this.href,
    required this.total,
  });

  factory SpotifyFollowers.fromJson(Map<String, dynamic> json) =>
      _$SpotifyFollowersFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyFollowersToJson(this);

  @override
  List<Object?> get props => [href, total];
}

