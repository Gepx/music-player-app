import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:flutter/foundation.dart';
import '../../../data/services/spotify/spotify_services.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/models/spotify/spotify_search_result.dart';

/// Spotify API Test Controller
/// Handles all test operations for the API testing screen
/// Uses static API token from .env (not OAuth)
class SpotifyApiTestController extends GetxController {
  final SpotifyAuthService _authService = SpotifyAuthService.instance;
  final SpotifyApiService _apiService = SpotifyApiService.instance;
  final MusicRepository _musicRepo = MusicRepository.instance;
  final SpotifyCacheService _cache = SpotifyCacheService.instance;

  // Observable state
  final RxBool isConfigured = false.obs;
  final RxBool isLoading = false.obs;
  final RxList<TestResult> results = <TestResult>[].obs;

  // Test data IDs (Spotify examples)
  final String testTrackId = '3n3Ppam7vgaVa1iaRUc9Lp'; // Mr. Brightside
  final String testAlbumId =
      '4aawyAB9vmqN3uQ7FjRGTy'; // Hot Fuss by The Killers
  final String testArtistId = '0C0XlULifJtAgn6ZNCW2eu'; // The Killers
  final String testPlaylistId = '37i9dQZF1DXcBWIGoYBM5M'; // Today's Top Hits

  @override
  void onInit() {
    super.onInit();
    checkConfiguration();
  }

  // -------------------- Helper Methods -------------------- //

  void checkConfiguration() async {
    isConfigured.value = await _authService.isConfigured;
  }

  void addResult(TestResult result) {
    results.insert(0, result);
    if (results.length > 20) {
      results.removeLast();
    }
  }

  void clearResults() {
    results.clear();
  }

  String _formatTimestamp() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  // -------------------- Configuration Tests -------------------- //

  Future<void> testCheckConfiguration() async {
    final testName = 'Check API Configuration';
    addResult(
      TestResult(
        testName: testName,
        status: TestStatus.loading,
        timestamp: _formatTimestamp(),
      ),
    );

    try {
      final configured = await _authService.isConfigured;
      final token = _authService.getAccessToken();

      isConfigured.value = configured;

      if (configured && token != null) {
        // Mask token for security
        final maskedToken =
            token.length > 20
                ? '${token.substring(0, 10)}...${token.substring(token.length - 10)}'
                : '***masked***';

        addResult(
          TestResult(
            testName: testName,
            status: TestStatus.success,
            message: '✅ Spotify API is configured',
            data: {
              'tokenPreview': maskedToken,
              'tokenLength': token.length,
              'source': 'Environment variable (.env)',
              'note': 'Token is loaded from .env file',
            },
            timestamp: _formatTimestamp(),
          ),
        );
      } else {
        addResult(
          TestResult(
            testName: testName,
            status: TestStatus.error,
            message: '❌ Spotify API token not configured',
            data: {
              'note': 'Add SPOTIFY_API_TOKEN to your .env file',
              'help': 'Get token from: https://developer.spotify.com/console/',
            },
            timestamp: _formatTimestamp(),
          ),
        );
      }
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    }
  }

  // -------------------- Search Tests -------------------- //

