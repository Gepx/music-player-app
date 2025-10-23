// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifySearchResult _$SpotifySearchResultFromJson(Map<String, dynamic> json) =>
    SpotifySearchResult(
      tracks: json['tracks'] == null
          ? null
          : PagingDto<SpotifyTrack>.fromJson(
              json['tracks'] as Map<String, dynamic>,
              (value) => SpotifyTrack.fromJson(value as Map<String, dynamic>)),
      albums: json['albums'] == null
          ? null
          : PagingDto<SpotifyAlbum>.fromJson(
              json['albums'] as Map<String, dynamic>,
              (value) => SpotifyAlbum.fromJson(value as Map<String, dynamic>)),
      artists: json['artists'] == null
          ? null
          : PagingDto<SpotifyArtist>.fromJson(
              json['artists'] as Map<String, dynamic>,
              (value) => SpotifyArtist.fromJson(value as Map<String, dynamic>)),
      playlists: json['playlists'] == null
          ? null
          : PagingDto<SpotifyPlaylist>.fromJson(
              json['playlists'] as Map<String, dynamic>,
              (value) =>
                  SpotifyPlaylist.fromJson(value as Map<String, dynamic>)),
    );

Map<String, dynamic> _$SpotifySearchResultToJson(
        SpotifySearchResult instance) =>
    <String, dynamic>{
      'tracks': instance.tracks?.toJson(
        (value) => value,
      ),
      'albums': instance.albums?.toJson(
        (value) => value,
      ),
      'artists': instance.artists?.toJson(
        (value) => value,
      ),
      'playlists': instance.playlists?.toJson(
        (value) => value,
      ),
    };
