import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'track_model.g.dart';

/// App's Internal Track Model
/// Represents a track in the app (can come from Spotify or local storage)
@HiveType(typeId: 0)
class TrackModel extends Equatable {
  /// Internal app ID
  @HiveField(0)
  final String id;

  /// Spotify ID (if from Spotify)
  @HiveField(1)
  final String? spotifyId;

  /// Track title
  @HiveField(2)
  final String title;

  /// Artist name
  @HiveField(3)
  final String artistName;

  /// Artist ID
  @HiveField(4)
  final String? artistId;

  /// Album name
  @HiveField(5)
  final String albumName;

  /// Album ID
  @HiveField(6)
  final String? albumId;

  /// Album art URL
  @HiveField(7)
  final String? albumArtUrl;

  /// Track duration
  @HiveField(8)
  final int durationMs;

  /// Stream URL (preview URL from Spotify or full URL from storage)
  @HiveField(9)
  final String? streamUrl;

  /// Is this track marked as favorite?
  @HiveField(10)
  final bool isFavorite;

  /// When was this track added to library?
  @HiveField(11)
  final DateTime? addedAt;

  /// Play count
  @HiveField(12)
  final int playCount;

  /// Is this track downloaded locally?
  @HiveField(13)
  final bool isDownloaded;

  /// Local file path (if downloaded)
  @HiveField(14)
  final String? localPath;

  /// Track popularity (0-100)
  @HiveField(15)
  final int? popularity;

  /// Is explicit content?
  @HiveField(16)
  final bool explicit;

  /// Spotify URI
  @HiveField(17)
  final String? uri;

  const TrackModel({
    required this.id,
    this.spotifyId,
    required this.title,
    required this.artistName,
    this.artistId,
    required this.albumName,
    this.albumId,
    this.albumArtUrl,
    required this.durationMs,
    this.streamUrl,
    this.isFavorite = false,
    this.addedAt,
    this.playCount = 0,
    this.isDownloaded = false,
    this.localPath,
    this.popularity,
    this.explicit = false,
    this.uri,
  });

  /// Get duration as Duration object
  Duration get duration => Duration(milliseconds: durationMs);

  /// Get formatted duration (mm:ss)
  String get formattedDuration {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if track has a playable URL
  bool get isPlayable => streamUrl != null && streamUrl!.isNotEmpty;

  /// Copy with method
  TrackModel copyWith({
    String? id,
    String? spotifyId,
    String? title,
    String? artistName,
    String? artistId,
    String? albumName,
    String? albumId,
    String? albumArtUrl,
    int? durationMs,
    String? streamUrl,
    bool? isFavorite,
    DateTime? addedAt,
    int? playCount,
    bool? isDownloaded,
    String? localPath,
    int? popularity,
    bool? explicit,
    String? uri,
  }) {
    return TrackModel(
      id: id ?? this.id,
      spotifyId: spotifyId ?? this.spotifyId,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      artistId: artistId ?? this.artistId,
      albumName: albumName ?? this.albumName,
      albumId: albumId ?? this.albumId,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      durationMs: durationMs ?? this.durationMs,
      streamUrl: streamUrl ?? this.streamUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      addedAt: addedAt ?? this.addedAt,
      playCount: playCount ?? this.playCount,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
      popularity: popularity ?? this.popularity,
      explicit: explicit ?? this.explicit,
      uri: uri ?? this.uri,
    );
  }

  @override
  List<Object?> get props => [
        id,
        spotifyId,
        title,
        artistName,
        artistId,
        albumName,
        albumId,
        albumArtUrl,
        durationMs,
        streamUrl,
        isFavorite,
        addedAt,
        playCount,
        isDownloaded,
        localPath,
        popularity,
        explicit,
        uri,
      ];
}

