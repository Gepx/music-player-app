import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/spotify/spotify_models.dart';
import '../../models/dto/dto_models.dart';
import '../../../utils/constants/spotify_constants.dart';
import 'spotify_auth_service.dart';

/// Spotify API Service
/// Handles all Spotify Web API calls
class SpotifyApiService {
  SpotifyApiService._();
  static final SpotifyApiService instance = SpotifyApiService._();

  final http.Client _client = http.Client();
  final SpotifyAuthService _authService = SpotifyAuthService.instance;

  // Simple in-memory cache + in-flight de-dupe to prevent repetitive calls.
  final Map<String, SpotifyTrack> _trackCache = {};
  final Map<String, Future<SpotifyTrack>> _inFlightTrackRequests = {};

  // -------------------- Helper Methods -------------------- //

  /// Make authenticated GET request
  Future<http.Response> _get(String endpoint, {Map<String, String>? queryParams}) async {
    final headers = await _authService.getAuthHeaders();
    final uri = Uri.parse('${SpotifyConstants.baseUrl}$endpoint')
        .replace(queryParameters: queryParams);
    
    debugPrint('🌐 GET: $uri');
    return await _client.get(uri, headers: headers);
  }

  /// Make authenticated POST request
  Future<http.Response> _post(String endpoint, {Object? body}) async {
    final headers = await _authService.getAuthHeaders();
    final uri = Uri.parse('${SpotifyConstants.baseUrl}$endpoint');
    
    debugPrint('🌐 POST: $uri');
    return await _client.post(uri, headers: headers, body: jsonEncode(body));
  }

  /// Make authenticated PUT request
  Future<http.Response> _put(String endpoint, {Object? body}) async {
    final headers = await _authService.getAuthHeaders();
    final uri = Uri.parse('${SpotifyConstants.baseUrl}$endpoint');
    
    debugPrint('🌐 PUT: $uri');
    return await _client.put(uri, headers: headers, body: jsonEncode(body));
  }

