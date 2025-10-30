import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'spotify_image.g.dart';

/// Spotify Image Model
/// Represents an image in various sizes
@JsonSerializable()
class SpotifyImage extends Equatable {
  /// Image URL
  final String url;

  /// Image height in pixels (nullable for dynamic sizes)
  final int? height;

  /// Image width in pixels (nullable for dynamic sizes)
  final int? width;

  const SpotifyImage({
    required this.url,
    this.height,
    this.width,
  });

  factory SpotifyImage.fromJson(Map<String, dynamic> json) =>
      _$SpotifyImageFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyImageToJson(this);

  @override
  List<Object?> get props => [url, height, width];
}

