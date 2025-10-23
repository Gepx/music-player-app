// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyArtist _$SpotifyArtistFromJson(Map<String, dynamic> json) =>
    SpotifyArtist(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      externalUrls: json['external_urls'] == null
          ? null
          : SpotifyExternalUrls.fromJson(
              json['external_urls'] as Map<String, dynamic>),
      href: json['href'] as String?,
      type: json['type'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => SpotifyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularity: (json['popularity'] as num?)?.toInt(),
      followers: json['followers'] == null
          ? null
          : SpotifyFollowers.fromJson(
              json['followers'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SpotifyArtistToJson(SpotifyArtist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'uri': instance.uri,
      'external_urls': instance.externalUrls,
      'href': instance.href,
      'type': instance.type,
      'genres': instance.genres,
      'images': instance.images,
      'popularity': instance.popularity,
      'followers': instance.followers,
    };
