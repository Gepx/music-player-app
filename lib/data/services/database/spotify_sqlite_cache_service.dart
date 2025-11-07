import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/app/app_models.dart';
import 'local_database_service.dart';

/// Spotify SQLite Cache Service
/// Manages caching of Spotify API data using SQLite
/// Provides advanced querying capabilities and relational data management
class SpotifySQLiteCacheService {
  SpotifySQLiteCacheService._();
  static final SpotifySQLiteCacheService instance = SpotifySQLiteCacheService._();

  final LocalDatabaseService _db = LocalDatabaseService.instance;

  // Table names (from LocalDatabaseService)
  static const String _tracksTable = 'tracks';
  static const String _albumsTable = 'albums';
  static const String _artistsTable = 'artists';
  static const String _playlistsTable = 'playlists';
  static const String _playlistTracksTable = 'playlist_tracks';
  static const String _searchHistoryTable = 'search_history';
  static const String _recentlyPlayedTable = 'recently_played';
  static const String _favoritesTable = 'user_favorites';
  static const String _cacheMetadataTable = 'cache_metadata';

  // Cache expiry duration (24 hours)
  static const Duration _cacheExpiry = Duration(hours: 24);

  // -------------------- Initialization -------------------- //

  /// Initialize the service
  Future<void> initialize() async {
    try {
      debugPrint('🗄️ Initializing Spotify SQLite cache service...');
      
      // Trigger database initialization
      await _db.database;
      
      // Clear expired cache on startup
      await clearExpiredCache();
      
      debugPrint('✅ Spotify SQLite cache service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Spotify SQLite cache: $e');
      rethrow;
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    return await _db.healthCheck();
  }

  // -------------------- Track Operations -------------------- //

  /// Cache a single track
  Future<void> cacheTrack(TrackModel track) async {
    try {
      final db = await _db.database;
      
      await db.insert(
        _tracksTable,
        track.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      await _updateCacheMetadata('track_${track.spotifyId}', 'track');
      debugPrint('💾 Track cached: ${track.title}');
    } catch (e) {
      debugPrint('❌ Error caching track: $e');
    }
  }

  /// Cache multiple tracks
  Future<void> cacheTracks(List<TrackModel> tracks) async {
    try {
      final db = await _db.database;
      final batch = db.batch();
      
      for (var track in tracks) {
        batch.insert(
          _tracksTable,
          track.toSQLite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit(noResult: true);
      
      // Update cache metadata
      for (var track in tracks) {
        await _updateCacheMetadata('track_${track.spotifyId}', 'track');
      }
      
      debugPrint('💾 Cached ${tracks.length} tracks');
    } catch (e) {
      debugPrint('❌ Error caching tracks: $e');
    }
  }

  /// Get cached track by ID
  Future<TrackModel?> getCachedTrack(String trackId) async {
    try {
      final db = await _db.database;
      
      // Check if cache is valid
      if (!await _isCacheValid('track_$trackId')) {
        await db.delete(_tracksTable, where: 'spotify_id = ?', whereArgs: [trackId]);
        return null;
      }
      
      final results = await db.query(
        _tracksTable,
        where: 'spotify_id = ?',
        whereArgs: [trackId],
        limit: 1,
      );
      
      if (results.isEmpty) return null;
      
      await _incrementHitCount('track_$trackId');
      return TrackModel.fromSQLite(results.first);
    } catch (e) {
      debugPrint('❌ Error getting cached track: $e');
      return null;
    }
  }

  /// Search cached tracks by title or artist
  Future<List<TrackModel>> searchCachedTracks(String query) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        _tracksTable,
        where: 'title LIKE ? OR artist_name LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'popularity DESC',
        limit: 50,
      );
      
      return results.map((map) => TrackModel.fromSQLite(map)).toList();
    } catch (e) {
      debugPrint('❌ Error searching cached tracks: $e');
      return [];
    }
  }

  /// Get tracks by album
  Future<List<TrackModel>> getTracksByAlbum(String albumId) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        _tracksTable,
        where: 'album_id = ?',
        whereArgs: [albumId],
        orderBy: 'track_number ASC',
      );
      
