import 'package:flutter/foundation.dart';
import '../../models/user/liked_playlist.dart';
import '../../models/user/playlist.dart';
import '../local/liked_playlists_db_service.dart';
import '../auth/auth_service.dart';

/// Liked Playlists Service
/// Manages liked playlists state and operations
class LikedPlaylistsService extends ChangeNotifier {
  LikedPlaylistsService._();
  static final LikedPlaylistsService instance = LikedPlaylistsService._();

  LikedPlaylistsDbService get _db => LikedPlaylistsDbService.instance;
  AuthService get _auth => AuthService.instance;

  Set<String> _likedPlaylistIds = {};
  List<LikedPlaylist> _likedPlaylists = [];
  bool _loading = false;
  String? _error;

  Set<String> get likedPlaylistIds => _likedPlaylistIds;
  List<LikedPlaylist> get likedPlaylists => _likedPlaylists;
  bool get loading => _loading;
  String? get error => _error;
  int get likedCount => _likedPlaylistIds.length;

  Future<void> initialize() async {
    await loadLikedPlaylists();
  }

  Future<void> loadLikedPlaylists() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentFirebaseUser;
      if (user == null) {
        _likedPlaylistIds = {};
        _likedPlaylists = [];
        _loading = false;
        notifyListeners();
        return;
      }

      _likedPlaylists = await _db.getLikedPlaylists(user.uid);
      _likedPlaylistIds = await _db.getLikedPlaylistIds(user.uid);

      _loading = false;
      notifyListeners();
      debugPrint('💽 Loaded ${_likedPlaylistIds.length} liked playlists');
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      debugPrint('❌ Load liked playlists error: $e');
    }
  }

  Future<void> likePlaylist(Playlist playlist) async {
    try {
      final user = _auth.currentFirebaseUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (_likedPlaylistIds.contains(playlist.id)) {
        debugPrint('⚠️ Playlist already liked');
        return;
      }

      final liked = LikedPlaylist.fromPlaylist(playlist, user.uid);
      await _db.likePlaylist(liked);

      _likedPlaylistIds.add(playlist.id);
      _likedPlaylists.insert(0, liked);
      notifyListeners();

      debugPrint('❤️ Liked playlist: ${playlist.name}');
    } catch (e) {
      debugPrint('❌ Like playlist error: $e');
      rethrow;
    }
  }

  Future<void> unlikePlaylist(String playlistId) async {
    try {
      final user = _auth.currentFirebaseUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _db.unlikePlaylist(user.uid, playlistId);
      _likedPlaylistIds.remove(playlistId);
      _likedPlaylists.removeWhere((p) => p.playlistId == playlistId);
      notifyListeners();
      debugPrint('💔 Unliked playlist: $playlistId');
    } catch (e) {
      debugPrint('❌ Unlike playlist error: $e');
      rethrow;
    }
  }

  Future<void> toggleLike(Playlist playlist) async {
    if (isLiked(playlist.id)) {
      await unlikePlaylist(playlist.id);
    } else {
      await likePlaylist(playlist);
    }
  }

  bool isLiked(String playlistId) {
    return _likedPlaylistIds.contains(playlistId);
  }

  LikedPlaylist? getLikedPlaylist(String playlistId) {
    try {
      return _likedPlaylists.firstWhere((p) => p.playlistId == playlistId);
    } catch (_) {
      return null;
    }
  }

  Future<List<LikedPlaylist>> getPendingLikes() async {
    final user = _auth.currentFirebaseUser;
    if (user == null) return [];
    return await _db.getPendingLikes(user.uid);
  }

  Future<void> markAsSynced(String playlistId) async {
    try {
      await _db.markAsSynced(playlistId);
      final index = _likedPlaylists.indexWhere((p) => p.playlistId == playlistId);
      if (index != -1) {
        _likedPlaylists[index] =
            _likedPlaylists[index].copyWith(syncStatus: 'synced');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Mark playlist as synced error: $e');
    }
  }

  void clear() {
    _likedPlaylistIds = {};
    _likedPlaylists = [];
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
