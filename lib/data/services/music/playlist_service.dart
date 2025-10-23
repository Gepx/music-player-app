import 'package:flutter/foundation.dart';
import '../database/firestore_service.dart';

/// Playlist Management Service
/// Handles CRUD operations for playlists
class PlaylistService {
  PlaylistService._();
  static final PlaylistService instance = PlaylistService._();

  final FirestoreService _firestore = FirestoreService.instance;
  // final LocalDatabaseService _localDb = LocalDatabaseService.instance;

  // -------------------- Create Operations -------------------- //

  /// Create a new playlist
  Future<String?> createPlaylist({
    required String userId,
    required String name,
    String? description,
    String? coverUrl,
    List<String>? songIds,
  }) async {
    try {
      debugPrint('📝 Creating playlist: $name');
      
      final playlistData = {
        'userId': userId,
        'name': name,
        'description': description ?? '',
        'coverUrl': coverUrl ?? '',
        'songIds': songIds ?? [],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'songCount': (songIds ?? []).length,
        'isPublic': false,
      };

      final docRef = await _firestore.playlists.add(playlistData);
      debugPrint('✅ Playlist created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating playlist: $e');
      return null;
    }
  }

  // -------------------- Read Operations -------------------- //

  /// Get playlist by ID
  Future<Map<String, dynamic>?> getPlaylist(String playlistId) async {
    try {
      final doc = await _firestore.playlists.doc(playlistId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting playlist: $e');
      return null;
    }
  }

  /// Get all playlists for a user
  Future<List<Map<String, dynamic>>> getUserPlaylists(String userId) async {
    try {
      final querySnapshot = await _firestore.playlists
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting user playlists: $e');
      return [];
    }
  }

  /// Get public playlists
  Future<List<Map<String, dynamic>>> getPublicPlaylists({int limit = 20}) async {
    try {
      final querySnapshot = await _firestore.playlists
          .where('isPublic', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting public playlists: $e');
      return [];
    }
  }

  // -------------------- Update Operations -------------------- //

  /// Update playlist details
  Future<bool> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    String? coverUrl,
    bool? isPublic,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (coverUrl != null) updateData['coverUrl'] = coverUrl;
      if (isPublic != null) updateData['isPublic'] = isPublic;

      await _firestore.playlists.doc(playlistId).update(updateData);
      debugPrint('✅ Playlist updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating playlist: $e');
      return false;
    }
  }

  /// Add song to playlist
  Future<bool> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      final playlistDoc = _firestore.playlists.doc(playlistId);
      final playlist = await playlistDoc.get();

      if (!playlist.exists) {
        debugPrint('❌ Playlist not found');
        return false;
      }

      final data = playlist.data()!;
      final songIds = List<String>.from(data['songIds'] ?? []);

      if (songIds.contains(songId)) {
        debugPrint('⚠️ Song already in playlist');
        return false;
      }

      songIds.add(songId);

      await playlistDoc.update({
        'songIds': songIds,
        'songCount': songIds.length,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint('✅ Song added to playlist');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding song to playlist: $e');
      return false;
    }
  }

  /// Remove song from playlist
  Future<bool> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      final playlistDoc = _firestore.playlists.doc(playlistId);
      final playlist = await playlistDoc.get();

      if (!playlist.exists) {
        debugPrint('❌ Playlist not found');
        return false;
      }

      final data = playlist.data()!;
      final songIds = List<String>.from(data['songIds'] ?? []);

      if (!songIds.contains(songId)) {
        debugPrint('⚠️ Song not in playlist');
        return false;
      }

      songIds.remove(songId);

      await playlistDoc.update({
        'songIds': songIds,
        'songCount': songIds.length,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint('✅ Song removed from playlist');
      return true;
    } catch (e) {
      debugPrint('❌ Error removing song from playlist: $e');
      return false;
    }
  }

  /// Reorder songs in playlist
  Future<bool> reorderPlaylist({
    required String playlistId,
    required List<String> newSongOrder,
  }) async {
    try {
      await _firestore.playlists.doc(playlistId).update({
        'songIds': newSongOrder,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint('✅ Playlist reordered successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error reordering playlist: $e');
      return false;
    }
  }

  // -------------------- Delete Operations -------------------- //

  /// Delete playlist
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      await _firestore.playlists.doc(playlistId).delete();
      debugPrint('✅ Playlist deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting playlist: $e');
      return false;
    }
  }

  // -------------------- Search Operations -------------------- //

  /// Search playlists by name
  Future<List<Map<String, dynamic>>> searchPlaylists(String query) async {
    try {
      final querySnapshot = await _firestore.playlists
          .where('isPublic', isEqualTo: true)
          .orderBy('name')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      debugPrint('❌ Error searching playlists: $e');
      return [];
    }
  }
}

