import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'playlist_model.g.dart';

/// App's Internal Playlist Model
@HiveType(typeId: 3)
class PlaylistModel extends Equatable {
  /// Internal app ID
  @HiveField(0)
  final String id;

  /// Spotify ID (if from Spotify)
  @HiveField(1)
  final String? spotifyId;

  /// Playlist name
  @HiveField(2)
  final String name;

  /// Playlist description
  @HiveField(3)
  final String? description;

  /// Cover image URL
  @HiveField(4)
  final String? coverUrl;

  /// User ID of the owner
  @HiveField(5)
  final String ownerId;

  /// Owner name
  @HiveField(6)
  final String ownerName;

  /// Track IDs in this playlist
  @HiveField(7)
  final List<String> trackIds;

  /// Is this a public playlist?
  @HiveField(8)
  final bool isPublic;

  /// Is this a collaborative playlist?
  @HiveField(9)
  final bool isCollaborative;

  /// Created at
  @HiveField(10)
  final DateTime createdAt;

  /// Updated at
  @HiveField(11)
  final DateTime updatedAt;

  /// Is this playlist from Spotify or created locally?
  @HiveField(12)
  final bool isFromSpotify;

  /// Spotify URI
  @HiveField(13)
  final String? uri;

  const PlaylistModel({
    required this.id,
    this.spotifyId,
    required this.name,
    this.description,
    this.coverUrl,
    required this.ownerId,
    required this.ownerName,
    this.trackIds = const [],
    this.isPublic = false,
    this.isCollaborative = false,
    required this.createdAt,
    required this.updatedAt,
    this.isFromSpotify = false,
    this.uri,
  });

  /// Get total tracks
  int get totalTracks => trackIds.length;

  /// Check if empty
  bool get isEmpty => trackIds.isEmpty;

  /// Copy with method
  PlaylistModel copyWith({
    String? id,
    String? spotifyId,
    String? name,
    String? description,
    String? coverUrl,
    String? ownerId,
    String? ownerName,
    List<String>? trackIds,
    bool? isPublic,
    bool? isCollaborative,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFromSpotify,
    String? uri,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      spotifyId: spotifyId ?? this.spotifyId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      trackIds: trackIds ?? this.trackIds,
      isPublic: isPublic ?? this.isPublic,
      isCollaborative: isCollaborative ?? this.isCollaborative,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFromSpotify: isFromSpotify ?? this.isFromSpotify,
      uri: uri ?? this.uri,
    );
  }

  @override
  List<Object?> get props => [
        id,
        spotifyId,
        name,
        description,
        coverUrl,
        ownerId,
        ownerName,
        trackIds,
        isPublic,
        isCollaborative,
        createdAt,
        updatedAt,
        isFromSpotify,
        uri,
      ];
}

