// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_auth_tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyAuthTokens _$SpotifyAuthTokensFromJson(Map<String, dynamic> json) =>
    SpotifyAuthTokens(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      refreshToken: json['refresh_token'] as String?,
      scope: json['scope'] as String?,
    );

Map<String, dynamic> _$SpotifyAuthTokensToJson(SpotifyAuthTokens instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'refresh_token': instance.refreshToken,
      'scope': instance.scope,
    };
