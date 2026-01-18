import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user/playlist.dart';

/// Playlist Database Service (sqflite for native, SharedPreferences for web)
/// Manages local storage of user playlists
class PlaylistDbService {
  PlaylistDbService._();
  static final PlaylistDbService instance = PlaylistDbService._();

  static const _dbName = 'playlists.db';
  static const _dbVersion = 1;
  static const _playlistsTable = 'playlists';
  static const _tracksTable = 'playlist_tracks';
  static const _webPrefsKey = 'playlists_web_storage';

  Database? _db;
  bool _opening = false;
  SharedPreferences? _prefs;

  Future<Database> _openDb() async {
    // Check if database is already open and valid
    if (_db != null && _db!.isOpen) {
      return _db!;
    }

    // If database was closed, reset it
    if (_db != null && !_db!.isOpen) {
      debugPrint('⚠️ Playlist DB was closed, reopening...');
      _db = null;
    }

    if (_opening) {
      // Wait for concurrent open to complete
      while (_opening) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _db!;
    }
    _opening = true;

    // Ensure correct database factory on each platform
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } else {
      // On Web, sqflite is not supported - return null to indicate no DB
      _opening = false;
      _db = null;
      return Future.error('Web platform does not support sqflite');
    }

    try {
      String basePath;
      try {
        basePath = await databaseFactory.getDatabasesPath();
      } catch (_) {
        basePath = await getDatabasesPath();
      }
      final path = p.join(basePath, _dbName);
      debugPrint('📁 Opening Playlist database at: $path');

      _db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: (db, version) async {
          debugPrint('🔧 Creating Playlist database tables...');
          
          // Playlists table
          await db.execute('''
            CREATE TABLE $_playlistsTable (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT,
              userId TEXT NOT NULL,
              trackIds TEXT,
              createdAt INTEGER NOT NULL,
              updatedAt INTEGER NOT NULL,
              isPublic INTEGER DEFAULT 0,
              syncStatus TEXT DEFAULT 'synced'
            )
          ''');
          
          // Playlist tracks table (for track ordering and metadata)
          await db.execute('''
            CREATE TABLE $_tracksTable (
              playlistId TEXT NOT NULL,
              trackId TEXT NOT NULL,
              position INTEGER NOT NULL,
              addedAt INTEGER NOT NULL,
              PRIMARY KEY (playlistId, trackId)
            )
          ''');
          
          // Create indexes
          await db.execute('CREATE INDEX idx_userId ON $_playlistsTable(userId)');
          await db.execute('CREATE INDEX idx_playlistId ON $_tracksTable(playlistId)');
          
          debugPrint('✅ Playlist database created successfully');
        },
        onOpen: (db) async {
          debugPrint('✅ Playlist database opened successfully');
        },
      );
      return _db!;
    } catch (e) {
      debugPrint('❌ Failed to open Playlist DB: $e');
      rethrow;
    } finally {
      _opening = false;
    }
  }

  // ========== Web Storage Helpers ========== //
  
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<Playlist>> _getWebPlaylists() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_webPrefsKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<Playlist> playlists = [];
      
      for (final json in jsonList) {
        try {
          if (json is Map<String, dynamic>) {
            playlists.add(Playlist.fromJson(json));
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing playlist: $e');
          // Skip malformed playlists
        }
      }
      
      return playlists;
    } catch (e) {
      debugPrint('❌ Error loading web playlists: $e');
      return [];
    }
  }

  Future<void> _saveWebPlaylists(List<Playlist> playlists) async {
    try {
      final prefs = await _getPrefs();
      final jsonList = playlists.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_webPrefsKey, jsonString);
      debugPrint('💾 Saved ${playlists.length} playlists to web storage');
    } catch (e) {
      debugPrint('❌ Error saving web playlists: $e');
      rethrow;
    }
  }

  // ========== CRUD Operations ========== //

  /// Create a new playlist
  Future<void> createPlaylist(Playlist playlist) async {
    if (kIsWeb) {
      try {
        final playlists = await _getWebPlaylists();
        playlists.add(playlist);
        await _saveWebPlaylists(playlists);
        debugPrint('💾 Created playlist (web): ${playlist.name}');
      } catch (e) {
        debugPrint('❌ Create playlist error (web): $e');
        rethrow;
      }
      return;
    }
    
    try {
      final db = await _openDb();
      await db.insert(
        _playlistsTable,
        playlist.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Insert track positions if any tracks exist
      if (playlist.trackIds.isNotEmpty) {
        await _updatePlaylistTracks(db, playlist.id, playlist.trackIds);
      }
      
      debugPrint('💾 Created playlist: ${playlist.name}');
    } catch (e) {
      debugPrint('❌ Create playlist error: $e');
      rethrow;
    }
  }

  /// Update playlist metadata
  Future<void> updatePlaylist(Playlist playlist) async {
    if (kIsWeb) {
      try {
        final playlists = await _getWebPlaylists();
        final index = playlists.indexWhere((p) => p.id == playlist.id);
        if (index != -1) {
          playlists[index] = playlist;
          await _saveWebPlaylists(playlists);
          debugPrint('📝 Updated playlist (web): ${playlist.name}');
        }
      } catch (e) {
        debugPrint('❌ Update playlist error (web): $e');
        rethrow;
      }
      return;
    }
    
    try {
      final db = await _openDb();
      await db.update(
        _playlistsTable,
        playlist.toDb(),
        where: 'id = ?',
        whereArgs: [playlist.id],
      );
      
      // Update track positions
      await _updatePlaylistTracks(db, playlist.id, playlist.trackIds);
      
      debugPrint('📝 Updated playlist: ${playlist.name}');
    } catch (e) {
      debugPrint('❌ Update playlist error: $e');
      rethrow;
    }
  }

  /// Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    if (kIsWeb) {
      try {
        final playlists = await _getWebPlaylists();
        playlists.removeWhere((p) => p.id == playlistId);
        await _saveWebPlaylists(playlists);
        debugPrint('🗑️ Deleted playlist (web): $playlistId');
      } catch (e) {
        debugPrint('❌ Delete playlist error (web): $e');
        rethrow;
      }
      return;
    }
    
    try {
      final db = await _openDb();
      await db.delete(
        _playlistsTable,
        where: 'id = ?',
        whereArgs: [playlistId],
      );
      
      // Delete associated tracks
      await db.delete(
        _tracksTable,
        where: 'playlistId = ?',
        whereArgs: [playlistId],
      );
      
      debugPrint('🗑️ Deleted playlist: $playlistId');
    } catch (e) {
      debugPrint('❌ Delete playlist error: $e');
      rethrow;
    }
  }

  /// Get all playlists for a user
  Future<List<Playlist>> getPlaylists(String userId) async {
    if (kIsWeb) {
      try {
        final allPlaylists = await _getWebPlaylists();
        final userPlaylists = allPlaylists.where((p) => p.userId == userId).toList();
        // Sort by updated date
        userPlaylists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        debugPrint('📖 Retrieved ${userPlaylists.length} playlists (web)');
        return userPlaylists;
      } catch (e) {
        debugPrint('❌ Get playlists error (web): $e');
        return [];
      }
    }
    
    try {
      final db = await _openDb();
      final rows = await db.query(
        _playlistsTable,
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'updatedAt DESC',
      );
      
      final playlists = rows.map((row) => Playlist.fromDb(row)).toList();
      debugPrint('📖 Retrieved ${playlists.length} playlists');
      return playlists;
    } catch (e) {
      debugPrint('❌ Get playlists error: $e');
      return [];
    }
  }

  /// Get a single playlist by ID
  Future<Playlist?> getPlaylist(String playlistId) async {
    if (kIsWeb) {
      try {
        final playlists = await _getWebPlaylists();
        return playlists.firstWhere(
          (p) => p.id == playlistId,
          orElse: () => throw Exception('Not found'),
        );
      } catch (e) {
        debugPrint('❌ Get playlist error (web): $e');
        return null;
      }
    }
    
    try {
      final db = await _openDb();
      final rows = await db.query(
        _playlistsTable,
        where: 'id = ?',
        whereArgs: [playlistId],
        limit: 1,
      );
      
      if (rows.isEmpty) return null;
      return Playlist.fromDb(rows.first);
    } catch (e) {
      debugPrint('❌ Get playlist error: $e');
      return null;
    }
  }

  /// Add track to playlist
  Future<void> addTrack(String playlistId, String trackId) async {
    try {
      final playlist = await getPlaylist(playlistId);
      if (playlist == null) {
        throw Exception('Playlist not found');
      }
      
      // Check if track already exists
      if (playlist.trackIds.contains(trackId)) {
        debugPrint('⚠️ Track already in playlist');
        return;
      }
      
      final updatedTrackIds = [...playlist.trackIds, trackId];
      final updatedPlaylist = playlist.copyWith(
        trackIds: updatedTrackIds,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      
      await updatePlaylist(updatedPlaylist);
      debugPrint('➕ Added track to playlist: $trackId');
    } catch (e) {
      debugPrint('❌ Add track error: $e');
      rethrow;
    }
  }

  /// Remove track from playlist
  Future<void> removeTrack(String playlistId, String trackId) async {
    try {
      final playlist = await getPlaylist(playlistId);
      if (playlist == null) {
        throw Exception('Playlist not found');
      }
      
      final updatedTrackIds = playlist.trackIds.where((id) => id != trackId).toList();
      final updatedPlaylist = playlist.copyWith(
        trackIds: updatedTrackIds,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      
      await updatePlaylist(updatedPlaylist);
      
      // Remove from tracks table
      final db = await _openDb();
      await db.delete(
        _tracksTable,
        where: 'playlistId = ? AND trackId = ?',
        whereArgs: [playlistId, trackId],
      );
      
      debugPrint('➖ Removed track from playlist: $trackId');
    } catch (e) {
      debugPrint('❌ Remove track error: $e');
      rethrow;
    }
  }

  /// Reorder tracks in playlist
  Future<void> reorderTracks(String playlistId, List<String> newTrackOrder) async {
    try {
      final playlist = await getPlaylist(playlistId);
      if (playlist == null) {
        throw Exception('Playlist not found');
      }
      
      final updatedPlaylist = playlist.copyWith(
        trackIds: newTrackOrder,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      
      await updatePlaylist(updatedPlaylist);
      debugPrint('🔄 Reordered tracks in playlist');
    } catch (e) {
      debugPrint('❌ Reorder tracks error: $e');
      rethrow;
    }
  }

  /// Update playlist tracks table with positions
  Future<void> _updatePlaylistTracks(Database db, String playlistId, List<String> trackIds) async {
    // Delete existing track records for this playlist
    await db.delete(
      _tracksTable,
      where: 'playlistId = ?',
      whereArgs: [playlistId],
    );
    
    // Insert new track records with positions
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < trackIds.length; i++) {
      await db.insert(
        _tracksTable,
        {
          'playlistId': playlistId,
          'trackId': trackIds[i],
          'position': i,
          'addedAt': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get playlists that need sync
  Future<List<Playlist>> getPendingPlaylists(String userId) async {
    if (kIsWeb) {
      try {
        final allPlaylists = await _getWebPlaylists();
        return allPlaylists
            .where((p) => p.userId == userId && p.syncStatus == 'pending')
            .toList();
      } catch (e) {
        debugPrint('❌ Get pending playlists error (web): $e');
        return [];
      }
    }
    
    try {
      final db = await _openDb();
      final rows = await db.query(
        _playlistsTable,
        where: 'userId = ? AND syncStatus = ?',
        whereArgs: [userId, 'pending'],
      );
      
      return rows.map((row) => Playlist.fromDb(row)).toList();
    } catch (e) {
      debugPrint('❌ Get pending playlists error: $e');
      return [];
    }
  }

  /// Mark playlist as synced
  Future<void> markAsSynced(String playlistId) async {
    if (kIsWeb) {
      try {
        final playlist = await getPlaylist(playlistId);
        if (playlist != null) {
          final updatedPlaylist = playlist.copyWith(syncStatus: 'synced');
          await updatePlaylist(updatedPlaylist);
        }
      } catch (e) {
        debugPrint('❌ Mark synced error (web): $e');
      }
      return;
    }
    
    try {
      final db = await _openDb();
      await db.update(
        _playlistsTable,
        {'syncStatus': 'synced'},
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    } catch (e) {
      debugPrint('❌ Mark synced error: $e');
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
      debugPrint('🔒 Playlist database closed');
    }
  }
}

