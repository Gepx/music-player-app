import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'spotify_auth_tokens.g.dart';

/// Spotify Authentication Tokens
/// Contains OAuth 2.0 tokens for Spotify API access
@JsonSerializable()
class SpotifyAuthTokens extends Equatable {
  /// The access token
  @JsonKey(name: 'access_token')
  final String accessToken;

  /// The type of token (Bearer)
  @JsonKey(name: 'token_type')
  final String tokenType;

  /// The time in seconds until the access token expires
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  /// The refresh token (used to get a new access token)
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  /// The scope granted to the access token
  final String? scope;

  /// Timestamp when the token was created (for expiry calculation)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? createdAt;

  const SpotifyAuthTokens({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.refreshToken,
    this.scope,
    this.createdAt,
  });

  factory SpotifyAuthTokens.fromJson(Map<String, dynamic> json) {
    return _$SpotifyAuthTokensFromJson(json).copyWith(
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$SpotifyAuthTokensToJson(this);

  /// Check if the access token is expired
  bool get isExpired {
    if (createdAt == null) return true;
    final expiryTime = createdAt!.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expiryTime);
  }

  /// Check if the token will expire soon (within 5 minutes)
  bool get willExpireSoon {
    if (createdAt == null) return true;
    final expiryTime = createdAt!.add(Duration(seconds: expiresIn));
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiryTime);
  }

  /// Copy with method
  SpotifyAuthTokens copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    String? refreshToken,
    String? scope,
    DateTime? createdAt,
  }) {
    return SpotifyAuthTokens(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      refreshToken: refreshToken ?? this.refreshToken,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        accessToken,
        tokenType,
        expiresIn,
        refreshToken,
        scope,
        createdAt,
      ];
}