      return results.map((map) => TrackModel.fromSQLite(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting tracks by album: $e');
      return [];
    }
  }

  /// Get all cached tracks
  Future<List<TrackModel>> getAllCachedTracks({int limit = 100}) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        _tracksTable,
        orderBy: 'cached_at DESC',
        limit: limit,
      );
      
      return results.map((map) => TrackModel.fromSQLite(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting all cached tracks: $e');
      return [];
    }
  }

  // -------------------- Album Operations -------------------- //

  /// Cache a single album
  Future<void> cacheAlbum(AlbumModel album) async {
    try {
      final db = await _db.database;
      
      await db.insert(
        _albumsTable,
        album.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      await _updateCacheMetadata('album_${album.spotifyId}', 'album');
      debugPrint('💾 Album cached: ${album.title}');
    } catch (e) {
      debugPrint('❌ Error caching album: $e');
    }
  }

  /// Cache multiple albums
  Future<void> cacheAlbums(List<AlbumModel> albums) async {
    try {
      final db = await _db.database;
      final batch = db.batch();
      
      for (var album in albums) {
        batch.insert(
          _albumsTable,
          album.toSQLite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit(noResult: true);
      
      for (var album in albums) {
        await _updateCacheMetadata('album_${album.spotifyId}', 'album');
      }
      
      debugPrint('💾 Cached ${albums.length} albums');
    } catch (e) {
      debugPrint('❌ Error caching albums: $e');
    }
  }

  /// Get cached album by ID
  Future<AlbumModel?> getCachedAlbum(String albumId) async {
    try {
      final db = await _db.database;
      
      if (!await _isCacheValid('album_$albumId')) {
        await db.delete(_albumsTable, where: 'spotify_id = ?', whereArgs: [albumId]);
        return null;
      }
      
      final results = await db.query(
        _albumsTable,
        where: 'spotify_id = ?',
        whereArgs: [albumId],
        limit: 1,
      );
      
      if (results.isEmpty) return null;
      
      await _incrementHitCount('album_$albumId');
      return AlbumModel.fromSQLite(results.first);
    } catch (e) {
      debugPrint('❌ Error getting cached album: $e');
      return null;
    }
  }

  /// Search cached albums
  Future<List<AlbumModel>> searchCachedAlbums(String query) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        _albumsTable,
        where: 'title LIKE ? OR artist_name LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'cached_at DESC',
        limit: 50,
      );
      
      return results.map((map) => AlbumModel.fromSQLite(map)).toList();
    } catch (e) {
      debugPrint('❌ Error searching cached albums: $e');
      return [];
    }
  }

  // -------------------- Artist Operations -------------------- //

  /// Cache a single artist
  Future<void> cacheArtist(ArtistModel artist) async {
    try {
      final db = await _db.database;
      
      await db.insert(
        _artistsTable,
        artist.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      await _updateCacheMetadata('artist_${artist.spotifyId}', 'artist');
      debugPrint('💾 Artist cached: ${artist.name}');
    } catch (e) {
      debugPrint('❌ Error caching artist: $e');
    }
  }

  /// Get cached artist by ID
  Future<ArtistModel?> getCachedArtist(String artistId) async {
    try {
      final db = await _db.database;
      
      if (!await _isCacheValid('artist_$artistId')) {
        await db.delete(_artistsTable, where: 'spotify_id = ?', whereArgs: [artistId]);
        return null;
      }
      
      final results = await db.query(
        _artistsTable,
        where: 'spotify_id = ?',
        whereArgs: [artistId],
        limit: 1,
      );
      
      if (results.isEmpty) return null;
      
      await _incrementHitCount('artist_$artistId');
      return ArtistModel.fromSQLite(results.first);
    } catch (e) {
      debugPrint('❌ Error getting cached artist: $e');
      return null;
    }
  }

  /// Search cached artists
  Future<List<ArtistModel>> searchCachedArtists(String query) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        _artistsTable,
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'popularity DESC',
        limit: 50,
      );
      
      return results.map((map) => ArtistModel.fromSQLite(map)).toList();
    } catch (e) {
      debugPrint('❌ Error searching cached artists: $e');
      return [];
    }
  }

  // -------------------- Playlist Operations -------------------- //

  /// Cache a playlist with its tracks
  Future<void> cachePlaylist(PlaylistModel playlist, List<TrackModel>? tracks) async {
    try {
      final db = await _db.database;
      final batch = db.batch();
      
      // Cache playlist
      batch.insert(
        _playlistsTable,
        playlist.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Cache tracks if provided
      if (tracks != null && tracks.isNotEmpty) {
        // First cache the tracks themselves
        for (var track in tracks) {
          batch.insert(
            _tracksTable,
            track.toSQLite(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        
        // Then create playlist-track relationships
        for (var i = 0; i < tracks.length; i++) {
          batch.insert(
            _playlistTracksTable,
            {
              'playlist_id': playlist.spotifyId ?? playlist.id,
              'track_id': tracks[i].spotifyId ?? tracks[i].id,
              'position': i,
              'added_at': DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      
      await batch.commit(noResult: true);
      await _updateCacheMetadata('playlist_${playlist.spotifyId}', 'playlist');
      
      debugPrint('💾 Playlist cached: ${playlist.name} with ${tracks?.length ?? 0} tracks');
    } catch (e) {
      debugPrint('❌ Error caching playlist: $e');
    }
  }

  /// Get cached playlist by ID
  Future<PlaylistModel?> getCachedPlaylist(String playlistId) async {
    try {
      final db = await _db.database;
      
      if (!await _isCacheValid('playlist_$playlistId')) {
        await db.delete(_playlistsTable, where: 'spotify_id = ?', whereArgs: [playlistId]);
        return null;
      }
      
      final results = await db.query(
        _playlistsTable,
        where: 'spotify_id = ?',
        whereArgs: [playlistId],
        limit: 1,
      );
      
      if (results.isEmpty) return null;
      
      await _incrementHitCount('playlist_$playlistId');
      return PlaylistModel.fromSQLite(results.first);
    } catch (e) {
      debugPrint('❌ Error getting cached playlist: $e');
      return null;
    }
  }

  /// Get tracks for a playlist
  Future<List<TrackModel>> getPlaylistTracks(String playlistId) async {
    try {
      final db = await _db.database;
      
      // Join playlist_tracks with tracks table
      final results = await db.rawQuery('''
        SELECT t.* FROM $_tracksTable t
        INNER JOIN $_playlistTracksTable pt ON t.spotify_id = pt.track_id
        WHERE pt.playlist_id = ?
        ORDER BY pt.position ASC
      ''', [playlistId]);
      
      return results.map((map) => TrackModel.fromSQLite(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting playlist tracks: $e');
      return [];
    }
  }

  /// Get all cached playlists
  Future<List<PlaylistModel>> getAllCachedPlaylists({int limit = 50}) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        _playlistsTable,
        orderBy: 'cached_at DESC',
        limit: limit,
      );
      
      return results.map((map) => PlaylistModel.fromSQLite(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting all cached playlists: $e');
      return [];
    }
  }

  // -------------------- Search History -------------------- //

  /// Save search history
  Future<void> saveSearchHistory(String query, String searchType, int resultsCount) async {
    try {
      final db = await _db.database;
      
      await db.insert(_searchHistoryTable, {
        'query': query,
        'search_type': searchType,
        'results_count': resultsCount,
        'searched_at': DateTime.now().millisecondsSinceEpoch,
      });
      
      debugPrint('📝 Search history saved: $query');
    } catch (e) {
      debugPrint('❌ Error saving search history: $e');
    }
  }

  /// Get search history
  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 20}) async {
    try {
      final db = await _db.database;
      
      return await db.query(
        _searchHistoryTable,
        orderBy: 'searched_at DESC',
        limit: limit,
      );
    } catch (e) {
      debugPrint('❌ Error getting search history: $e');
      return [];
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      final db = await _db.database;
      await db.delete(_searchHistoryTable);
      debugPrint('✅ Search history cleared');
    } catch (e) {
      debugPrint('❌ Error clearing search history: $e');
    }
  }

  // -------------------- Recently Played -------------------- //

  /// Save recently played track
  Future<void> saveRecentlyPlayed(
    String trackId,
    DateTime playedAt, {
    String? contextType,
    String? contextId,
  }) async {
    try {
      final db = await _db.database;
      
      await db.insert(_recentlyPlayedTable, {
        'track_id': trackId,
        'played_at': playedAt.millisecondsSinceEpoch,
        'context_type': contextType,
        'context_id': contextId,
      });
      
      debugPrint('📝 Recently played saved: $trackId');
    } catch (e) {
      debugPrint('❌ Error saving recently played: $e');
    }
  }

  /// Get recently played tracks
  Future<List<TrackModel>> getRecentlyPlayed({int limit = 50}) async {
    try {
      final db = await _db.database;
      
      final results = await db.rawQuery('''
        SELECT DISTINCT t.* FROM $_tracksTable t
        INNER JOIN $_recentlyPlayedTable rp ON t.spotify_id = rp.track_id
        ORDER BY rp.played_at DESC
        LIMIT ?
      ''', [limit]);
      
      return results.map((map) => TrackModel.fromSQLite(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting recently played: $e');
      return [];
    }
  }

  // -------------------- Favorites -------------------- //

  /// Add to favorites
  Future<void> addFavorite(String itemId, String itemType) async {
    try {
      final db = await _db.database;
      
      await db.insert(
        _favoritesTable,
        {
          'item_id': itemId,
          'item_type': itemType,
          'added_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      
      debugPrint('⭐ Added to favorites: $itemType $itemId');
    } catch (e) {
      debugPrint('❌ Error adding to favorites: $e');
    }
  }

  /// Remove from favorites
  Future<void> removeFavorite(String itemId, String itemType) async {
    try {
      final db = await _db.database;
      
      await db.delete(
        _favoritesTable,
        where: 'item_id = ? AND item_type = ?',
        whereArgs: [itemId, itemType],
      );
      
      debugPrint('💔 Removed from favorites: $itemType $itemId');
    } catch (e) {
      debugPrint('❌ Error removing from favorites: $e');
    }
  }

  /// Check if item is favorite
  Future<bool> isFavorite(String itemId, String itemType) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        _favoritesTable,
        where: 'item_id = ? AND item_type = ?',
        whereArgs: [itemId, itemType],
        limit: 1,
      );
      
      return results.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking favorite: $e');
      return false;
    }
  }

  /// Get favorite tracks
  Future<List<TrackModel>> getFavoriteTracks() async {
    try {
      final db = await _db.database;
      
      final results = await db.rawQuery('''
        SELECT t.* FROM $_tracksTable t
        INNER JOIN $_favoritesTable f ON t.spotify_id = f.item_id
        WHERE f.item_type = 'track'
        ORDER BY f.added_at DESC
      ''');
      
      return results.map((map) => TrackModel.fromSQLite(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting favorite tracks: $e');
      return [];
    }
  }

  // -------------------- Cache Metadata Management -------------------- //

  /// Update cache metadata
  Future<void> _updateCacheMetadata(String cacheKey, String dataType) async {
    try {
      final db = await _db.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiresAt = DateTime.now().add(_cacheExpiry).millisecondsSinceEpoch;
      
      await db.insert(
        _cacheMetadataTable,
        {
          'cache_key': cacheKey,
          'cached_at': now,
          'expires_at': expiresAt,
          'data_type': dataType,
          'hit_count': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ Error updating cache metadata: $e');
    }
  }

  /// Check if cache is valid
  Future<bool> _isCacheValid(String cacheKey) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        _cacheMetadataTable,
        where: 'cache_key = ?',
        whereArgs: [cacheKey],
        limit: 1,
      );
      
      if (results.isEmpty) return false;
      
      final expiresAt = results.first['expires_at'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      return now < expiresAt;
    } catch (e) {
      return false;
    }
  }

  /// Increment cache hit count
  Future<void> _incrementHitCount(String cacheKey) async {
    try {
      final db = await _db.database;
      
      await db.rawUpdate('''
        UPDATE $_cacheMetadataTable 
        SET hit_count = hit_count + 1 
        WHERE cache_key = ?
      ''', [cacheKey]);
    } catch (e) {
      debugPrint('❌ Error incrementing hit count: $e');
    }
  }

  /// Invalidate specific cache
  Future<void> invalidateCache(String cacheKey) async {
    try {
      final db = await _db.database;
      
      await db.delete(
        _cacheMetadataTable,
        where: 'cache_key = ?',
        whereArgs: [cacheKey],
      );
      
      debugPrint('🗑️ Cache invalidated: $cacheKey');
    } catch (e) {
      debugPrint('❌ Error invalidating cache: $e');
    }
  }

  /// Clear expired cache
  Future<void> clearExpiredCache() async {
    try {
      final db = await _db.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final expired = await db.query(
        _cacheMetadataTable,
        where: 'expires_at < ?',
        whereArgs: [now],
      );
      
      for (var item in expired) {
        final cacheKey = item['cache_key'] as String;
        final dataType = item['data_type'] as String;
        final id = cacheKey.replaceFirst('${dataType}_', '');
        
        // Delete from respective table
        switch (dataType) {
          case 'track':
            await db.delete(_tracksTable, where: 'spotify_id = ?', whereArgs: [id]);
            break;
          case 'album':
            await db.delete(_albumsTable, where: 'spotify_id = ?', whereArgs: [id]);
            break;
          case 'artist':
            await db.delete(_artistsTable, where: 'spotify_id = ?', whereArgs: [id]);
            break;
          case 'playlist':
            await db.delete(_playlistsTable, where: 'spotify_id = ?', whereArgs: [id]);
            break;
        }
      }
      
      // Delete expired metadata
      await db.delete(
        _cacheMetadataTable,
        where: 'expires_at < ?',
        whereArgs: [now],
      );
      
      debugPrint('🧹 Cleared ${expired.length} expired cache entries');
    } catch (e) {
      debugPrint('❌ Error clearing expired cache: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      final db = await _db.database;
      final batch = db.batch();
      
      batch.delete(_tracksTable);
      batch.delete(_albumsTable);
      batch.delete(_artistsTable);
      batch.delete(_playlistsTable);
      batch.delete(_playlistTracksTable);
      batch.delete(_cacheMetadataTable);
      batch.delete(_searchHistoryTable);
      batch.delete(_recentlyPlayedTable);
      
      await batch.commit(noResult: true);
      
      debugPrint('🧹 All cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing all cache: $e');
    }
  }

  // -------------------- Statistics -------------------- //

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final db = await _db.database;
      
      final tracksCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tracksTable'),
      ) ?? 0;
      
      final albumsCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_albumsTable'),
      ) ?? 0;
      
      final artistsCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_artistsTable'),
      ) ?? 0;
      
      final playlistsCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_playlistsTable'),
      ) ?? 0;
      
      final totalSize = tracksCount + albumsCount + artistsCount + playlistsCount;
      
      return {
        'tracks': tracksCount,
        'albums': albumsCount,
        'artists': artistsCount,
        'playlists': playlistsCount,
        'totalItems': totalSize,
        'cacheExpiry': '${_cacheExpiry.inHours} hours',
      };
    } catch (e) {
      debugPrint('❌ Error getting cache stats: $e');
      return {};
    }
  }

  /// Close database
  Future<void> close() async {
    await _db.close();
  }
}

