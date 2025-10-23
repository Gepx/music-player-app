// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyPlaylist _$SpotifyPlaylistFromJson(Map<String, dynamic> json) =>
    SpotifyPlaylist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      uri: json['uri'] as String,
      owner: SpotifyUser.fromJson(json['owner'] as Map<String, dynamic>),
      snapshotId: json['snapshot_id'] as String,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => SpotifyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      public: json['public'] as bool?,
      collaborative: json['collaborative'] as bool?,
      externalUrls: json['external_urls'] == null
          ? null
          : SpotifyExternalUrls.fromJson(
              json['external_urls'] as Map<String, dynamic>),
      href: json['href'] as String?,
      followers: json['followers'] == null
          ? null
          : SpotifyFollowers.fromJson(
              json['followers'] as Map<String, dynamic>),
      type: json['type'] as String?,
      tracks: json['tracks'] == null
          ? null
          : PlaylistTracks.fromJson(json['tracks'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SpotifyPlaylistToJson(SpotifyPlaylist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'uri': instance.uri,
      'owner': instance.owner,
      'images': instance.images,
      'public': instance.public,
      'collaborative': instance.collaborative,
      'external_urls': instance.externalUrls,
      'href': instance.href,
      'followers': instance.followers,
      'snapshot_id': instance.snapshotId,
      'type': instance.type,
      'tracks': instance.tracks,
    };

PlaylistTracks _$PlaylistTracksFromJson(Map<String, dynamic> json) =>
    PlaylistTracks(
      href: json['href'] as String?,
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$PlaylistTracksToJson(PlaylistTracks instance) =>
    <String, dynamic>{
      'href': instance.href,
      'total': instance.total,
    };
