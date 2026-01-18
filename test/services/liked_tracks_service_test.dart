import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/models/user/liked_track.dart';
import 'package:music_player/data/services/liked/liked_tracks_service.dart';

void main() {
  test('LikedTracksService sortLikedTracks sorts by name and artist', () {
    final service = LikedTracksService.instance;

    final tracks = [
      LikedTrack(
        trackId: '1',
        userId: 'u',
        likedAt: DateTime(2024, 1, 1),
        name: 'Beta',
        artist: 'Zed',
      ),
      LikedTrack(
        trackId: '2',
        userId: 'u',
        likedAt: DateTime(2024, 1, 2),
        name: 'Alpha',
        artist: 'Able',
      ),
    ];

    service.setTestState(
      likedIds: {'1', '2'},
      likedTracks: tracks,
    );

    final byName = service.sortLikedTracks('name');
    expect(byName.map((t) => t.trackId).toList(), ['2', '1']);

    final byArtist = service.sortLikedTracks('artist');
    expect(byArtist.map((t) => t.trackId).toList(), ['2', '1']);

    final recent = service.sortLikedTracks('recent');
    // 'recent' keeps the stored order (db returns DESC); we keep insertion order in test.
    expect(recent.map((t) => t.trackId).toList(), ['1', '2']);
  });

  test('LikedTracksService isLiked uses cached ids', () {
    final service = LikedTracksService.instance;
    service.setTestState(likedIds: {'t1'}, likedTracks: const []);

    expect(service.isLiked('t1'), isTrue);
    expect(service.isLiked('t2'), isFalse);
  });
}

