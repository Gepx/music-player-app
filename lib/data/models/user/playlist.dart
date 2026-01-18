import 'package:flutter/foundation.dart';

/// User Playlist Model
/// Represents a user-created playlist with tracks
class Playlist {
  final String id;
  final String name;
  final String? description;
  final String userId;
  final List<String> trackIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final String syncStatus; // 'synced', 'pending', 'error'

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.trackIds,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.syncStatus = 'synced',
  });

  /// Get track count
  int get trackCount => trackIds.length;

  /// Determine cover type based on track count
  /// 'grid' for 4+ tracks (2x2 grid), 'single' for 1-3 tracks, 'placeholder' for 0
  String get coverType {
    if (trackIds.isEmpty) return 'placeholder';
    if (trackIds.length >= 4) return 'grid';
    return 'single';
  }

  /// Get first 4 track IDs for cover grid
  List<String> get coverTrackIds => trackIds.take(4).toList();

  /// Create from JSON (Firebase)
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      userId: json['userId'] as String,
      trackIds: (json['trackIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : DateTime.parse(json['updatedAt'] as String),
      isPublic: json['isPublic'] as bool? ?? false,
      syncStatus: json['syncStatus'] as String? ?? 'synced',
    );
  }

  /// Convert to JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'trackIds': trackIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isPublic': isPublic,
      'syncStatus': syncStatus,
    };
  }

  /// Create from database (sqflite)
  factory Playlist.fromDb(Map<String, dynamic> db) {
    return Playlist(
      id: db['id'] as String,
      name: db['name'] as String,
      description: db['description'] as String?,
      userId: db['userId'] as String,
      trackIds: (db['trackIds'] as String?)
              ?.split(',')
              .where((id) => id.isNotEmpty)
              .toList() ??
          [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(db['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(db['updatedAt'] as int),
      isPublic: (db['isPublic'] as int) == 1,
      syncStatus: db['syncStatus'] as String? ?? 'synced',
    );
  }

  /// Convert to database (sqflite)
  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'trackIds': trackIds.join(','),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isPublic': isPublic ? 1 : 0,
      'syncStatus': syncStatus,
    };
  }

  /// Copy with modifications
  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    List<String>? trackIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    String? syncStatus,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist &&
        other.id == id &&
        other.name == name &&
        listEquals(other.trackIds, trackIds);
  }

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(trackIds));

  @override
  String toString() => 'Playlist(id: $id, name: $name, tracks: $trackCount)';
}

