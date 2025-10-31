import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'artist_model.g.dart';

/// App's Internal Artist Model
@HiveType(typeId: 2)
class ArtistModel extends Equatable {
  /// Internal app ID
  @HiveField(0)
  final String id;

  /// Spotify ID
  @HiveField(1)
  final String? spotifyId;

  /// Artist name
  @HiveField(2)
  final String name;

  /// Artist image URL
  @HiveField(3)
  final String? imageUrl;

  /// Genres
  @HiveField(4)
  final List<String> genres;

  /// Is following this artist?
  @HiveField(5)
  final bool isFollowing;

  /// Number of tracks (in user's library from this artist)
  @HiveField(6)
  final int trackCount;

  /// Number of albums (in user's library from this artist)
  @HiveField(7)
  final int albumCount;

  /// Popularity (0-100)
  @HiveField(8)
  final int? popularity;

  /// Number of followers
  @HiveField(9)
  final int? followers;

  /// Spotify URI
  @HiveField(10)
  final String? uri;

  const ArtistModel({
    required this.id,
    this.spotifyId,
    required this.name,
    this.imageUrl,
    this.genres = const [],
    this.isFollowing = false,
    this.trackCount = 0,
    this.albumCount = 0,
    this.popularity,
    this.followers,
    this.uri,
  });

  /// Copy with method
  ArtistModel copyWith({
    String? id,
    String? spotifyId,
    String? name,
    String? imageUrl,
    List<String>? genres,
    bool? isFollowing,
    int? trackCount,
    int? albumCount,
    int? popularity,
    int? followers,
    String? uri,
  }) {
    return ArtistModel(
      id: id ?? this.id,
      spotifyId: spotifyId ?? this.spotifyId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      genres: genres ?? this.genres,
      isFollowing: isFollowing ?? this.isFollowing,
      trackCount: trackCount ?? this.trackCount,
      albumCount: albumCount ?? this.albumCount,
      popularity: popularity ?? this.popularity,
      followers: followers ?? this.followers,
      uri: uri ?? this.uri,
    );
  }

  @override
  List<Object?> get props => [
        id,
        spotifyId,
        name,
        imageUrl,
        genres,
        isFollowing,
        trackCount,
        albumCount,
        popularity,
        followers,
        uri,
      ];

  // -------------------- SQLite Serialization -------------------- //

  /// Convert to SQLite map
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'spotify_id': spotifyId ?? id,
      'name': name,
      'image_url': imageUrl,
      'genres': jsonEncode(genres), // Store as JSON string
      'popularity': popularity ?? 0,
      'followers': followers ?? 0,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Create from SQLite map
  factory ArtistModel.fromSQLite(Map<String, dynamic> map) {
    List<String> parsedGenres = [];
    if (map['genres'] != null) {
      try {
        final decoded = jsonDecode(map['genres'] as String);
        if (decoded is List) {
          parsedGenres = decoded.cast<String>();
        }
      } catch (e) {
        // If JSON parsing fails, fallback to empty list
        parsedGenres = [];
      }
    }

    return ArtistModel(
      id: map['id'] as String,
      spotifyId: map['spotify_id'] as String?,
      name: map['name'] as String,
      imageUrl: map['image_url'] as String?,
      genres: parsedGenres,
      popularity: map['popularity'] as int?,
      followers: map['followers'] as int?,
    );
  }
}

