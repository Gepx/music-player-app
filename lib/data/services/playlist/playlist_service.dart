import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../models/user/playlist.dart';
import '../../models/spotify/spotify_track.dart';
import '../local/playlist_db_service.dart';
import '../auth/auth_service.dart';

/// Playlist Service
/// Manages playlist state and operations
class PlaylistService extends ChangeNotifier {
  PlaylistService._();
  static final PlaylistService instance = PlaylistService._();

  final PlaylistDbService _db = PlaylistDbService.instance;
  final AuthService _auth = AuthService.instance;
  final Uuid _uuid = const Uuid();

  List<Playlist> _playlists = [];
  bool _loading = false;
  String? _error;

  // Getters
  List<Playlist> get playlists => _playlists;
  bool get loading => _loading;
  String? get error => _error;
  int get playlistCount => _playlists.length;

  /// Initialize and load playlists
  Future<void> initialize() async {
    await loadPlaylists();
  }

  /// Load playlists from database
  Future<void> loadPlaylists() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentFirebaseUser;
      if (user == null) {
        _playlists = [];
        _loading = false;
        notifyListeners();
        return;
      }

      _playlists = await _db.getPlaylists(user.uid);
      _loading = false;
      notifyListeners();
      
      debugPrint('📚 Loaded ${_playlists.length} playlists');
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      debugPrint('❌ Load playlists error: $e');
    }
  }

  /// Create a new playlist
  Future<Playlist?> createPlaylist({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      final user = _auth.currentFirebaseUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final playlist = Playlist(
        id: _uuid.v4(),
        name: name,
        description: description,
        userId: user.uid,
        trackIds: [],
        createdAt: now,
        updatedAt: now,
        isPublic: isPublic,
        syncStatus: 'pending',
      );

      await _db.createPlaylist(playlist);
      _playlists.insert(0, playlist);
      notifyListeners();

      debugPrint('✅ Created playlist: $name');
      return playlist;
    } catch (e) {
      debugPrint('❌ Create playlist error: $e');
      return null;
    }
  }

  /// Update playlist metadata
  Future<void> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index == -1) {
        throw Exception('Playlist not found');
      }

      final updatedPlaylist = _playlists[index].copyWith(
        name: name,
        description: description,
        isPublic: isPublic,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _db.updatePlaylist(updatedPlaylist);
      _playlists[index] = updatedPlaylist;
      notifyListeners();

      debugPrint('✅ Updated playlist: $name');
    } catch (e) {
      debugPrint('❌ Update playlist error: $e');
      rethrow;
    }
  }

  /// Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _db.deletePlaylist(playlistId);
      _playlists.removeWhere((p) => p.id == playlistId);
      notifyListeners();

      debugPrint('✅ Deleted playlist');
    } catch (e) {
      debugPrint('❌ Delete playlist error: $e');
      rethrow;
    }
  }

  /// Add track to playlist
  Future<void> addTrackToPlaylist(String playlistId, SpotifyTrack track) async {
    try {
      await _db.addTrack(playlistId, track.id);
      
      // Update local state
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        final updatedTrackIds = [..._playlists[index].trackIds, track.id];
        _playlists[index] = _playlists[index].copyWith(
          trackIds: updatedTrackIds,
          updatedAt: DateTime.now(),
          syncStatus: 'pending',
        );
        notifyListeners();
      }

      debugPrint('✅ Added "${track.name}" to playlist');
    } catch (e) {
      debugPrint('❌ Add track to playlist error: $e');
      rethrow;
    }
  }

  /// Remove track from playlist
  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    try {
      await _db.removeTrack(playlistId, trackId);
      
      // Update local state
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        final updatedTrackIds = _playlists[index].trackIds
            .where((id) => id != trackId)
            .toList();
        _playlists[index] = _playlists[index].copyWith(
          trackIds: updatedTrackIds,
          updatedAt: DateTime.now(),
          syncStatus: 'pending',
        );
        notifyListeners();
      }

      debugPrint('✅ Removed track from playlist');
    } catch (e) {
      debugPrint('❌ Remove track from playlist error: $e');
      rethrow;
    }
  }

  /// Reorder tracks in playlist
  Future<void> reorderTracks(String playlistId, int oldIndex, int newIndex) async {
    try {
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index == -1) {
        throw Exception('Playlist not found');
      }

      final trackIds = List<String>.from(_playlists[index].trackIds);
      
      // Adjust newIndex if moving down
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      
      final track = trackIds.removeAt(oldIndex);
      trackIds.insert(newIndex, track);

      await _db.reorderTracks(playlistId, trackIds);
      
      _playlists[index] = _playlists[index].copyWith(
        trackIds: trackIds,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      notifyListeners();

      debugPrint('✅ Reordered tracks in playlist');
    } catch (e) {
      debugPrint('❌ Reorder tracks error: $e');
      rethrow;
    }
  }

  /// Get a single playlist
  Playlist? getPlaylist(String playlistId) {
    try {
      return _playlists.firstWhere((p) => p.id == playlistId);
    } catch (e) {
      return null;
    }
  }

  /// Check if track is in any playlist
  bool isTrackInPlaylist(String trackId, String playlistId) {
    final playlist = getPlaylist(playlistId);
    return playlist?.trackIds.contains(trackId) ?? false;
  }

  /// Get playlists containing a specific track
  List<Playlist> getPlaylistsContainingTrack(String trackId) {
    return _playlists.where((p) => p.trackIds.contains(trackId)).toList();
  }

  /// Get playlists that need sync
  Future<List<Playlist>> getPendingPlaylists() async {
    final user = _auth.currentFirebaseUser;
    if (user == null) return [];
    return await _db.getPendingPlaylists(user.uid);
  }

  /// Mark playlist as synced
  Future<void> markAsSynced(String playlistId) async {
    try {
      await _db.markAsSynced(playlistId);
      
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        _playlists[index] = _playlists[index].copyWith(syncStatus: 'synced');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Mark as synced error: $e');
    }
  }

  /// Clear all playlists (for logout)
  void clear() {
    _playlists = [];
    _loading = false;
    _error = null;
    notifyListeners();
  }
}

