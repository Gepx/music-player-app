import 'package:flutter/foundation.dart';
import '../../models/user/liked_track.dart';
import '../../models/spotify/spotify_track.dart';
import '../local/liked_tracks_db_service.dart';
import '../auth/auth_service.dart';

/// Liked Tracks Service
/// Manages liked tracks state and operations
class LikedTracksService extends ChangeNotifier {
  LikedTracksService._();
  static final LikedTracksService instance = LikedTracksService._();

  LikedTracksDbService get _db => LikedTracksDbService.instance;
  AuthService get _auth => AuthService.instance;

  Set<String> _likedTrackIds = {};
  List<LikedTrack> _likedTracks = [];
  bool _loading = false;
  String? _error;

  // Getters
  Set<String> get likedTrackIds => _likedTrackIds;
  List<LikedTrack> get likedTracks => _likedTracks;
  bool get loading => _loading;
  String? get error => _error;
  int get likedCount => _likedTrackIds.length;

  @visibleForTesting
  void setTestState({
    required Set<String> likedIds,
    required List<LikedTrack> likedTracks,
  }) {
    _likedTrackIds = Set<String>.from(likedIds);
    _likedTracks = List<LikedTrack>.from(likedTracks);
    _loading = false;
    _error = null;
  }

  /// Initialize and load liked tracks
  Future<void> initialize() async {
    await loadLikedTracks();
  }

  /// Load liked tracks from database
  Future<void> loadLikedTracks() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentFirebaseUser;
      if (user == null) {
        _likedTrackIds = {};
        _likedTracks = [];
        _loading = false;
        notifyListeners();
        return;
      }

      // Load full liked tracks
      _likedTracks = await _db.getLikedTracks(user.uid);
      
      // Load track IDs for quick lookup
      _likedTrackIds = await _db.getLikedTrackIds(user.uid);
      
      _loading = false;
      notifyListeners();
      
      debugPrint('❤️ Loaded ${_likedTrackIds.length} liked tracks');
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      debugPrint('❌ Load liked tracks error: $e');
    }
  }

  /// Like a track
  Future<void> likeTrack(SpotifyTrack track) async {
    try {
      final user = _auth.currentFirebaseUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if already liked
      if (_likedTrackIds.contains(track.id)) {
        debugPrint('⚠️ Track already liked');
        return;
      }

      final likedTrack = LikedTrack.fromSpotifyTrack(track, user.uid);
      
      await _db.likeTrack(likedTrack);
      
      // Update local state
      _likedTrackIds.add(track.id);
      _likedTracks.insert(0, likedTrack);
      notifyListeners();

      debugPrint('❤️ Liked track: ${track.name}');
    } catch (e) {
      debugPrint('❌ Like track error: $e');
      rethrow;
    }
  }

  /// Unlike a track
  Future<void> unlikeTrack(String trackId) async {
    try {
      final user = _auth.currentFirebaseUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _db.unlikeTrack(user.uid, trackId);
      
      // Update local state
      _likedTrackIds.remove(trackId);
      _likedTracks.removeWhere((t) => t.trackId == trackId);
      notifyListeners();

      debugPrint('💔 Unliked track: $trackId');
    } catch (e) {
      debugPrint('❌ Unlike track error: $e');
      rethrow;
    }
  }

  /// Toggle like status
  Future<void> toggleLike(SpotifyTrack track) async {
    if (isLiked(track.id)) {
      await unlikeTrack(track.id);
    } else {
      await likeTrack(track);
    }
  }

  /// Check if track is liked
  bool isLiked(String trackId) {
    return _likedTrackIds.contains(trackId);
  }

  /// Get liked track
  LikedTrack? getLikedTrack(String trackId) {
    try {
      return _likedTracks.firstWhere((t) => t.trackId == trackId);
    } catch (e) {
      return null;
    }
  }

  /// Search liked tracks
  Future<List<LikedTrack>> searchLikedTracks(String query) async {
    try {
      final user = _auth.currentFirebaseUser;
      if (user == null) return [];

      if (query.isEmpty) {
        return _likedTracks;
      }

      return await _db.searchLikedTracks(user.uid, query);
    } catch (e) {
      debugPrint('❌ Search liked tracks error: $e');
      return [];
    }
  }

  /// Sort liked tracks
  List<LikedTrack> sortLikedTracks(String sortBy) {
    try {
      final tracks = List<LikedTrack>.from(_likedTracks);
      
      switch (sortBy) {
        case 'recent':
          // Already sorted by likedAt DESC in database
          return tracks;
        case 'name':
          tracks.sort((a, b) {
            final aName = (a.name ?? '').toLowerCase();
            final bName = (b.name ?? '').toLowerCase();
            return aName.compareTo(bName);
          });
          return tracks;
        case 'artist':
          tracks.sort((a, b) {
            final aArtist = (a.artist ?? '').toLowerCase();
            final bArtist = (b.artist ?? '').toLowerCase();
            return aArtist.compareTo(bArtist);
          });
          return tracks;
        default:
          return tracks;
      }
    } catch (e) {
      debugPrint('❌ Sort liked tracks error: $e');
      return List<LikedTrack>.from(_likedTracks);
    }
  }

  /// Get pending liked tracks (need sync)
  Future<List<LikedTrack>> getPendingLikes() async {
    final user = _auth.currentFirebaseUser;
    if (user == null) return [];
    return await _db.getPendingLikes(user.uid);
  }

  /// Mark track as synced
  Future<void> markAsSynced(String trackId) async {
    try {
      await _db.markAsSynced(trackId);
      
      final index = _likedTracks.indexWhere((t) => t.trackId == trackId);
      if (index != -1) {
        _likedTracks[index] = _likedTracks[index].copyWith(syncStatus: 'synced');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Mark as synced error: $e');
    }
  }

  /// Get liked tracks count
  Future<int> getLikedCount() async {
    try {
      final user = _auth.currentFirebaseUser;
      if (user == null) return 0;
      return await _db.getLikedCount(user.uid);
    } catch (e) {
      debugPrint('❌ Get liked count error: $e');
      return 0;
    }
  }

  /// Clear all liked tracks (for logout)
  void clear() {
    _likedTrackIds = {};
    _likedTracks = [];
    _loading = false;
    _error = null;
    notifyListeners();
  }
}

