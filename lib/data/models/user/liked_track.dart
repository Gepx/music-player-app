import '../spotify/spotify_track.dart';

/// Liked Track Model
/// Represents a track that the user has liked
class LikedTrack {
  final String trackId;
  final String userId;
  final DateTime likedAt;
  final String syncStatus; // 'synced', 'pending', 'error'
  
  // Cached track metadata (optional)
  final String? name;
  final String? artist;
  final String? album;
  final String? imageUrl;
  final int? durationMs;

  const LikedTrack({
    required this.trackId,
    required this.userId,
    required this.likedAt,
    this.syncStatus = 'synced',
    this.name,
    this.artist,
    this.album,
    this.imageUrl,
    this.durationMs,
  });

  /// Create from Spotify track
  factory LikedTrack.fromSpotifyTrack(SpotifyTrack track, String userId) {
    return LikedTrack(
      trackId: track.id,
      userId: userId,
      likedAt: DateTime.now(),
      syncStatus: 'pending',
      name: track.name,
      artist: track.artists.map((a) => a.name).join(', '),
      album: track.album?.name,
      imageUrl: track.album?.images.isNotEmpty == true
          ? track.album!.images.first.url
          : null,
      durationMs: track.durationMs,
    );
  }

  /// Create from JSON (Firebase)
  factory LikedTrack.fromJson(Map<String, dynamic> json) {
    return LikedTrack(
      trackId: json['trackId'] as String,
      userId: json['userId'] as String,
      likedAt: json['likedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['likedAt'] as int)
          : DateTime.parse(json['likedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      name: json['name'] as String?,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      imageUrl: json['imageUrl'] as String?,
      durationMs: json['durationMs'] as int?,
    );
  }

  /// Convert to JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'userId': userId,
      'likedAt': likedAt.millisecondsSinceEpoch,
      'syncStatus': syncStatus,
      if (name != null) 'name': name,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (durationMs != null) 'durationMs': durationMs,
    };
  }

  /// Create from database (sqflite)
  factory LikedTrack.fromDb(Map<String, dynamic> db) {
    return LikedTrack(
      trackId: db['trackId'] as String,
      userId: db['userId'] as String,
      likedAt: DateTime.fromMillisecondsSinceEpoch(db['likedAt'] as int),
      syncStatus: db['syncStatus'] as String? ?? 'synced',
      name: db['name'] as String?,
      artist: db['artist'] as String?,
      album: db['album'] as String?,
      imageUrl: db['imageUrl'] as String?,
      durationMs: db['durationMs'] as int?,
    );
  }

  /// Convert to database (sqflite)
  Map<String, dynamic> toDb() {
    return {
      'trackId': trackId,
      'userId': userId,
      'likedAt': likedAt.millisecondsSinceEpoch,
      'syncStatus': syncStatus,
      'name': name,
      'artist': artist,
      'album': album,
      'imageUrl': imageUrl,
      'durationMs': durationMs,
    };
  }

  /// Copy with modifications
  LikedTrack copyWith({
    String? trackId,
    String? userId,
    DateTime? likedAt,
    String? syncStatus,
    String? name,
    String? artist,
    String? album,
    String? imageUrl,
    int? durationMs,
  }) {
    return LikedTrack(
      trackId: trackId ?? this.trackId,
      userId: userId ?? this.userId,
      likedAt: likedAt ?? this.likedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      imageUrl: imageUrl ?? this.imageUrl,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LikedTrack &&
        other.trackId == trackId &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(trackId, userId);

  @override
  String toString() => 'LikedTrack(trackId: $trackId, name: $name)';
}

