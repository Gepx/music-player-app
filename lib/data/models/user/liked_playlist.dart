import 'package:music_player/data/models/user/playlist.dart';

/// Liked Playlist Model
/// Represents a playlist that the user has liked
class LikedPlaylist {
  final String playlistId;
  final String userId;
  final DateTime likedAt;
  final String syncStatus; // 'synced', 'pending', 'error'

  // Cached playlist metadata (optional)
  final String? name;
  final String? description;
  final List<String>? trackIds;
  final bool? isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LikedPlaylist({
    required this.playlistId,
    required this.userId,
    required this.likedAt,
    this.syncStatus = 'synced',
    this.name,
    this.description,
    this.trackIds,
    this.isPublic,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from Playlist
  factory LikedPlaylist.fromPlaylist(Playlist playlist, String userId) {
    return LikedPlaylist(
      playlistId: playlist.id,
      userId: userId,
      likedAt: DateTime.now(),
      syncStatus: 'pending',
      name: playlist.name,
      description: playlist.description,
      trackIds: playlist.trackIds,
      isPublic: playlist.isPublic,
      createdAt: playlist.createdAt,
      updatedAt: playlist.updatedAt,
    );
  }

  /// Create from JSON (Firebase/web storage)
  factory LikedPlaylist.fromJson(Map<String, dynamic> json) {
    return LikedPlaylist(
      playlistId: json['playlistId'] as String,
      userId: json['userId'] as String,
      likedAt: json['likedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['likedAt'] as int)
          : DateTime.parse(json['likedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      name: json['name'] as String?,
      description: json['description'] as String?,
      trackIds: (json['trackIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isPublic: json['isPublic'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : json['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
              : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : json['updatedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
              : DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON (Firebase/web storage)
  Map<String, dynamic> toJson() {
    return {
      'playlistId': playlistId,
      'userId': userId,
      'likedAt': likedAt.millisecondsSinceEpoch,
      'syncStatus': syncStatus,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (trackIds != null) 'trackIds': trackIds,
      if (isPublic != null) 'isPublic': isPublic,
      if (createdAt != null) 'createdAt': createdAt!.millisecondsSinceEpoch,
      if (updatedAt != null) 'updatedAt': updatedAt!.millisecondsSinceEpoch,
    };
  }

  /// Create from database (sqflite)
  factory LikedPlaylist.fromDb(Map<String, dynamic> db) {
    return LikedPlaylist(
      playlistId: db['playlistId'] as String,
      userId: db['userId'] as String,
      likedAt: DateTime.fromMillisecondsSinceEpoch(db['likedAt'] as int),
      syncStatus: db['syncStatus'] as String? ?? 'synced',
      name: db['name'] as String?,
      description: db['description'] as String?,
      trackIds: (db['trackIds'] as String?)
          ?.split(',')
          .where((id) => id.isNotEmpty)
          .toList(),
      isPublic: (db['isPublic'] as int?) == 1,
      createdAt: db['createdAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(db['createdAt'] as int),
      updatedAt: db['updatedAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(db['updatedAt'] as int),
    );
  }

  /// Convert to database (sqflite)
  Map<String, dynamic> toDb() {
    return {
      'playlistId': playlistId,
      'userId': userId,
      'likedAt': likedAt.millisecondsSinceEpoch,
      'syncStatus': syncStatus,
      'name': name,
      'description': description,
      'trackIds': (trackIds ?? []).join(','),
      'isPublic': (isPublic ?? false) ? 1 : 0,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  LikedPlaylist copyWith({
    String? playlistId,
    String? userId,
    DateTime? likedAt,
    String? syncStatus,
    String? name,
    String? description,
    List<String>? trackIds,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LikedPlaylist(
      playlistId: playlistId ?? this.playlistId,
      userId: userId ?? this.userId,
      likedAt: likedAt ?? this.likedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      description: description ?? this.description,
      trackIds: trackIds ?? this.trackIds,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LikedPlaylist &&
        other.playlistId == playlistId &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(playlistId, userId);
}