  Future<void> testSearchTracks() async {
    final testName = 'Search Tracks';
    isLoading.value = true;

    addResult(
      TestResult(
        testName: testName,
        status: TestStatus.loading,
        message: 'Searching for "The Killers"...',
        timestamp: _formatTimestamp(),
      ),
    );

    try {
      final result = await _apiService.search(
        query: 'The Killers',
        type: SpotifySearchType.track,
        limit: 5,
      );

      final tracks = result.tracks?.items ?? [];

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Found ${tracks.length} tracks',
          data: {
            'count': tracks.length,
            'tracks':
                tracks
                    .map(
                      (t) => {
                        'name': t.name,
                        'artists': t.artists.map((a) => a.name).join(', '),
                        'id': t.id,
                      },
                    )
                    .toList(),
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> testSearchAlbums() async {
    final testName = 'Search Albums';
    isLoading.value = true;

    try {
      final result = await _apiService.search(
        query: 'Hot Fuss',
        type: SpotifySearchType.album,
        limit: 5,
      );

      final albums = result.albums?.items ?? [];

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Found ${albums.length} albums',
          data: {
            'count': albums.length,
            'albums':
                albums
                    .map(
                      (a) => {
                        'name': a.name,
                        'artists': a.artists
                            .map((artist) => artist.name)
                            .join(', '),
                        'releaseDate': a.releaseDate,
                      },
                    )
                    .toList(),
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> testSearchArtists() async {
    final testName = 'Search Artists';
    isLoading.value = true;

    try {
      final result = await _apiService.search(
        query: 'The Killers',
        type: SpotifySearchType.artist,
        limit: 5,
      );

      final artists = result.artists?.items ?? [];

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Found ${artists.length} artists',
          data: {
            'count': artists.length,
            'artists':
                artists
                    .map(
                      (a) => {
                        'name': a.name,
                        'genres': a.genres ?? [],
                        'popularity': a.popularity,
                      },
                    )
                    .toList(),
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- Track Tests -------------------- //

  Future<void> testGetTrack() async {
    final testName = 'Get Track by ID';
    isLoading.value = true;

    try {
      final track = await _apiService.getTrack(testTrackId);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved: ${track.name}',
          data: {
            'name': track.name,
            'artists': track.artists.map((a) => a.name).join(', '),
            'album': track.album?.name,
            'duration': '${track.durationMs ~/ 1000}s',
            'popularity': track.popularity,
            'explicit': track.explicit,
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> testGetSavedTracks() async {
    final testName = 'Get Saved Tracks';
    isLoading.value = true;

    try {
      final result = await _apiService.getUserSavedTracks(limit: 10);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved ${result.items.length} saved tracks',
          data: {
            'total': result.total,
            'limit': result.limit,
            'tracks':
                result.items
                    .take(5)
                    .map(
                      (t) => {
                        'name': t.name,
                        'artists': t.artists.map((a) => a.name).join(', '),
                      },
                    )
                    .toList(),
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> testSaveTrack() async {
    final testName = 'Save Track';
    isLoading.value = true;

    try {
      final success = await _apiService.saveTracks([testTrackId]);

      addResult(
        TestResult(
          testName: testName,
          status: success ? TestStatus.success : TestStatus.error,
          message:
              success ? 'Track saved successfully' : 'Failed to save track',
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- Album Tests -------------------- //

  Future<void> testGetAlbum() async {
    final testName = 'Get Album';
    isLoading.value = true;

    try {
      final album = await _apiService.getAlbum(testAlbumId);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved: ${album.name}',
          data: {
            'name': album.name,
            'artists': album.artists.map((a) => a.name).join(', '),
            'releaseDate': album.releaseDate,
            'totalTracks': album.totalTracks,
            'albumType': album.albumType,
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> testGetAlbumTracks() async {
    final testName = 'Get Album Tracks';
    isLoading.value = true;

    try {
      final result = await _apiService.getAlbumTracks(testAlbumId, limit: 10);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved ${result.items.length} tracks',
          data: {
            'total': result.total,
            'tracks':
                result.items
                    .map(
                      (t) => {
                        'name': t.name,
                        'trackNumber': t.trackNumber,
                        'duration': '${t.durationMs ~/ 1000}s',
                      },
                    )
                    .toList(),
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- Artist Tests -------------------- //

  Future<void> testGetArtist() async {
    final testName = 'Get Artist';
    isLoading.value = true;

    try {
      final artist = await _apiService.getArtist(testArtistId);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved: ${artist.name}',
          data: {
            'name': artist.name,
            'genres': artist.genres,
            'popularity': artist.popularity,
            'followers': artist.followers?.total,
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> testGetArtistTopTracks() async {
    final testName = 'Get Artist Top Tracks';
    isLoading.value = true;

    try {
      final tracks = await _apiService.getArtistTopTracks(testArtistId);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved ${tracks.length} top tracks',
          data: {
            'count': tracks.length,
            'tracks':
                tracks
                    .take(5)
                    .map(
                      (t) => {
                        'name': t.name,
                        'popularity': t.popularity,
                        'album': t.album?.name,
                      },
                    )
                    .toList(),
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- Playlist Tests -------------------- //

  Future<void> testGetUserPlaylists() async {
    final testName = 'Get User Playlists';
    isLoading.value = true;

    try {
      final result = await _apiService.getUserPlaylists(limit: 10);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved ${result.items.length} playlists',
          data: {
            'total': result.total,
            'playlists':
                result.items
                    .map(
                      (p) => {
                        'name': p.name,
                        'owner': p.owner.displayName ?? p.owner.id,
                        'tracks': p.tracks?.total ?? 0,
                      },
                    )
                    .toList(),
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> testGetPlaylist() async {
    final testName = 'Get Playlist';
    isLoading.value = true;

    try {
      final playlist = await _apiService.getPlaylist(testPlaylistId);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved: ${playlist.name}',
          data: {
            'name': playlist.name,
            'description': playlist.description,
            'owner': playlist.owner.displayName ?? playlist.owner.id,
            'tracks': playlist.tracks?.total ?? 0,
            'public': playlist.public,
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- Browse Tests -------------------- //

  Future<void> testGetFeaturedPlaylists() async {
    final testName = 'Get Featured Playlists';
    isLoading.value = true;

    try {
      final playlists = await _apiService.getFeaturedPlaylists(limit: 5);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved ${playlists.length} featured playlists',
          data: {
            'count': playlists.length,
            'playlists':
                playlists
                    .map((p) => {'name': p.name, 'description': p.description})
                    .toList(),
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> testGetNewReleases() async {
    final testName = 'Get New Releases';
    isLoading.value = true;

    try {
      final albums = await _apiService.getNewReleases(limit: 5);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved ${albums.length} new releases',
          data: {
            'count': albums.length,
            'albums':
                albums
                    .map(
                      (a) => {
                        'name': a.name,
                        'artists': a.artists
                            .map((artist) => artist.name)
                            .join(', '),
                        'releaseDate': a.releaseDate,
                      },
                    )
                    .toList(),
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- Recommendations Tests -------------------- //

  Future<void> testGetRecommendations() async {
    final testName = 'Get Recommendations';
    isLoading.value = true;

    try {
      final tracks = await _apiService.getRecommendations(
        seedTracks: [testTrackId],
        limit: 5,
      );

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Retrieved ${tracks.length} recommendations',
          data: {
            'count': tracks.length,
            'tracks':
                tracks
                    .map(
                      (t) => {
                        'name': t.name,
                        'artists': t.artists.map((a) => a.name).join(', '),
                      },
                    )
                    .toList(),
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- Repository Tests -------------------- //

  Future<void> testMusicRepository() async {
    final testName = 'Test Music Repository';
    isLoading.value = true;

    try {
      // Test search
      final tracks = await _musicRepo.searchTracks('The Killers', limit: 3);

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Repository working! Found ${tracks.length} tracks',
          data: {
            'searchResults':
                tracks
                    .map(
                      (t) => {
                        'title': t.title,
                        'artist': t.artistName,
                        'cached': t.addedAt != null,
                      },
                    )
                    .toList(),
            'note': 'Data was mapped to app models and cached',
          },
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> testCache() async {
    final testName = 'Test Cache';
    isLoading.value = true;

    try {
      final stats = _cache.getCacheStats();

      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.success,
          message: 'Cache is working',
          data: {'statistics': stats, 'totalSize': _cache.getTotalCacheSize()},
          timestamp: _formatTimestamp(),
        ),
      );
    } catch (e) {
      addResult(
        TestResult(
          testName: testName,
          status: TestStatus.error,
          message: 'Error: $e',
          timestamp: _formatTimestamp(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

// -------------------- Test Result Model -------------------- //

enum TestStatus { loading, success, error }

class TestResult {
  final String testName;
  final TestStatus status;
  final String message;
  final dynamic data;
  final String timestamp;

  TestResult({
    required this.testName,
    required this.status,
    this.message = '',
    this.data,
    required this.timestamp,
  });
}
