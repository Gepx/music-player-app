import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'album_model.g.dart';

/// App's Internal Album Model
@HiveType(typeId: 1)
class AlbumModel extends Equatable {
  /// Internal app ID
  @HiveField(0)
  final String id;

  /// Spotify ID
  @HiveField(1)
  final String? spotifyId;

  /// Album title
  @HiveField(2)
  final String title;

  /// Artist name
  @HiveField(3)
  final String artistName;

  /// Artist ID
  @HiveField(4)
  final String? artistId;

  /// Cover art URL
  @HiveField(5)
  final String? coverArtUrl;

  /// Release date
  @HiveField(6)
  final DateTime releaseDate;

  /// Total number of tracks
  @HiveField(7)
  final int totalTracks;

  /// Track IDs in this album
  @HiveField(8)
  final List<String> trackIds;

  /// Is this album saved to library?
  @HiveField(9)
  final bool isSaved;

  /// Album type (album, single, compilation)
  @HiveField(10)
  final String albumType;

  /// Spotify URI
  @HiveField(11)
  final String? uri;

  const AlbumModel({
    required this.id,
    this.spotifyId,
    required this.title,
    required this.artistName,
    this.artistId,
    this.coverArtUrl,
    required this.releaseDate,
    required this.totalTracks,
    this.trackIds = const [],
    this.isSaved = false,
    this.albumType = 'album',
    this.uri,
  });

  /// Get release year
  int get releaseYear => releaseDate.year;

  /// Copy with method
  AlbumModel copyWith({
    String? id,
    String? spotifyId,
    String? title,
    String? artistName,
    String? artistId,
    String? coverArtUrl,
    DateTime? releaseDate,
    int? totalTracks,
    List<String>? trackIds,
    bool? isSaved,
    String? albumType,
    String? uri,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      spotifyId: spotifyId ?? this.spotifyId,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      artistId: artistId ?? this.artistId,
      coverArtUrl: coverArtUrl ?? this.coverArtUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      totalTracks: totalTracks ?? this.totalTracks,
      trackIds: trackIds ?? this.trackIds,
      isSaved: isSaved ?? this.isSaved,
      albumType: albumType ?? this.albumType,
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
        coverArtUrl,
        releaseDate,
        totalTracks,
        trackIds,
        isSaved,
        albumType,
        uri,
      ];

  // -------------------- SQLite Serialization -------------------- //

  /// Convert to SQLite map
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'spotify_id': spotifyId ?? id,
      'title': title,
      'artist_name': artistName,
      'release_date': releaseDate.toIso8601String(),
      'total_tracks': totalTracks,
      'image_url': coverArtUrl,
      'album_type': albumType,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Create from SQLite map
  factory AlbumModel.fromSQLite(Map<String, dynamic> map) {
    return AlbumModel(
      id: map['id'] as String,
      spotifyId: map['spotify_id'] as String?,
      title: map['title'] as String,
      artistName: map['artist_name'] as String? ?? 'Unknown Artist',
      coverArtUrl: map['image_url'] as String?,
      releaseDate: map['release_date'] != null
          ? DateTime.parse(map['release_date'] as String)
          : DateTime.now(),
      totalTracks: map['total_tracks'] as int? ?? 0,
      albumType: map['album_type'] as String? ?? 'album',
    );
  }
}

