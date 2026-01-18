import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/services/database/firestore_history_service.dart';

void main() {
  test('normalizeHistoryData normalizes playedAt and fields', () {
    final data = <String, dynamic>{
      'trackId': 't1',
      'trackName': 'Song',
      'artistName': 'Artist',
      'albumName': 'Album',
      'playedAt': Timestamp.fromMillisecondsSinceEpoch(1234),
    };

    final normalized = FirestoreHistoryService.normalizeHistoryData('doc', data);

    expect(normalized['id'], 't1');
    expect(normalized['name'], 'Song');
    expect(normalized['artist'], 'Artist');
    expect(normalized['album'], 'Album');
    expect(normalized['playedAt'], 1234);
  });
}

