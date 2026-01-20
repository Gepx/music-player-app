import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user/liked_playlist.dart';

/// Liked Playlists Database Service (sqflite for native, SharedPreferences for web)
/// Manages local storage of user's liked playlists
class LikedPlaylistsDbService {
  LikedPlaylistsDbService._();
  static final LikedPlaylistsDbService instance = LikedPlaylistsDbService._();

  static const _dbName = 'liked_playlists.db';
  static const _dbVersion = 1;
  static const _table = 'liked_playlists';
  static const _webPrefsKey = 'liked_playlists_web_storage';

  Database? _db;
  bool _opening = false;
  SharedPreferences? _prefs;

  Future<Database> _openDb() async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }

    if (_db != null && !_db!.isOpen) {
      debugPrint('⚠️ Liked Playlists DB was closed, reopening...');
      _db = null;
    }

    if (_opening) {
      while (_opening) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _db!;
    }
    _opening = true;

    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } else {
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
      debugPrint('📁 Opening LikedPlaylists database at: $path');

      _db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: (db, version) async {
          debugPrint('🔧 Creating LikedPlaylists database tables...');
          await db.execute('''
            CREATE TABLE $_table (
              playlistId TEXT NOT NULL,
              userId TEXT NOT NULL,
              likedAt INTEGER NOT NULL,
              syncStatus TEXT DEFAULT 'synced',
              name TEXT,
              description TEXT,
              trackIds TEXT,
              isPublic INTEGER DEFAULT 0,
              createdAt INTEGER,
              updatedAt INTEGER,
              PRIMARY KEY (userId, playlistId)
            )
          ''');

          await db.execute('CREATE INDEX idx_userId_likedAt ON $_table(userId, likedAt DESC)');
          await db.execute('CREATE INDEX idx_syncStatus ON $_table(syncStatus)');
          debugPrint('✅ LikedPlaylists database ready');
        },
      );

      _opening = false;
      return _db!;
    } catch (e) {
      _opening = false;
      debugPrint('❌ Error opening LikedPlaylists database: $e');
      rethrow;
    }
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<LikedPlaylist>> _loadWebLikedPlaylists() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_webPrefsKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => LikedPlaylist.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading web liked playlists: $e');
      return [];
    }
  }

  Future<void> _saveWebLikedPlaylists(List<LikedPlaylist> playlists) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = jsonEncode(playlists.map((p) => p.toJson()).toList());
      await prefs.setString(_webPrefsKey, jsonString);
      debugPrint('💾 Saved ${playlists.length} liked playlists to web storage');
    } catch (e) {
      debugPrint('❌ Error saving web liked playlists: $e');
    }
  }

  Future<void> likePlaylist(LikedPlaylist likedPlaylist) async {
    if (kIsWeb) {
      final playlists = await _loadWebLikedPlaylists();
      playlists.removeWhere((p) => p.playlistId == likedPlaylist.playlistId);
      playlists.insert(0, likedPlaylist);
      await _saveWebLikedPlaylists(playlists);
      debugPrint('❤️ Liked playlist (web): ${likedPlaylist.name ?? likedPlaylist.playlistId}');
      return;
    }

    final db = await _openDb();
    await db.insert(
      _table,
      likedPlaylist.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('❤️ Liked playlist: ${likedPlaylist.name ?? likedPlaylist.playlistId}');
  }

  Future<void> unlikePlaylist(String userId, String playlistId) async {
    if (kIsWeb) {
      final playlists = await _loadWebLikedPlaylists();
      playlists.removeWhere((p) => p.playlistId == playlistId && p.userId == userId);
      await _saveWebLikedPlaylists(playlists);
      debugPrint('💔 Unliked playlist (web): $playlistId');
      return;
    }

    final db = await _openDb();
    await db.delete(
      _table,
      where: 'userId = ? AND playlistId = ?',
      whereArgs: [userId, playlistId],
    );
    debugPrint('💔 Unliked playlist: $playlistId');
  }

  Future<List<LikedPlaylist>> getLikedPlaylists(String userId) async {
    if (kIsWeb) {
      final playlists = await _loadWebLikedPlaylists();
      final userPlaylists = playlists.where((p) => p.userId == userId).toList();
      userPlaylists.sort((a, b) => b.likedAt.compareTo(a.likedAt));
      return userPlaylists;
    }

    final db = await _openDb();
    final rows = await db.query(
      _table,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'likedAt DESC',
    );
    return rows.map(LikedPlaylist.fromDb).toList();
  }

  Future<Set<String>> getLikedPlaylistIds(String userId) async {
    if (kIsWeb) {
      final playlists = await _loadWebLikedPlaylists();
      return playlists
          .where((p) => p.userId == userId)
          .map((p) => p.playlistId)
          .toSet();
    }

    final db = await _openDb();
    final rows = await db.query(
      _table,
      columns: ['playlistId'],
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return rows.map((row) => row['playlistId'] as String).toSet();
  }

  Future<int> getLikedCount(String userId) async {
    if (kIsWeb) {
      final playlists = await _loadWebLikedPlaylists();
      return playlists.where((p) => p.userId == userId).length;
    }

    final db = await _openDb();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_table WHERE userId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<LikedPlaylist>> getPendingLikes(String userId) async {
    if (kIsWeb) return [];
    final db = await _openDb();
    final rows = await db.query(
      _table,
      where: 'userId = ? AND syncStatus = ?',
      whereArgs: [userId, 'pending'],
    );
    return rows.map(LikedPlaylist.fromDb).toList();
  }

  Future<void> markAsSynced(String playlistId) async {
    if (kIsWeb) return;
    final db = await _openDb();
    await db.update(
      _table,
      {'syncStatus': 'synced'},
      where: 'playlistId = ?',
      whereArgs: [playlistId],
    );
  }
}
