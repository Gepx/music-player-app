// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyUser _$SpotifyUserFromJson(Map<String, dynamic> json) => SpotifyUser(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      uri: json['uri'] as String,
      externalUrls: json['external_urls'] == null
          ? null
          : SpotifyExternalUrls.fromJson(
              json['external_urls'] as Map<String, dynamic>),
      followers: json['followers'] == null
          ? null
          : SpotifyFollowers.fromJson(
              json['followers'] as Map<String, dynamic>),
      href: json['href'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => SpotifyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: json['type'] as String?,
      product: json['product'] as String?,
      country: json['country'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$SpotifyUserToJson(SpotifyUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display_name': instance.displayName,
      'uri': instance.uri,
      'external_urls': instance.externalUrls,
      'followers': instance.followers,
      'href': instance.href,
      'images': instance.images,
      'type': instance.type,
      'product': instance.product,
      'country': instance.country,
      'email': instance.email,
    };
