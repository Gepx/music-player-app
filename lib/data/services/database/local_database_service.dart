import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';

/// Local Database Service using SQLite
/// Handles local storage for user data and caching
class LocalDatabaseService {
  LocalDatabaseService._();
  static final LocalDatabaseService instance = LocalDatabaseService._();

  Database? _database;

  // Table names
  static const String _userTable = 'users';
  static const String _tracksTable = 'tracks';
  static const String _albumsTable = 'albums';
  static const String _artistsTable = 'artists';
  static const String _playlistsTable = 'playlists';
  static const String _playlistTracksTable = 'playlist_tracks';
  static const String _searchHistoryTable = 'search_history';
  static const String _recentlyPlayedTable = 'recently_played';
  static const String _favoritesTable = 'user_favorites';
  static const String _cacheMetadataTable = 'cache_metadata';
  
  static const String _databaseName = 'music_player.db';
  static const int _databaseVersion = 2;  // Updated version

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);
      debugPrint('🗄️ Opening DB at: $path (web: $kIsWeb)');
      debugPrint('📁 Initializing database at: $path');

      final factory = databaseFactory;

      return await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error initializing database: $e');
      rethrow;
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🔨 Creating database tables...');

    // Users table
    await db.execute('''
      CREATE TABLE $_userTable (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        displayName TEXT,
        photoUrl TEXT,
        phoneNumber TEXT,
        createdAt INTEGER,
        lastLoginAt INTEGER,
        provider TEXT
      )
    ''');

    // Cache Metadata table
    await db.execute('''
      CREATE TABLE $_cacheMetadataTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cache_key TEXT UNIQUE NOT NULL,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        data_type TEXT NOT NULL,
        hit_count INTEGER DEFAULT 0
      )
    ''');

    // Tracks table
    await db.execute('''
      CREATE TABLE $_tracksTable (
        id TEXT PRIMARY KEY,
        spotify_id TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        artist_name TEXT,
        album_id TEXT,
        album_name TEXT,
        duration_ms INTEGER,
        preview_url TEXT,
        image_url TEXT,
        popularity INTEGER,
        explicit INTEGER DEFAULT 0,
        is_playable INTEGER DEFAULT 1,
        track_number INTEGER,
        disc_number INTEGER,
        added_at INTEGER,
        cached_at INTEGER NOT NULL
      )
    ''');

    // Albums table
    await db.execute('''
      CREATE TABLE $_albumsTable (
        id TEXT PRIMARY KEY,
        spotify_id TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        artist_name TEXT,
        release_date TEXT,
        total_tracks INTEGER,
        image_url TEXT,
        album_type TEXT,
        cached_at INTEGER NOT NULL
      )
    ''');

    // Artists table
    await db.execute('''
      CREATE TABLE $_artistsTable (
        id TEXT PRIMARY KEY,
        spotify_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        image_url TEXT,
        genres TEXT,
        popularity INTEGER,
        followers INTEGER,
        cached_at INTEGER NOT NULL
      )
    ''');

    // Playlists table
    await db.execute('''
      CREATE TABLE $_playlistsTable (
        id TEXT PRIMARY KEY,
        spotify_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        owner_id TEXT,
        owner_name TEXT,
        image_url TEXT,
        total_tracks INTEGER,
        is_public INTEGER DEFAULT 1,
        is_collaborative INTEGER DEFAULT 0,
        cached_at INTEGER NOT NULL
      )
    ''');

    // Playlist Tracks junction table
    await db.execute('''
      CREATE TABLE $_playlistTracksTable (
        playlist_id TEXT NOT NULL,
        track_id TEXT NOT NULL,
        position INTEGER,
        added_at INTEGER,
        PRIMARY KEY (playlist_id, track_id)
      )
    ''');

    // Search History table
    await db.execute('''
      CREATE TABLE $_searchHistoryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        search_type TEXT,
        results_count INTEGER,
        searched_at INTEGER NOT NULL
      )
    ''');

    // Recently Played table
    await db.execute('''
      CREATE TABLE $_recentlyPlayedTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        track_id TEXT NOT NULL,
        played_at INTEGER NOT NULL,
        context_type TEXT,
        context_id TEXT
      )
    ''');

    // User Favorites table
    await db.execute('''
      CREATE TABLE $_favoritesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id TEXT NOT NULL,
        item_type TEXT NOT NULL,
        added_at INTEGER NOT NULL,
        UNIQUE(item_id, item_type)
      )
    ''');

    // Create indexes for performance
    await _createIndexes(db);

    debugPrint('✅ Database tables created successfully');
  }

  /// Create indexes for better query performance
  Future<void> _createIndexes(Database db) async {
    debugPrint('📑 Creating indexes...');
    
    await db.execute('CREATE INDEX idx_tracks_spotify_id ON $_tracksTable(spotify_id)');
    await db.execute('CREATE INDEX idx_tracks_artist ON $_tracksTable(artist_name)');
    await db.execute('CREATE INDEX idx_tracks_album ON $_tracksTable(album_id)');
    await db.execute('CREATE INDEX idx_tracks_title ON $_tracksTable(title)');
    
    await db.execute('CREATE INDEX idx_albums_spotify_id ON $_albumsTable(spotify_id)');
    await db.execute('CREATE INDEX idx_albums_artist ON $_albumsTable(artist_name)');
    
    await db.execute('CREATE INDEX idx_artists_spotify_id ON $_artistsTable(spotify_id)');
    await db.execute('CREATE INDEX idx_artists_name ON $_artistsTable(name)');
    
    await db.execute('CREATE INDEX idx_playlists_spotify_id ON $_playlistsTable(spotify_id)');
    
    await db.execute('CREATE INDEX idx_cache_key ON $_cacheMetadataTable(cache_key)');
    await db.execute('CREATE INDEX idx_cache_type ON $_cacheMetadataTable(data_type)');
    
    await db.execute('CREATE INDEX idx_search_query ON $_searchHistoryTable(query)');
    await db.execute('CREATE INDEX idx_recently_played_at ON $_recentlyPlayedTable(played_at DESC)');
    
    debugPrint('✅ Indexes created successfully');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('⬆️ Upgrading database from version $oldVersion to $newVersion');
    
    // Migration from version 1 to 2 - Add Spotify caching tables
    if (oldVersion < 2) {
      debugPrint('📦 Migrating to version 2: Adding Spotify cache tables...');
      
      // Cache Metadata table
      await db.execute('''
        CREATE TABLE $_cacheMetadataTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cache_key TEXT UNIQUE NOT NULL,
          cached_at INTEGER NOT NULL,
          expires_at INTEGER NOT NULL,
          data_type TEXT NOT NULL,
          hit_count INTEGER DEFAULT 0
        )
      ''');

      // Tracks table
      await db.execute('''
        CREATE TABLE $_tracksTable (
          id TEXT PRIMARY KEY,
          spotify_id TEXT UNIQUE NOT NULL,
          title TEXT NOT NULL,
          artist_name TEXT,
          album_id TEXT,
          album_name TEXT,
          duration_ms INTEGER,
          preview_url TEXT,
          image_url TEXT,
          popularity INTEGER,
          explicit INTEGER DEFAULT 0,
          is_playable INTEGER DEFAULT 1,
          track_number INTEGER,
          disc_number INTEGER,
          added_at INTEGER,
          cached_at INTEGER NOT NULL
        )
      ''');

      // Albums table
      await db.execute('''
        CREATE TABLE $_albumsTable (
          id TEXT PRIMARY KEY,
          spotify_id TEXT UNIQUE NOT NULL,
          title TEXT NOT NULL,
          artist_name TEXT,
          release_date TEXT,
          total_tracks INTEGER,
          image_url TEXT,
          album_type TEXT,
          cached_at INTEGER NOT NULL
        )
      ''');

      // Artists table
      await db.execute('''
        CREATE TABLE $_artistsTable (
          id TEXT PRIMARY KEY,
          spotify_id TEXT UNIQUE NOT NULL,
          name TEXT NOT NULL,
          image_url TEXT,
          genres TEXT,
          popularity INTEGER,
          followers INTEGER,
          cached_at INTEGER NOT NULL
        )
      ''');

      // Playlists table
      await db.execute('''
        CREATE TABLE $_playlistsTable (
          id TEXT PRIMARY KEY,
          spotify_id TEXT UNIQUE NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          owner_id TEXT,
          owner_name TEXT,
          image_url TEXT,
          total_tracks INTEGER,
          is_public INTEGER DEFAULT 1,
          is_collaborative INTEGER DEFAULT 0,
          cached_at INTEGER NOT NULL
        )
      ''');

      // Playlist Tracks junction table
      await db.execute('''
        CREATE TABLE $_playlistTracksTable (
          playlist_id TEXT NOT NULL,
          track_id TEXT NOT NULL,
          position INTEGER,
          added_at INTEGER,
          PRIMARY KEY (playlist_id, track_id)
        )
      ''');

      // Search History table
      await db.execute('''
        CREATE TABLE $_searchHistoryTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT NOT NULL,
          search_type TEXT,
          results_count INTEGER,
          searched_at INTEGER NOT NULL
        )
      ''');

      // Recently Played table
      await db.execute('''
        CREATE TABLE $_recentlyPlayedTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          track_id TEXT NOT NULL,
          played_at INTEGER NOT NULL,
          context_type TEXT,
          context_id TEXT
        )
      ''');

      // User Favorites table
      await db.execute('''
        CREATE TABLE $_favoritesTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_id TEXT NOT NULL,
          item_type TEXT NOT NULL,
          added_at INTEGER NOT NULL,
          UNIQUE(item_id, item_type)
        )
      ''');

      // Create indexes
      await _createIndexes(db);
      
      debugPrint('✅ Migration to version 2 completed');
    }
  }

  // -------------------- User Operations -------------------- //

  /// Save or update user in local database
  Future<void> saveUser(UserModel user) async {
    try {
      final db = await database;
      await db.insert(
        _userTable,
        user.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('✅ User saved to local database: ${user.email}');
    } catch (e) {
      debugPrint('❌ Error saving user to database: $e');
      rethrow;
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final db = await database;
      final results = await db.query(
        _userTable,
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isEmpty) return null;
      return UserModel.fromSQLite(results.first);
    } catch (e) {
      debugPrint('❌ Error getting user by ID: $e');
      return null;
    }
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        _userTable,
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (results.isEmpty) return null;
      return UserModel.fromSQLite(results.first);
    } catch (e) {
      debugPrint('❌ Error getting user by email: $e');
      return null;
    }
  }

  /// Get the currently stored user (assumes single user per device)
  Future<UserModel?> getCurrentUser() async {
    try {
      final db = await database;
      final results = await db.query(
        _userTable,
        orderBy: 'lastLoginAt DESC',
        limit: 1,
      );

      if (results.isEmpty) return null;
      return UserModel.fromSQLite(results.first);
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      return null;
    }
  }

  /// Update user's last login time
  Future<void> updateLastLogin(String userId) async {
    try {
      final db = await database;
      await db.update(
        _userTable,
        {'lastLoginAt': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [userId],
      );
      debugPrint('✅ Updated last login for user: $userId');
    } catch (e) {
      debugPrint('❌ Error updating last login: $e');
      rethrow;
    }
  }

  /// Delete user from local database
  Future<void> deleteUser(String userId) async {
    try {
      final db = await database;
      await db.delete(_userTable, where: 'id = ?', whereArgs: [userId]);
      debugPrint('✅ User deleted from local database: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      rethrow;
    }
  }

  /// Clear all users from local database
  Future<void> clearAllUsers() async {
    try {
      final db = await database;
      await db.delete(_userTable);
      debugPrint('✅ All users cleared from local database');
    } catch (e) {
      debugPrint('❌ Error clearing users: $e');
      rethrow;
    }
  }

  /// Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint('🔒 Database connection closed');
    }
  }

  /// Check if database is healthy
  Future<bool> healthCheck() async {
    try {
      final db = await database;
      await db.query(_userTable, limit: 1);
      debugPrint('✅ Local database is healthy');
      return true;
    } catch (e) {
      debugPrint('❌ Local database health check failed: $e');
      return false;
    }
  }
}
