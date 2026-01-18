import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user/liked_track.dart';

/// Liked Tracks Database Service (sqflite for native, SharedPreferences for web)
/// Manages local storage of user's liked tracks
class LikedTracksDbService {
  LikedTracksDbService._();
  static final LikedTracksDbService instance = LikedTracksDbService._();

  static const _dbName = 'liked_tracks.db';
  static const _dbVersion = 2;
  static const _table = 'liked_tracks';
  static const _webPrefsKey = 'liked_tracks_web_storage';

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
      debugPrint('⚠️ Liked Tracks DB was closed, reopening...');
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
      debugPrint('📁 Opening LikedTracks database at: $path');

      _db = await openDatabase(
        path,
        version: _dbVersion,
        onUpgrade: (db, oldVersion, newVersion) async {
          // v2: make likes user-scoped by using composite primary key (userId, trackId)
          // and avoid global trackId collisions between different users.
          if (oldVersion < 2) {
            debugPrint('🔧 Migrating LikedTracks DB to v2...');
            await db.execute('''
              CREATE TABLE ${_table}_v2 (
                trackId TEXT NOT NULL,
                userId TEXT NOT NULL,
                likedAt INTEGER NOT NULL,
                syncStatus TEXT DEFAULT 'synced',
                name TEXT,
                artist TEXT,
                album TEXT,
                imageUrl TEXT,
                durationMs INTEGER,
                PRIMARY KEY (userId, trackId)
              )
            ''');

            // Attempt to migrate existing data. Old schema could only store 1 row per trackId
            // so we just copy it over as-is.
            await db.execute('''
              INSERT OR REPLACE INTO ${_table}_v2
              (trackId, userId, likedAt, syncStatus, name, artist, album, imageUrl, durationMs)
              SELECT trackId, userId, likedAt, syncStatus, name, artist, album, imageUrl, durationMs
              FROM $_table
            ''');

            await db.execute('DROP TABLE IF EXISTS $_table');
            await db.execute('ALTER TABLE ${_table}_v2 RENAME TO $_table');

            // Recreate indexes
            await db.execute('DROP INDEX IF EXISTS idx_userId_likedAt');
            await db.execute('DROP INDEX IF EXISTS idx_syncStatus');
            await db.execute('CREATE INDEX idx_userId_likedAt ON $_table(userId, likedAt DESC)');
            await db.execute('CREATE INDEX idx_syncStatus ON $_table(syncStatus)');
            debugPrint('✅ LikedTracks DB migrated to v2');
          }
        },
        onCreate: (db, version) async {
          debugPrint('🔧 Creating LikedTracks database tables...');
          
          await db.execute('''
            CREATE TABLE $_table (
              trackId TEXT NOT NULL,
              userId TEXT NOT NULL,
              likedAt INTEGER NOT NULL,
              syncStatus TEXT DEFAULT 'synced',
              name TEXT,
              artist TEXT,
              album TEXT,
              imageUrl TEXT,
              durationMs INTEGER
              ,
              PRIMARY KEY (userId, trackId)
            )
          ''');
          
          // Create indexes
          await db.execute('CREATE INDEX idx_userId_likedAt ON $_table(userId, likedAt DESC)');
          await db.execute('CREATE INDEX idx_syncStatus ON $_table(syncStatus)');
          
          debugPrint('✅ LikedTracks database created successfully');
        },
        onOpen: (db) async {
          debugPrint('✅ LikedTracks database opened successfully');
        },
      );
      return _db!;
    } catch (e) {
      debugPrint('❌ Failed to open LikedTracks DB: $e');
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

  Future<List<LikedTrack>> _getWebLikedTracks() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_webPrefsKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<LikedTrack> tracks = [];
      
      for (final json in jsonList) {
        try {
          if (json is Map<String, dynamic>) {
            tracks.add(LikedTrack.fromJson(json));
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing liked track: $e');
          // Skip malformed tracks
        }
      }
      
      return tracks;
    } catch (e) {
      debugPrint('❌ Error loading web liked tracks: $e');
      return [];
    }
  }

  Future<void> _saveWebLikedTracks(List<LikedTrack> tracks) async {
    try {
      final prefs = await _getPrefs();
      final jsonList = tracks.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_webPrefsKey, jsonString);
      debugPrint('💾 Saved ${tracks.length} liked tracks to web storage');
    } catch (e) {
      debugPrint('❌ Error saving web liked tracks: $e');
      rethrow;
    }
  }

  // ========== CRUD Operations ========== //

  /// Like a track
  Future<void> likeTrack(LikedTrack likedTrack) async {
    if (kIsWeb) {
      try {
        final tracks = await _getWebLikedTracks();
        // Remove if exists, then add (update)
        tracks.removeWhere((t) => t.trackId == likedTrack.trackId);
        tracks.insert(0, likedTrack);
        await _saveWebLikedTracks(tracks);
        debugPrint('❤️ Liked track (web): ${likedTrack.name ?? likedTrack.trackId}');
      } catch (e) {
        debugPrint('❌ Like track error (web): $e');
        rethrow;
      }
      return;
    }
    
    try {
      final db = await _openDb();
      await db.insert(
        _table,
        likedTrack.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('❤️ Liked track: ${likedTrack.name ?? likedTrack.trackId}');
    } catch (e) {
      debugPrint('❌ Like track error: $e');
      rethrow;
    }
  }

  /// Unlike a track
  Future<void> unlikeTrack(String userId, String trackId) async {
    if (kIsWeb) {
      try {
        final tracks = await _getWebLikedTracks();
        tracks.removeWhere((t) => t.userId == userId && t.trackId == trackId);
        await _saveWebLikedTracks(tracks);
        debugPrint('💔 Unliked track (web): $trackId');
      } catch (e) {
        debugPrint('❌ Unlike track error (web): $e');
        rethrow;
      }
      return;
    }
    
    try {
      final db = await _openDb();
      await db.delete(
        _table,
        where: 'userId = ? AND trackId = ?',
        whereArgs: [userId, trackId],
      );
      debugPrint('💔 Unliked track: $trackId');
    } catch (e) {
      debugPrint('❌ Unlike track error: $e');
      rethrow;
    }
  }

  /// Check if track is liked
  Future<bool> isLiked(String userId, String trackId) async {
    if (kIsWeb) {
      try {
        final tracks = await _getWebLikedTracks();
        return tracks.any((t) => t.userId == userId && t.trackId == trackId);
      } catch (e) {
        debugPrint('❌ Check liked error (web): $e');
        return false;
      }
    }
    
    try {
      final db = await _openDb();
      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM $_table WHERE userId = ? AND trackId = ?',
          [userId, trackId],
        ),
      );
      return (count ?? 0) > 0;
    } catch (e) {
      debugPrint('❌ Check liked error: $e');
      return false;
    }
  }

  /// Get all liked tracks for a user
  Future<List<LikedTrack>> getLikedTracks(String userId) async {
    if (kIsWeb) {
      try {
        final allTracks = await _getWebLikedTracks();
        final userTracks = allTracks.where((t) => t.userId == userId).toList();
        // Sort by liked date
        userTracks.sort((a, b) => b.likedAt.compareTo(a.likedAt));
        debugPrint('📖 Retrieved ${userTracks.length} liked tracks (web)');
        return userTracks;
      } catch (e) {
        debugPrint('❌ Get liked tracks error (web): $e');
        return [];
      }
    }
    
    try {
      final db = await _openDb();
      final rows = await db.query(
        _table,
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'likedAt DESC',
      );
      
      final tracks = rows.map((row) => LikedTrack.fromDb(row)).toList();
      debugPrint('📖 Retrieved ${tracks.length} liked tracks');
      return tracks;
    } catch (e) {
      debugPrint('❌ Get liked tracks error: $e');
      return [];
    }
  }

  /// Get liked track IDs set for quick lookup
  Future<Set<String>> getLikedTrackIds(String userId) async {
    if (kIsWeb) {
      try {
        final tracks = await _getWebLikedTracks();
        return tracks.where((t) => t.userId == userId).map((t) => t.trackId).toSet();
      } catch (e) {
        debugPrint('❌ Get liked track IDs error (web): $e');
        return {};
      }
    }
    
    try {
      final db = await _openDb();
      final rows = await db.query(
        _table,
        columns: ['trackId'],
        where: 'userId = ?',
        whereArgs: [userId],
      );
      
      return rows.map((row) => row['trackId'] as String).toSet();
    } catch (e) {
      debugPrint('❌ Get liked track IDs error: $e');
      return {};
    }
  }

  /// Get liked tracks count
  Future<int> getLikedCount(String userId) async {
    if (kIsWeb) {
      try {
        final tracks = await _getWebLikedTracks();
        return tracks.where((t) => t.userId == userId).length;
      } catch (e) {
        debugPrint('❌ Get liked count error (web): $e');
        return 0;
      }
    }
    
    try {
      final db = await _openDb();
      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM $_table WHERE userId = ?',
          [userId],
        ),
      );
      return count ?? 0;
    } catch (e) {
      debugPrint('❌ Get liked count error: $e');
      return 0;
    }
  }

  /// Get pending liked tracks (need sync)
  Future<List<LikedTrack>> getPendingLikes(String userId) async {
    if (kIsWeb) {
      try {
        final tracks = await _getWebLikedTracks();
        return tracks.where((t) => t.userId == userId && t.syncStatus == 'pending').toList();
      } catch (e) {
        debugPrint('❌ Get pending likes error (web): $e');
        return [];
      }
    }
    
    try {
      final db = await _openDb();
      final rows = await db.query(
        _table,
        where: 'userId = ? AND syncStatus = ?',
        whereArgs: [userId, 'pending'],
      );
      
      return rows.map((row) => LikedTrack.fromDb(row)).toList();
    } catch (e) {
      debugPrint('❌ Get pending likes error: $e');
      return [];
    }
  }

  /// Mark track as synced
  Future<void> markAsSynced(String trackId) async {
    if (kIsWeb) {
      try {
        final tracks = await _getWebLikedTracks();
        final index = tracks.indexWhere((t) => t.trackId == trackId);
        if (index != -1) {
          tracks[index] = tracks[index].copyWith(syncStatus: 'synced');
          await _saveWebLikedTracks(tracks);
        }
      } catch (e) {
        debugPrint('❌ Mark synced error (web): $e');
      }
      return;
    }
    
    try {
      final db = await _openDb();
      await db.update(
        _table,
        {'syncStatus': 'synced'},
        where: 'trackId = ?',
        whereArgs: [trackId],
      );
    } catch (e) {
      debugPrint('❌ Mark synced error: $e');
    }
  }

  /// Search liked tracks
  Future<List<LikedTrack>> searchLikedTracks(String userId, String query) async {
    if (kIsWeb) {
      try {
        final tracks = await _getWebLikedTracks();
        final lowerQuery = query.toLowerCase();
        return tracks
            .where((t) => 
                t.userId == userId &&
                ((t.name?.toLowerCase().contains(lowerQuery) ?? false) ||
                 (t.artist?.toLowerCase().contains(lowerQuery) ?? false)))
            .toList()
          ..sort((a, b) => b.likedAt.compareTo(a.likedAt));
      } catch (e) {
        debugPrint('❌ Search liked tracks error (web): $e');
        return [];
      }
    }
    
    try {
      final db = await _openDb();
      final rows = await db.query(
        _table,
        where: 'userId = ? AND (name LIKE ? OR artist LIKE ?)',
        whereArgs: [userId, '%$query%', '%$query%'],
        orderBy: 'likedAt DESC',
      );
      
      return rows.map((row) => LikedTrack.fromDb(row)).toList();
    } catch (e) {
      debugPrint('❌ Search liked tracks error: $e');
      return [];
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
      debugPrint('🔒 LikedTracks database closed');
    }
  }
}

