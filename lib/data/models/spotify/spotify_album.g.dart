// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyAlbum _$SpotifyAlbumFromJson(Map<String, dynamic> json) => SpotifyAlbum(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      albumType: json['album_type'] as String,
      artists: (json['artists'] as List<dynamic>)
          .map((e) => SpotifyArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>)
          .map((e) => SpotifyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      releaseDate: json['release_date'] as String,
      releaseDatePrecision: json['release_date_precision'] as String,
      totalTracks: (json['total_tracks'] as num).toInt(),
      availableMarkets: (json['available_markets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      externalUrls: json['external_urls'] == null
          ? null
          : SpotifyExternalUrls.fromJson(
              json['external_urls'] as Map<String, dynamic>),
      href: json['href'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$SpotifyAlbumToJson(SpotifyAlbum instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'uri': instance.uri,
      'album_type': instance.albumType,
      'artists': instance.artists,
      'available_markets': instance.availableMarkets,
      'external_urls': instance.externalUrls,
      'href': instance.href,
      'images': instance.images,
      'release_date': instance.releaseDate,
      'release_date_precision': instance.releaseDatePrecision,
      'total_tracks': instance.totalTracks,
      'type': instance.type,
    };
