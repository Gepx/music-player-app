import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Firestore Database Service
/// Handles all Cloud Firestore operations
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get Firestore instance
  FirebaseFirestore get db => _db;

  // -------------------- Helper Methods -------------------- //

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  /// Get document reference
  DocumentReference<Map<String, dynamic>> document(String path) => _db.doc(path);

  // -------------------- Common Collections -------------------- //

  /// Users collection
  CollectionReference<Map<String, dynamic>> get users => collection('users');

  /// Songs collection
  CollectionReference<Map<String, dynamic>> get songs => collection('songs');

  /// Playlists collection
  CollectionReference<Map<String, dynamic>> get playlists =>
      collection('playlists');

  /// Albums collection
  CollectionReference<Map<String, dynamic>> get albums => collection('albums');

  /// Artists collection
  CollectionReference<Map<String, dynamic>> get artists => collection('artists');

  // -------------------- Health Check -------------------- //

  /// Check Firestore connection health
  Future<bool> healthCheck() async {
    try {
      await _db.collection('_health').doc('ping').get();
      debugPrint('✅ Firestore is healthy');
      return true;
    } catch (e) {
      debugPrint('❌ Firestore health check failed: $e');
      return false;
    }
  }

  // -------------------- Batch Operations -------------------- //

  /// Create a new batch
  WriteBatch batch() => _db.batch();

  /// Execute a batch write
  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
      debugPrint('✅ Batch write completed');
    } catch (e) {
      debugPrint('❌ Batch write failed: $e');
      rethrow;
    }
  }

  // -------------------- Transaction Operations -------------------- //

  /// Run a transaction
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await _db.runTransaction(transactionHandler, timeout: timeout);
    } catch (e) {
      debugPrint('❌ Transaction failed: $e');
      rethrow;
    }
  }
}

