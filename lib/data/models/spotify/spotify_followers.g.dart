// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_followers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyFollowers _$SpotifyFollowersFromJson(Map<String, dynamic> json) =>
    SpotifyFollowers(
      href: json['href'] as String?,
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$SpotifyFollowersToJson(SpotifyFollowers instance) =>
    <String, dynamic>{
      'href': instance.href,
      'total': instance.total,
    };
