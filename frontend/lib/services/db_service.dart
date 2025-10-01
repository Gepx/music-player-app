import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;

  CollectionReference<Map<String, dynamic>> col(String path) =>
      _db.collection(path);
  DocumentReference<Map<String, dynamic>> doc(String path) => _db.doc(path);

  Future<void> healthCheck() async {
    try {
      await _db.collection('_health').doc('ping').get();
      debugPrint('Firestore is ok.');
    } catch (e) {
      debugPrint('Firestore is failed: $e');
      rethrow;
    }
  }
}
