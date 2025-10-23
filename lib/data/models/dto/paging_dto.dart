import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'paging_dto.g.dart';

/// Paging DTO
/// Generic paging wrapper for Spotify API responses
@JsonSerializable(genericArgumentFactories: true)
class PagingDto<T> extends Equatable {
  /// A link to the Web API endpoint returning the full result
  final String? href;

  /// The requested data
  final List<T> items;

  /// The maximum number of items in the response
  final int limit;

  /// URL to the next page of items (null if none)
  final String? next;

  /// The offset of the items returned
  final int offset;

  /// URL to the previous page of items (null if none)
  final String? previous;

  /// The total number of items available to return
  final int total;

  const PagingDto({
    this.href,
    required this.items,
    required this.limit,
    this.next,
    required this.offset,
    this.previous,
    required this.total,
  });

  factory PagingDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PagingDtoFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PagingDtoToJson(this, toJsonT);

  /// Check if there are more items
  bool get hasMore => next != null;

  /// Check if this is the first page
  bool get isFirstPage => previous == null && offset == 0;

  /// Check if this is the last page
  bool get isLastPage => next == null;

  @override
  List<Object?> get props => [href, items, limit, next, offset, previous, total];
}

