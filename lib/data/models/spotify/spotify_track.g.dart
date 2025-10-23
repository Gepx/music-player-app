// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyTrack _$SpotifyTrackFromJson(Map<String, dynamic> json) => SpotifyTrack(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      artists: (json['artists'] as List<dynamic>)
          .map((e) => SpotifyArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
      durationMs: (json['duration_ms'] as num).toInt(),
      explicit: json['explicit'] as bool,
      album: json['album'] == null
          ? null
          : SpotifyAlbum.fromJson(json['album'] as Map<String, dynamic>),
      externalUrls: json['external_urls'] == null
          ? null
          : SpotifyExternalUrls.fromJson(
              json['external_urls'] as Map<String, dynamic>),
      href: json['href'] as String?,
      popularity: (json['popularity'] as num?)?.toInt(),
      previewUrl: json['preview_url'] as String?,
      trackNumber: (json['track_number'] as num?)?.toInt(),
      type: json['type'] as String?,
      isLocal: json['is_local'] as bool?,
      isPlayable: json['is_playable'] as bool?,
      discNumber: (json['disc_number'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SpotifyTrackToJson(SpotifyTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'uri': instance.uri,
      'artists': instance.artists,
      'album': instance.album,
      'duration_ms': instance.durationMs,
      'explicit': instance.explicit,
      'external_urls': instance.externalUrls,
      'href': instance.href,
      'popularity': instance.popularity,
      'preview_url': instance.previewUrl,
      'track_number': instance.trackNumber,
      'type': instance.type,
      'is_local': instance.isLocal,
      'is_playable': instance.isPlayable,
      'disc_number': instance.discNumber,
    };
