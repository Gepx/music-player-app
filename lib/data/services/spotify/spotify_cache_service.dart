import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/app/app_models.dart';

/// Spotify Cache Service
/// Manages local caching of Spotify data using Hive
class SpotifyCacheService {
  SpotifyCacheService._();
  static final SpotifyCacheService instance = SpotifyCacheService._();

  // Box names
  static const String _tracksBoxName = 'spotify_tracks';
  static const String _albumsBoxName = 'spotify_albums';
  static const String _artistsBoxName = 'spotify_artists';
  static const String _playlistsBoxName = 'spotify_playlists';
  static const String _searchHistoryBoxName = 'search_history';
  static const String _metadataBoxName = 'cache_metadata';

  // Boxes
  Box<TrackModel>? _tracksBox;
  Box<AlbumModel>? _albumsBox;
  Box<ArtistModel>? _artistsBox;
  Box<PlaylistModel>? _playlistsBox;
  Box<String>? _searchHistoryBox;
  Box<dynamic>? _metadataBox;

  // Cache expiry duration (24 hours)
  static const Duration _cacheExpiry = Duration(hours: 24);

  // -------------------- Initialization -------------------- //

  /// Initialize all cache boxes
  Future<void> initialize() async {
    try {
      debugPrint('📦 Initializing Spotify cache service...');

      _tracksBox = await Hive.openBox<TrackModel>(_tracksBoxName);
      _albumsBox = await Hive.openBox<AlbumModel>(_albumsBoxName);
      _artistsBox = await Hive.openBox<ArtistModel>(_artistsBoxName);
      _playlistsBox = await Hive.openBox<PlaylistModel>(_playlistsBoxName);
      _searchHistoryBox = await Hive.openBox<String>(_searchHistoryBoxName);
      _metadataBox = await Hive.openBox(_metadataBoxName);

      debugPrint('✅ Spotify cache service initialized');
      debugPrint('📊 Cache stats: ${_tracksBox!.length} tracks, ${_albumsBox!.length} albums');
    } catch (e) {
      debugPrint('❌ Error initializing cache service: $e');
      rethrow;
    }
  }

  // -------------------- Track Caching -------------------- //

  /// Cache a track
  Future<void> cacheTrack(TrackModel track) async {
    try {
      await _tracksBox?.put(track.spotifyId ?? track.id, track);
      await _updateCacheTimestamp('track_${track.spotifyId ?? track.id}');
      debugPrint('💾 Track cached: ${track.title}');
    } catch (e) {
      debugPrint('❌ Error caching track: $e');
    }
  }

  /// Cache multiple tracks
  Future<void> cacheTracks(List<TrackModel> tracks) async {
    try {
      final entries = {for (var t in tracks) t.spotifyId ?? t.id: t};
      await _tracksBox?.putAll(entries);
      
      for (var track in tracks) {
        await _updateCacheTimestamp('track_${track.spotifyId ?? track.id}');
      }
      
      debugPrint('💾 Cached ${tracks.length} tracks');
    } catch (e) {
      debugPrint('❌ Error caching tracks: $e');
    }
  }

  /// Get cached track
  Future<TrackModel?> getCachedTrack(String trackId) async {
    try {
      if (!await _isCacheValid('track_$trackId')) {
        await _tracksBox?.delete(trackId);
        return null;
      }
      
      return _tracksBox?.get(trackId);
    } catch (e) {
      debugPrint('❌ Error getting cached track: $e');
      return null;
    }
  }

  /// Get all cached tracks
  Future<List<TrackModel>> getAllCachedTracks() async {
    try {
      return _tracksBox?.values.toList() ?? [];
    } catch (e) {
      debugPrint('❌ Error getting all cached tracks: $e');
      return [];
    }
  }

  // -------------------- Album Caching -------------------- //

  /// Cache an album
  Future<void> cacheAlbum(AlbumModel album) async {
    try {
      await _albumsBox?.put(album.spotifyId ?? album.id, album);
      await _updateCacheTimestamp('album_${album.spotifyId ?? album.id}');
      debugPrint('💾 Album cached: ${album.title}');
    } catch (e) {
      debugPrint('❌ Error caching album: $e');
    }
  }

  /// Cache multiple albums
  Future<void> cacheAlbums(List<AlbumModel> albums) async {
    try {
      final entries = {for (var a in albums) a.spotifyId ?? a.id: a};
      await _albumsBox?.putAll(entries);
      
      for (var album in albums) {
        await _updateCacheTimestamp('album_${album.spotifyId ?? album.id}');
      }
      
      debugPrint('💾 Cached ${albums.length} albums');
    } catch (e) {
      debugPrint('❌ Error caching albums: $e');
    }
  }

  /// Get cached album
  Future<AlbumModel?> getCachedAlbum(String albumId) async {
    try {
      if (!await _isCacheValid('album_$albumId')) {
        await _albumsBox?.delete(albumId);
        return null;
      }
      
      return _albumsBox?.get(albumId);
    } catch (e) {
      debugPrint('❌ Error getting cached album: $e');
      return null;
    }
  }

  // -------------------- Artist Caching -------------------- //

  /// Cache an artist
  Future<void> cacheArtist(ArtistModel artist) async {
    try {
      await _artistsBox?.put(artist.spotifyId ?? artist.id, artist);
      await _updateCacheTimestamp('artist_${artist.spotifyId ?? artist.id}');
      debugPrint('💾 Artist cached: ${artist.name}');
    } catch (e) {
      debugPrint('❌ Error caching artist: $e');
    }
  }

