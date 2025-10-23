// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paging_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PagingDto<T> _$PagingDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PagingDto<T>(
      href: json['href'] as String?,
      items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
      limit: (json['limit'] as num).toInt(),
      next: json['next'] as String?,
      offset: (json['offset'] as num).toInt(),
      previous: json['previous'] as String?,
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$PagingDtoToJson<T>(
  PagingDto<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'href': instance.href,
      'items': instance.items.map(toJsonT).toList(),
      'limit': instance.limit,
      'next': instance.next,
      'offset': instance.offset,
      'previous': instance.previous,
      'total': instance.total,
    };