  /// Make authenticated DELETE request
  Future<http.Response> _delete(String endpoint, {Object? body}) async {
    final headers = await _authService.getAuthHeaders();
    final uri = Uri.parse('${SpotifyConstants.baseUrl}$endpoint');
    
    debugPrint('🌐 DELETE: $uri');
    return await _client.delete(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
  }

  /// Handle API response
  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return fromJson(json);
    } else {
      final error = SpotifyError.fromJson(jsonDecode(response.body));
      throw SpotifyApiException(error.message, error.status);
    }
  }

  @visibleForTesting
  T handleResponseForTest<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return _handleResponse(response, fromJson);
  }

  // -------------------- Search -------------------- //

  /// Search for tracks, albums, artists, or playlists
  Future<SpotifySearchResult> search({
    required String query,
    SpotifySearchType type = SpotifySearchType.all,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      debugPrint('🔍 Searching for: $query (type: ${type.apiValue})');
      
      final response = await _get(
        SpotifyConstants.searchEndpoint,
        queryParams: {
          'q': query,
          'type': type.apiValue,
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Filter out null items from the results and clean nested nulls
        final cleanedJson = <String, dynamic>{};
        
        for (final key in ['tracks', 'albums', 'artists', 'playlists']) {
          if (json[key] != null) {
            final section = json[key] as Map<String, dynamic>;
            if (section['items'] != null) {
              final items = (section['items'] as List)
                  .where((item) => item != null)
                  .map((item) {
                    // Clean nested arrays that might contain nulls
                    if (item is Map<String, dynamic>) {
                      final cleanedItem = Map<String, dynamic>.from(item);
                      if (cleanedItem['artists'] is List) {
                        cleanedItem['artists'] = (cleanedItem['artists'] as List)
                            .where((artist) => artist != null)
                            .toList();
                      }
                      return cleanedItem;
                    }
                    return item;
                  })
                  .toList();
              cleanedJson[key] = {...section, 'items': items};
            }
          }
        }
        
        return SpotifySearchResult.fromJson(cleanedJson);
      } else {
        final error = SpotifyError.fromJson(jsonDecode(response.body));
        throw SpotifyApiException(error.message, error.status);
      }
    } catch (e) {
      debugPrint('❌ Search error: $e');
      rethrow;
    }
  }

  /// Convenience helper to search for tracks only
  Future<List<SpotifyTrack>> searchTracks(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await search(
      query: query,
      type: SpotifySearchType.track,
      limit: limit,
      offset: offset,
    );

    return result.tracks?.items ?? const [];
  }

  // -------------------- Tracks -------------------- //

  /// Get a track by ID
  Future<SpotifyTrack> getTrack(String trackId) async {
    final cached = _trackCache[trackId];
    if (cached != null) return cached;

    final inFlight = _inFlightTrackRequests[trackId];
    if (inFlight != null) return inFlight;

    final future = _getTrackNetwork(trackId);
    _inFlightTrackRequests[trackId] = future;
    try {
      final track = await future;
      _trackCache[trackId] = track;
      return track;
    } finally {
      _inFlightTrackRequests.remove(trackId);
    }
  }

  Future<SpotifyTrack> _getTrackNetwork(String trackId) async {
    try {
      debugPrint('🎵 Getting track: $trackId');
      final endpoint =
          SpotifyConstants.replaceId(SpotifyConstants.trackEndpoint, trackId);
      final response = await _get(endpoint);
      return _handleResponse(response, SpotifyTrack.fromJson);
    } catch (e) {
      debugPrint('❌ Get track error: $e');
      rethrow;
    }
  }

  /// Get multiple tracks by IDs
  Future<List<SpotifyTrack>> getTracks(List<String> trackIds) async {
    try {
      debugPrint('🎵 Getting ${trackIds.length} tracks');
      
      final response = await _get(
        SpotifyConstants.tracksEndpoint,
        queryParams: {'ids': trackIds.join(',')},
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tracks = (json['tracks'] as List)
          .map((t) => SpotifyTrack.fromJson(t as Map<String, dynamic>))
          .toList();

      return tracks;
    } catch (e) {
      debugPrint('❌ Get tracks error: $e');
      rethrow;
    }
  }

  /// Get user's saved tracks
  Future<PagingDto<SpotifyTrack>> getUserSavedTracks({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      debugPrint('📚 Getting saved tracks (limit: $limit, offset: $offset)');
      
      final response = await _get(
        SpotifyConstants.savedTracksEndpoint,
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      // Saved tracks response wraps tracks in items with added_at
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['items'] as List)
          .map((item) => SpotifyTrack.fromJson(item['track'] as Map<String, dynamic>))
          .toList();

      return PagingDto<SpotifyTrack>(
        href: json['href'] as String?,
        items: items,
        limit: json['limit'] as int,
        next: json['next'] as String?,
        offset: json['offset'] as int,
        previous: json['previous'] as String?,
        total: json['total'] as int,
      );
    } catch (e) {
      debugPrint('❌ Get saved tracks error: $e');
      rethrow;
    }
  }

  /// Save tracks to user's library
  Future<bool> saveTracks(List<String> trackIds) async {
    try {
      debugPrint('💾 Saving ${trackIds.length} tracks');
      
      final response = await _put(
        SpotifyConstants.savedTracksEndpoint,
        body: {'ids': trackIds},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Save tracks error: $e');
      return false;
    }
  }

  /// Remove tracks from user's library
  Future<bool> removeTracks(List<String> trackIds) async {
    try {
      debugPrint('🗑️ Removing ${trackIds.length} tracks');
      
      final response = await _delete(
        SpotifyConstants.savedTracksEndpoint,
        body: {'ids': trackIds},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Remove tracks error: $e');
      return false;
    }
  }

  /// Check if tracks are saved
  Future<List<bool>> checkSavedTracks(List<String> trackIds) async {
    try {
      debugPrint('✓ Checking ${trackIds.length} saved tracks');
      
      final response = await _get(
        '${SpotifyConstants.savedTracksEndpoint}/contains',
        queryParams: {'ids': trackIds.join(',')},
      );

      final list = jsonDecode(response.body) as List;
      return list.cast<bool>();
    } catch (e) {
      debugPrint('❌ Check saved tracks error: $e');
      rethrow;
    }
  }

  // -------------------- Albums -------------------- //

  /// Get an album by ID
  Future<SpotifyAlbum> getAlbum(String albumId) async {
    try {
      debugPrint('💿 Getting album: $albumId');
      
      final endpoint = SpotifyConstants.replaceId(SpotifyConstants.albumEndpoint, albumId);
      final response = await _get(endpoint);

      return _handleResponse(response, SpotifyAlbum.fromJson);
    } catch (e) {
      debugPrint('❌ Get album error: $e');
      rethrow;
    }
  }

  /// Get album tracks
  Future<PagingDto<SpotifyTrack>> getAlbumTracks(String albumId, {int limit = 20, int offset = 0}) async {
    try {
      debugPrint('🎵 Getting album tracks: $albumId');
      
      final endpoint = SpotifyConstants.replaceId(SpotifyConstants.albumTracksEndpoint, albumId);
      final response = await _get(
        endpoint,
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      return _handleResponse(
        response,
        (json) => PagingDto<SpotifyTrack>.fromJson(json, (item) => SpotifyTrack.fromJson(item as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('❌ Get album tracks error: $e');
      rethrow;
    }
  }

  /// Get user's saved albums
  Future<PagingDto<SpotifyAlbum>> getUserSavedAlbums({int limit = 20, int offset = 0}) async {
    try {
      debugPrint('📚 Getting saved albums');
      
      final response = await _get(
        SpotifyConstants.savedAlbumsEndpoint,
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['items'] as List)
          .map((item) => SpotifyAlbum.fromJson(item['album'] as Map<String, dynamic>))
          .toList();

      return PagingDto<SpotifyAlbum>(
        href: json['href'] as String?,
        items: items,
        limit: json['limit'] as int,
        next: json['next'] as String?,
        offset: json['offset'] as int,
        previous: json['previous'] as String?,
        total: json['total'] as int,
      );
    } catch (e) {
      debugPrint('❌ Get saved albums error: $e');
      rethrow;
    }
  }

  /// Save albums to user's library
  Future<bool> saveAlbums(List<String> albumIds) async {
    try {
      debugPrint('💾 Saving ${albumIds.length} albums');
      
      final response = await _put(
        SpotifyConstants.savedAlbumsEndpoint,
        body: {'ids': albumIds},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Save albums error: $e');
      return false;
    }
  }

  // -------------------- Artists -------------------- //

  /// Get an artist by ID
  Future<SpotifyArtist> getArtist(String artistId) async {
    try {
      debugPrint('👤 Getting artist: $artistId');
      
      final endpoint = SpotifyConstants.replaceId(SpotifyConstants.artistEndpoint, artistId);
      final response = await _get(endpoint);

      return _handleResponse(response, SpotifyArtist.fromJson);
    } catch (e) {
      debugPrint('❌ Get artist error: $e');
      rethrow;
    }
  }

  /// Get artist's top tracks
  Future<List<SpotifyTrack>> getArtistTopTracks(String artistId, {String market = 'US'}) async {
    try {
      debugPrint('🎵 Getting artist top tracks: $artistId');
      
      final endpoint = SpotifyConstants.replaceId(SpotifyConstants.artistTopTracksEndpoint, artistId);
      final response = await _get(endpoint, queryParams: {'market': market});

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tracks = (json['tracks'] as List)
          .map((t) => SpotifyTrack.fromJson(t as Map<String, dynamic>))
          .toList();

      return tracks;
    } catch (e) {
      debugPrint('❌ Get artist top tracks error: $e');
      rethrow;
    }
  }

  /// Get artist's albums
  Future<PagingDto<SpotifyAlbum>> getArtistAlbums(
    String artistId, {
    int limit = 20,
    int offset = 0,
    String? includeGroups,
  }) async {
    try {
      debugPrint('💿 Getting artist albums: $artistId');
      
      final endpoint = SpotifyConstants.replaceId(SpotifyConstants.artistAlbumsEndpoint, artistId);
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (includeGroups != null) {
        queryParams['include_groups'] = includeGroups;
      }
      
      final response = await _get(endpoint, queryParams: queryParams);

      return _handleResponse(
        response,
        (json) => PagingDto<SpotifyAlbum>.fromJson(json, (item) => SpotifyAlbum.fromJson(item as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('❌ Get artist albums error: $e');
      rethrow;
    }
  }

  /// Get related artists
  Future<List<SpotifyArtist>> getRelatedArtists(String artistId) async {
    try {
      debugPrint('👥 Getting related artists: $artistId');
      
      final endpoint = SpotifyConstants.replaceId(SpotifyConstants.artistRelatedArtistsEndpoint, artistId);
      final response = await _get(endpoint);

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final artists = (json['artists'] as List)
          .map((a) => SpotifyArtist.fromJson(a as Map<String, dynamic>))
          .toList();

      return artists;
    } catch (e) {
      debugPrint('❌ Get related artists error: $e');
      rethrow;
    }
  }

  // -------------------- Playlists -------------------- //

  /// Get a playlist by ID
  Future<SpotifyPlaylist> getPlaylist(String playlistId) async {
    try {
      debugPrint('📋 Getting playlist: $playlistId');
      
      final endpoint = SpotifyConstants.replaceId(SpotifyConstants.playlistEndpoint, playlistId);
      final response = await _get(endpoint);

      return _handleResponse(response, SpotifyPlaylist.fromJson);
    } catch (e) {
      debugPrint('❌ Get playlist error: $e');
      rethrow;
    }
  }

  /// Get user's playlists
  Future<PagingDto<SpotifyPlaylist>> getUserPlaylists({int limit = 20, int offset = 0}) async {
    try {
      debugPrint('📚 Getting user playlists');
      
      final response = await _get(
        SpotifyConstants.userPlaylistsEndpoint,
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      return _handleResponse(
        response,
        (json) => PagingDto<SpotifyPlaylist>.fromJson(json, (item) => SpotifyPlaylist.fromJson(item as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('❌ Get user playlists error: $e');
      rethrow;
    }
  }

  /// Get playlist tracks
  Future<PagingDto<SpotifyTrack>> getPlaylistTracks(
    String playlistId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      debugPrint('🎵 Getting playlist tracks: $playlistId');
      
      final endpoint = SpotifyConstants.replaceId(SpotifyConstants.playlistTracksEndpoint, playlistId);
      final response = await _get(
        endpoint,
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['items'] as List)
          .map((item) => SpotifyTrack.fromJson(item['track'] as Map<String, dynamic>))
          .toList();

      return PagingDto<SpotifyTrack>(
        href: json['href'] as String?,
        items: items,
        limit: json['limit'] as int,
        next: json['next'] as String?,
        offset: json['offset'] as int,
        previous: json['previous'] as String?,
        total: json['total'] as int,
      );
    } catch (e) {
      debugPrint('❌ Get playlist tracks error: $e');
      rethrow;
    }
  }

  /// Create a playlist
  Future<SpotifyPlaylist> createPlaylist({
    required String userId,
    required String name,
    String? description,
    bool public = true,
  }) async {
    try {
      debugPrint('📝 Creating playlist: $name');
      
      final response = await _post(
        '${SpotifyConstants.userEndpoint.replaceAll('{id}', userId)}/playlists',
        body: {
          'name': name,
          if (description != null) 'description': description,
          'public': public,
        },
      );

      return _handleResponse(response, SpotifyPlaylist.fromJson);
    } catch (e) {
      debugPrint('❌ Create playlist error: $e');
      rethrow;
    }
  }

  /// Add tracks to playlist
  Future<bool> addTracksToPlaylist(String playlistId, List<String> trackUris) async {
    try {
      debugPrint('➕ Adding ${trackUris.length} tracks to playlist');
      
      final endpoint = SpotifyConstants.replaceId(SpotifyConstants.playlistTracksEndpoint, playlistId);
      final response = await _post(endpoint, body: {'uris': trackUris});

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Add tracks to playlist error: $e');
      return false;
    }
  }

  // -------------------- Recommendations -------------------- //

  /// Get recommendations
  Future<List<SpotifyTrack>> getRecommendations({
    List<String>? seedTracks,
    List<String>? seedArtists,
    List<String>? seedGenres,
    int limit = 20,
  }) async {
    try {
      debugPrint('🎲 Getting recommendations');
      
      final queryParams = <String, String>{'limit': limit.toString()};
      
      if (seedTracks != null && seedTracks.isNotEmpty) {
        queryParams['seed_tracks'] = seedTracks.join(',');
      }
      if (seedArtists != null && seedArtists.isNotEmpty) {
        queryParams['seed_artists'] = seedArtists.join(',');
      }
      if (seedGenres != null && seedGenres.isNotEmpty) {
        queryParams['seed_genres'] = seedGenres.join(',');
      }
      
      final response = await _get(SpotifyConstants.recommendationsEndpoint, queryParams: queryParams);

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tracks = (json['tracks'] as List)
          .map((t) => SpotifyTrack.fromJson(t as Map<String, dynamic>))
          .toList();

      return tracks;
    } catch (e) {
      debugPrint('❌ Get recommendations error: $e');
      rethrow;
    }
  }

  // -------------------- Browse -------------------- //

  /// Get featured playlists
  Future<List<SpotifyPlaylist>> getFeaturedPlaylists({int limit = 20}) async {
    try {
      debugPrint('⭐ Getting featured playlists');
      
      final response = await _get(
        SpotifyConstants.featuredPlaylistsEndpoint,
        queryParams: {'limit': limit.toString()},
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final playlistsContainer = json['playlists'];
      final items = playlistsContainer is Map<String, dynamic>
          ? playlistsContainer['items'] as List?
          : null;
      final playlists = (items ?? const [])
          .map((p) => SpotifyPlaylist.fromJson(p as Map<String, dynamic>))
          .toList();

      return playlists;
    } catch (e) {
      debugPrint('❌ Get featured playlists error: $e');
      rethrow;
    }
  }

  /// Get new releases
  Future<List<SpotifyAlbum>> getNewReleases({int limit = 20}) async {
    try {
      debugPrint('🆕 Getting new releases');
      
      final response = await _get(
        SpotifyConstants.newReleasesEndpoint,
        queryParams: {'limit': limit.toString()},
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final albumsContainer = json['albums'];
      final items = albumsContainer is Map<String, dynamic>
          ? albumsContainer['items'] as List?
          : null;
      final albums = (items ?? const [])
          .map((a) => SpotifyAlbum.fromJson(a as Map<String, dynamic>))
          .toList();

      return albums;
    } catch (e) {
      debugPrint('❌ Get new releases error: $e');
      rethrow;
    }
  }

  /// Get playlists for a specific category (e.g., 'toplists')
  Future<List<SpotifyPlaylist>> getCategoryPlaylists(String categoryId, {int limit = 20}) async {
    try {
      debugPrint('📚 Getting category playlists: $categoryId');

      final endpoint = SpotifyConstants.replaceId(
        SpotifyConstants.categoryPlaylistsEndpoint,
        categoryId,
      );

      final response = await _get(endpoint, queryParams: {
        'limit': limit.toString(),
      });

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final playlistsContainer = json['playlists'];
      final items = playlistsContainer is Map<String, dynamic>
          ? playlistsContainer['items'] as List?
          : null;
      final playlists = (items ?? const [])
          .map((p) => SpotifyPlaylist.fromJson(p as Map<String, dynamic>))
          .toList();

      return playlists;
    } catch (e) {
      debugPrint('❌ Get category playlists error: $e');
      rethrow;
    }
  }

  // -------------------- Audio Features -------------------- //

  /// Get audio features for a track
  Future<SpotifyAudioFeatures> getAudioFeatures(String trackId) async {
    try {
      debugPrint('🎼 Getting audio features: $trackId');
      
      final endpoint = SpotifyConstants.replaceId(SpotifyConstants.audioFeaturesEndpoint, trackId);
      final response = await _get(endpoint);

      return _handleResponse(response, SpotifyAudioFeatures.fromJson);
    } catch (e) {
      debugPrint('❌ Get audio features error: $e');
      rethrow;
    }
  }

  // -------------------- Cleanup -------------------- //

  void dispose() {
    _client.close();
  }
}

/// Spotify API Exception
class SpotifyApiException implements Exception {
  final String message;
  final int statusCode;

  SpotifyApiException(this.message, this.statusCode);

  @override
  String toString() => 'SpotifyApiException($statusCode): $message';
}

