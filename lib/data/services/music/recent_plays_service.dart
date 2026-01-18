import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Note: we do not import the web ffi factory directly to avoid lint warnings; web path uses SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/spotify/spotify_track.dart';
import '../auth/auth_service.dart';
import '../database/firestore_history_service.dart';

/// Recent Plays Service (sqflite)
/// Stores recently played tracks locally for the "Recently Played" section
class RecentPlaysService {
  RecentPlaysService._();
  static final RecentPlaysService instance = RecentPlaysService._();

  static const _dbName = 'recent_plays.db';
  static const _dbVersion = 1;
  static const _table = 'recent_plays';
  static const _prefsKey = 'recent_plays_list';

  Database? _db;
  bool _opening = false;

  final AuthService _auth = AuthService.instance;
  final FirestoreHistoryService _history = FirestoreHistoryService.instance;

  Future<Database> _openDb() async {
    if (_db != null) return _db!;
    if (_opening) {
      // Simple wait loop to avoid concurrent opens
      while (_opening) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _db!;
    }
    _opening = true;

    // Ensure correct database factory on each platform (non-web)
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } else {
      // On Web we will not use sqflite at all – SharedPreferences instead
      _opening = false;
      throw UnimplementedError('DB not used on web');
    }
    
    try {
      String basePath;
      try {
        basePath = await databaseFactory.getDatabasesPath();
      } catch (_) {
        basePath = await getDatabasesPath();
      }
      final path = p.join(basePath, _dbName);
      _db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_table (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              artist TEXT NOT NULL,
              album TEXT,
              imageUrl TEXT,
              playedAt INTEGER NOT NULL
            )
          ''');
          await db.execute('CREATE INDEX idx_playedAt ON $_table(playedAt DESC)');
        },
      );
      return _db!;
    } catch (e) {
      debugPrint('❌ Failed to open DB, falling back to in-memory: $e');
      _db = await openDatabase(inMemoryDatabasePath, version: _dbVersion,
          onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            artist TEXT NOT NULL,
            album TEXT,
            imageUrl TEXT,
            playedAt INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_playedAt ON $_table(playedAt DESC)');
      });
      return _db!;
    } finally {
      _opening = false;
    }
  }

  /// Add or update a recently played track
  Future<void> addRecent(SpotifyTrack track) async {
    final data = {
      'id': track.id,
      'name': track.name,
      'artist': track.artists.map((a) => a.name).join(', '),
      'album': track.album?.name,
      'imageUrl': (track.album?.images.isNotEmpty == true)
          ? track.album!.images.first.url
          : null,
      'playedAt': DateTime.now().millisecondsSinceEpoch,
    };

    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final list = prefs.getStringList(_prefsKey) ?? <String>[];
        // Remove any existing entry with same id
        final filtered = list
            .map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(
                (s.isNotEmpty) ? (sDecode(s)) : {}))
            .where((m) => m['id'] != data['id'])
            .toList();
        filtered.insert(0, data);
        // Cap to 20
        while (filtered.length > 20) filtered.removeLast();
        await prefs.setStringList(_prefsKey, filtered.map((m) => sEncode(m)).toList());
      } catch (e) {
        debugPrint('❌ RecentPlays(web) add error: $e');
      }
      return;
    }

    try {
      final db = await _openDb();
      await db.insert(
        _table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ RecentPlays add error: $e');
    }

    // Fire-and-forget cloud sync (only when signed in).
    final user = _auth.currentFirebaseUser;
    if (user != null) {
      // Don't block UI; any failures should be silent.
      // ignore: unawaited_futures
      _history
          .recordPlay(userId: user.uid, track: track)
          .catchError((_) {});
    }
  }

  /// Get most recent tracks (as simple maps for UI)
  Future<List<Map<String, dynamic>>> getRecent({int limit = 8}) async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final list = prefs.getStringList(_prefsKey) ?? <String>[];
        final maps = list
            .map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(
                (s.isNotEmpty) ? (sDecode(s)) : {}))
            .where((m) => m.isNotEmpty)
            .toList();
        maps.sort((a, b) => (b['playedAt'] as int).compareTo(a['playedAt'] as int));
        return maps.take(limit).toList();
      } catch (e) {
        debugPrint('❌ RecentPlays(web) query error: $e');
        return [];
      }
    }

    try {
      final db = await _openDb();
      final rows = await db.query(
        _table,
        orderBy: 'playedAt DESC',
        limit: limit,
      );
      return rows;
    } catch (e) {
      debugPrint('❌ RecentPlays query error: $e');
      return [];
    }
  }

  /// Sync recent listening history from Firestore into the local cache.
  ///
  /// This is intended to run after login so "Recently Played" is consistent
  /// across devices.
  Future<void> syncFromCloud({int limit = 20}) async {
    final user = _auth.currentFirebaseUser;
    if (user == null) return;

    final items = await _history.getRecentHistory(userId: user.uid, limit: limit);
    if (items.isEmpty) return;

    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        // Convert to the same map shape used by the web local cache.
        final normalized =
            items.map((m) => <String, dynamic>{
              'id': m['id'],
              'name': m['name'],
              'artist': m['artist'],
              'album': m['album'],
              'imageUrl': m['imageUrl'],
              'playedAt': m['playedAt'] ?? DateTime.now().millisecondsSinceEpoch,
            }).toList();

        // Cap to 20 like the existing web logic.
        while (normalized.length > 20) normalized.removeLast();
        await prefs.setStringList(
          _prefsKey,
          normalized.map((m) => sEncode(m)).toList(),
        );
      } catch (e) {
        debugPrint('❌ RecentPlays syncFromCloud(web) error: $e');
      }
      return;
    }

    try {
      final db = await _openDb();
      final batch = db.batch();

      for (final m in items) {
        batch.insert(
          _table,
          <String, dynamic>{
            'id': m['id'],
            'name': m['name'],
            'artist': m['artist'],
            'album': m['album'],
            'imageUrl': m['imageUrl'],
            'playedAt': m['playedAt'] ?? DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('❌ RecentPlays syncFromCloud error: $e');
    }
  }

  // Simple JSON helpers without importing dart:convert at top level to keep file tidy
  static String sEncode(Map<String, dynamic> m) => jsonEncode(m);
  static Map<String, dynamic> sDecode(String s) => jsonDecode(s) as Map<String, dynamic>;
}


