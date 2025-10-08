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
  static const String _databaseName = 'music_player.db';
  static const int _databaseVersion = 1;

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

      debugPrint('📁 Initializing database at: $path');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
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

    debugPrint('✅ Database tables created successfully');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('⬆️ Upgrading database from version $oldVersion to $newVersion');
    // Add migration logic here when updating database schema
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
      await db.delete(
        _userTable,
        where: 'id = ?',
        whereArgs: [userId],
      );
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

