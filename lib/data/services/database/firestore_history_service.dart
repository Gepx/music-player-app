import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:music_player/data/models/spotify/spotify_track.dart';

import 'firestore_service.dart';

/// Firestore History Service
/// Stores a per-user "listening_history" under:
/// `users/{userId}/listening_history/{trackId}`
///
/// NOTE: Using trackId as the doc ID means this represents the *latest* play
/// time for a track (deduped by track).
class FirestoreHistoryService {
  FirestoreHistoryService._();
  static final FirestoreHistoryService instance = FirestoreHistoryService._();

  final FirestoreService _firestore = FirestoreService.instance;

  CollectionReference<Map<String, dynamic>> _historyCollection(String userId) {
    return _firestore.users.doc(userId).collection('listening_history');
  }

  /// Record a play for a track for the given user.
  Future<void> recordPlay({
    required String userId,
    required SpotifyTrack track,
    DateTime? playedAt,
  }) async {
    try {
      final when = playedAt ?? DateTime.now();

      final data = <String, dynamic>{
        'trackId': track.id,
        'trackName': track.name,
        'artistName': track.artists.map((a) => a.name).join(', '),
        'albumId': track.album?.id,
        'albumName': track.album?.name,
        'imageUrl':
            (track.album?.images.isNotEmpty == true) ? track.album!.images.first.url : null,
        'durationMs': track.durationMs,
        'playedAt': Timestamp.fromDate(when),
      };

      await _historyCollection(userId).doc(track.id).set(
            data,
            SetOptions(merge: true),
          );

      // Best-effort prune to keep the collection bounded.
      await pruneHistory(userId: userId, keep: 50);
    } catch (e) {
      debugPrint('❌ FirestoreHistory recordPlay error: $e');
      rethrow;
    }
  }

  /// Fetch recent listening history items as maps (UI-friendly).
  Future<List<Map<String, dynamic>>> getRecentHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final snap = await _historyCollection(userId)
          .orderBy('playedAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs.map((d) => normalizeHistoryData(d.id, d.data())).toList();
    } catch (e) {
      debugPrint('❌ FirestoreHistory getRecentHistory error: $e');
      return [];
    }
  }

  @visibleForTesting
  static Map<String, dynamic> normalizeHistoryData(
    String docId,
    Map<String, dynamic> data,
  ) {
    final playedAt = data['playedAt'];
    final playedAtMs = playedAt is Timestamp ? playedAt.millisecondsSinceEpoch : null;
    return <String, dynamic>{
      ...data,
      // Normalize for consumers that expect millis.
      if (playedAtMs != null) 'playedAt': playedAtMs,
      // Ensure an id field consistent with RecentPlays local schema.
      'id': data['trackId'] ?? docId,
      'name': data['trackName'],
      'artist': data['artistName'],
      'album': data['albumName'],
    };
  }

  /// Keep only [keep] most recent docs; delete the rest.
  Future<void> pruneHistory({
    required String userId,
    int keep = 50,
  }) async {
    try {
      final snap = await _historyCollection(userId)
          .orderBy('playedAt', descending: true)
          .limit(keep + 20)
          .get();

      if (snap.docs.length <= keep) return;

      final toDelete = snap.docs.sublist(keep);
      final batch = _firestore.batch();
      for (final doc in toDelete) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Pruning is best-effort; don't surface errors to callers.
      debugPrint('⚠️ FirestoreHistory pruneHistory error: $e');
    }
  }
}

