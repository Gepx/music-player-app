// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyImage _$SpotifyImageFromJson(Map<String, dynamic> json) => SpotifyImage(
      url: json['url'] as String,
      height: (json['height'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SpotifyImageToJson(SpotifyImage instance) =>
    <String, dynamic>{
      'url': instance.url,
      'height': instance.height,
      'width': instance.width,
    };
