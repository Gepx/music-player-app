// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_audio_features.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyAudioFeatures _$SpotifyAudioFeaturesFromJson(
        Map<String, dynamic> json) =>
    SpotifyAudioFeatures(
      id: json['id'] as String,
      acousticness: (json['acousticness'] as num).toDouble(),
      danceability: (json['danceability'] as num).toDouble(),
      energy: (json['energy'] as num).toDouble(),
      instrumentalness: (json['instrumentalness'] as num).toDouble(),
      liveness: (json['liveness'] as num).toDouble(),
      loudness: (json['loudness'] as num).toDouble(),
      speechiness: (json['speechiness'] as num).toDouble(),
      valence: (json['valence'] as num).toDouble(),
      tempo: (json['tempo'] as num).toDouble(),
      key: (json['key'] as num).toInt(),
      mode: (json['mode'] as num).toInt(),
      timeSignature: (json['time_signature'] as num).toInt(),
      durationMs: (json['duration_ms'] as num).toInt(),
      type: json['type'] as String?,
      uri: json['uri'] as String?,
      trackHref: json['track_href'] as String?,
      analysisUrl: json['analysis_url'] as String?,
    );

Map<String, dynamic> _$SpotifyAudioFeaturesToJson(
        SpotifyAudioFeatures instance) =>
    <String, dynamic>{
      'id': instance.id,
      'acousticness': instance.acousticness,
      'danceability': instance.danceability,
      'energy': instance.energy,
      'instrumentalness': instance.instrumentalness,
      'liveness': instance.liveness,
      'loudness': instance.loudness,
      'speechiness': instance.speechiness,
      'valence': instance.valence,
      'tempo': instance.tempo,
      'key': instance.key,
      'mode': instance.mode,
      'time_signature': instance.timeSignature,
      'duration_ms': instance.durationMs,
      'type': instance.type,
      'uri': instance.uri,
      'track_href': instance.trackHref,
      'analysis_url': instance.analysisUrl,
    };