  /// Get cached artist
  Future<ArtistModel?> getCachedArtist(String artistId) async {
    try {
      if (!await _isCacheValid('artist_$artistId')) {
        await _artistsBox?.delete(artistId);
        return null;
      }
      
      return _artistsBox?.get(artistId);
    } catch (e) {
      debugPrint('❌ Error getting cached artist: $e');
      return null;
    }
  }

  // -------------------- Playlist Caching -------------------- //

  /// Cache a playlist
  Future<void> cachePlaylist(PlaylistModel playlist) async {
    try {
      await _playlistsBox?.put(playlist.spotifyId ?? playlist.id, playlist);
      await _updateCacheTimestamp('playlist_${playlist.spotifyId ?? playlist.id}');
      debugPrint('💾 Playlist cached: ${playlist.name}');
    } catch (e) {
      debugPrint('❌ Error caching playlist: $e');
    }
  }

  /// Cache multiple playlists
  Future<void> cachePlaylists(List<PlaylistModel> playlists) async {
    try {
      final entries = {for (var p in playlists) p.spotifyId ?? p.id: p};
      await _playlistsBox?.putAll(entries);
      
      for (var playlist in playlists) {
        await _updateCacheTimestamp('playlist_${playlist.spotifyId ?? playlist.id}');
      }
      
      debugPrint('💾 Cached ${playlists.length} playlists');
    } catch (e) {
      debugPrint('❌ Error caching playlists: $e');
    }
  }

  /// Get cached playlist
  Future<PlaylistModel?> getCachedPlaylist(String playlistId) async {
    try {
      if (!await _isCacheValid('playlist_$playlistId')) {
        await _playlistsBox?.delete(playlistId);
        return null;
      }
      
      return _playlistsBox?.get(playlistId);
    } catch (e) {
      debugPrint('❌ Error getting cached playlist: $e');
      return null;
    }
  }

  /// Get all cached playlists
  Future<List<PlaylistModel>> getAllCachedPlaylists() async {
    try {
      return _playlistsBox?.values.toList() ?? [];
    } catch (e) {
      debugPrint('❌ Error getting all cached playlists: $e');
      return [];
    }
  }

  // -------------------- Search History -------------------- //

  /// Save search query
  Future<void> saveSearchQuery(String query) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await _searchHistoryBox?.put(timestamp, query);
      debugPrint('💾 Search query saved: $query');
    } catch (e) {
      debugPrint('❌ Error saving search query: $e');
    }
  }

  /// Get search history (latest first)
  Future<List<String>> getSearchHistory({int limit = 10}) async {
    try {
      final history = _searchHistoryBox?.values.toList() ?? [];
      return history.reversed.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Error getting search history: $e');
      return [];
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      await _searchHistoryBox?.clear();
      debugPrint('✅ Search history cleared');
    } catch (e) {
      debugPrint('❌ Error clearing search history: $e');
    }
  }

  // -------------------- Cache Metadata -------------------- //

  /// Update cache timestamp for an item
  Future<void> _updateCacheTimestamp(String key) async {
    await _metadataBox?.put(key, DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if cached item is still valid
  Future<bool> _isCacheValid(String key) async {
    try {
      final timestamp = _metadataBox?.get(key) as int?;
      if (timestamp == null) return false;
      
      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cachedTime) < _cacheExpiry;
    } catch (e) {
      return false;
    }
  }

  // -------------------- Clear Cache -------------------- //

  /// Clear all tracks cache
  Future<void> clearTracksCache() async {
    try {
      await _tracksBox?.clear();
      debugPrint('✅ Tracks cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing tracks cache: $e');
    }
  }

  /// Clear all albums cache
  Future<void> clearAlbumsCache() async {
    try {
      await _albumsBox?.clear();
      debugPrint('✅ Albums cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing albums cache: $e');
    }
  }

  /// Clear all artists cache
  Future<void> clearArtistsCache() async {
    try {
      await _artistsBox?.clear();
      debugPrint('✅ Artists cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing artists cache: $e');
    }
  }

  /// Clear all playlists cache
  Future<void> clearPlaylistsCache() async {
    try {
      await _playlistsBox?.clear();
      debugPrint('✅ Playlists cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing playlists cache: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      await Future.wait([
        clearTracksCache(),
        clearAlbumsCache(),
        clearArtistsCache(),
        clearPlaylistsCache(),
        clearSearchHistory(),
        _metadataBox?.clear() ?? Future.value(),
      ]);
      debugPrint('✅ All cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing all cache: $e');
    }
  }

  // -------------------- Cache Statistics -------------------- //

  /// Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'tracks': _tracksBox?.length ?? 0,
      'albums': _albumsBox?.length ?? 0,
      'artists': _artistsBox?.length ?? 0,
      'playlists': _playlistsBox?.length ?? 0,
      'searchHistory': _searchHistoryBox?.length ?? 0,
    };
  }

  /// Get cache size estimate (in entries)
  int getTotalCacheSize() {
    return (_tracksBox?.length ?? 0) +
        (_albumsBox?.length ?? 0) +
        (_artistsBox?.length ?? 0) +
        (_playlistsBox?.length ?? 0);
  }

  // -------------------- Cleanup -------------------- //

  /// Close all boxes
  Future<void> close() async {
    try {
      await _tracksBox?.close();
      await _albumsBox?.close();
      await _artistsBox?.close();
      await _playlistsBox?.close();
      await _searchHistoryBox?.close();
      await _metadataBox?.close();
      debugPrint('✅ Cache boxes closed');
    } catch (e) {
      debugPrint('❌ Error closing cache boxes: $e');
    }
  }
}

