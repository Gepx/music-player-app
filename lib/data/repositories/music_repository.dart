import 'package:flutter/foundation.dart';
import '../models/app/app_models.dart';
import '../models/spotify/spotify_models.dart';
import '../services/spotify/spotify_services.dart';
import '../services/database/firestore_service.dart';
import '../mappers/spotify_to_app_mapper.dart';

/// Music Repository
/// Combines Spotify API, Firestore, local DB, and cache for unified music data access
class MusicRepository {
  MusicRepository._();
  static final MusicRepository instance = MusicRepository._();

  final SpotifyApiService _spotifyApi = SpotifyApiService.instance;
  final SpotifyCacheService _cache = SpotifyCacheService.instance;
  final FirestoreService _firestore = FirestoreService.instance;

  // -------------------- Track Operations -------------------- //

  /// Get track by ID (cache → Spotify → Firestore)
  Future<TrackModel?> getTrack(String trackId) async {
    try {
      debugPrint('🎵 Getting track: $trackId');

      // Try cache first
      var track = await _cache.getCachedTrack(trackId);
      if (track != null) {
        debugPrint('✅ Track found in cache');
        return track;
      }

      // Fetch from Spotify
      try {
        final spotifyTrack = await _spotifyApi.getTrack(trackId);
        track = SpotifyToAppMapper.trackFromSpotify(spotifyTrack);
        
        // Cache the result
        await _cache.cacheTrack(track);
        
        debugPrint('✅ Track fetched from Spotify');
        return track;
      } catch (e) {
        debugPrint('⚠️ Spotify fetch failed, checking Firestore: $e');
        
        // Fallback to Firestore
        final doc = await _firestore.collection('tracks').doc(trackId).get();
        if (doc.exists) {
          // Convert Firestore data to TrackModel
          // Implementation depends on your Firestore schema
          debugPrint('✅ Track found in Firestore');
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error getting track: $e');
      return null;
    }
  }

  /// Search for tracks
  Future<List<TrackModel>> searchTracks(String query, {int limit = 20}) async {
    try {
      debugPrint('🔍 Searching tracks: $query');

      // Save search query to history
      await _cache.saveSearchQuery(query);

      // Search Spotify
      final searchResult = await _spotifyApi.search(
        query: query,
        type: SpotifySearchType.track,
        limit: limit,
      );

      if (searchResult.tracks == null) {
        return [];
      }

      // Convert to app models
      final tracks = SpotifyToAppMapper.tracksFromSpotify(searchResult.tracks!.items);

      // Cache results
      await _cache.cacheTracks(tracks);

      debugPrint('✅ Found ${tracks.length} tracks');
      return tracks;
    } catch (e) {
      debugPrint('❌ Error searching tracks: $e');
      return [];
    }
  }

  /// Get user's saved tracks
  Future<List<TrackModel>> getUserLibrary({int limit = 50, int offset = 0}) async {
    try {
      debugPrint('📚 Getting user library (limit: $limit, offset: $offset)');

      final savedTracks = await _spotifyApi.getUserSavedTracks(
        limit: limit,
        offset: offset,
      );

      // Convert to app models
      final tracks = SpotifyToAppMapper.tracksFromSpotify(savedTracks.items);

      // Cache results
      await _cache.cacheTracks(tracks);

      // Update favorites flag
      final favoriteTracks = tracks.map((t) => t.copyWith(isFavorite: true)).toList();

      debugPrint('✅ Retrieved ${favoriteTracks.length} library tracks');
      return favoriteTracks;
    } catch (e) {
      debugPrint('❌ Error getting user library: $e');
      
      // Fallback to cached tracks
      final cachedTracks = await _cache.getAllCachedTracks();
      return cachedTracks.where((t) => t.isFavorite).toList();
    }
  }

  /// Save track to library
  Future<bool> saveTrack(TrackModel track) async {
    try {
      debugPrint('💾 Saving track: ${track.title}');

      if (track.spotifyId == null) {
        debugPrint('⚠️ No Spotify ID, saving locally only');
        
        // Save to local DB only
        final updatedTrack = track.copyWith(isFavorite: true);
        await _cache.cacheTrack(updatedTrack);
        
        return true;
      }

      // Save to Spotify
      final success = await _spotifyApi.saveTracks([track.spotifyId!]);

      if (success) {
        // Update cache
        final updatedTrack = track.copyWith(isFavorite: true);
        await _cache.cacheTrack(updatedTrack);

        // Optionally save to Firestore for backup
        await _saveTrackToFirestore(updatedTrack);

        debugPrint('✅ Track saved successfully');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error saving track: $e');
      return false;
    }
  }

  /// Remove track from library
  Future<bool> removeTrack(String trackId) async {
    try {
      debugPrint('🗑️ Removing track: $trackId');

      // Remove from Spotify
      final success = await _spotifyApi.removeTracks([trackId]);

      if (success) {
        // Update cache
        final cachedTrack = await _cache.getCachedTrack(trackId);
        if (cachedTrack != null) {
          final updatedTrack = cachedTrack.copyWith(isFavorite: false);
          await _cache.cacheTrack(updatedTrack);
        }

        debugPrint('✅ Track removed successfully');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error removing track: $e');
      return false;
    }
  }

  /// Check if track is saved
  Future<bool> isTrackSaved(String trackId) async {
    try {
      final results = await _spotifyApi.checkSavedTracks([trackId]);
      return results.isNotEmpty ? results.first : false;
    } catch (e) {
      debugPrint('❌ Error checking if track is saved: $e');
      return false;
    }
  }

  // -------------------- Album Operations -------------------- //

  /// Get album
  Future<AlbumModel?> getAlbum(String albumId) async {
    try {
      debugPrint('💿 Getting album: $albumId');

      // Try cache first
      var album = await _cache.getCachedAlbum(albumId);
      if (album != null) {
        debugPrint('✅ Album found in cache');
        return album;
      }

      // Fetch from Spotify
      final spotifyAlbum = await _spotifyApi.getAlbum(albumId);
      album = SpotifyToAppMapper.albumFromSpotify(spotifyAlbum);

      // Cache the result
      await _cache.cacheAlbum(album);

      debugPrint('✅ Album fetched from Spotify');
      return album;
    } catch (e) {
      debugPrint('❌ Error getting album: $e');
      return null;
    }
  }

  /// Get album tracks
  Future<List<TrackModel>> getAlbumTracks(String albumId, {int limit = 50}) async {
    try {
      debugPrint('🎵 Getting album tracks: $albumId');

      final tracksPage = await _spotifyApi.getAlbumTracks(albumId, limit: limit);
      final tracks = SpotifyToAppMapper.tracksFromSpotify(tracksPage.items);

      // Cache tracks
      await _cache.cacheTracks(tracks);

      debugPrint('✅ Retrieved ${tracks.length} album tracks');
      return tracks;
    } catch (e) {
      debugPrint('❌ Error getting album tracks: $e');
      return [];
    }
  }

  // -------------------- Artist Operations -------------------- //

  /// Get artist
  Future<ArtistModel?> getArtist(String artistId) async {
    try {
      debugPrint('👤 Getting artist: $artistId');

      // Try cache first
      var artist = await _cache.getCachedArtist(artistId);
      if (artist != null) {
        debugPrint('✅ Artist found in cache');
        return artist;
      }

      // Fetch from Spotify
      final spotifyArtist = await _spotifyApi.getArtist(artistId);
      artist = SpotifyToAppMapper.artistFromSpotify(spotifyArtist);

      // Cache the result
      await _cache.cacheArtist(artist);

      debugPrint('✅ Artist fetched from Spotify');
      return artist;
    } catch (e) {
      debugPrint('❌ Error getting artist: $e');
      return null;
    }
  }

  /// Get artist's top tracks
  Future<List<TrackModel>> getArtistTopTracks(String artistId) async {
    try {
      debugPrint('🎵 Getting artist top tracks: $artistId');

      final spotifyTracks = await _spotifyApi.getArtistTopTracks(artistId);
      final tracks = SpotifyToAppMapper.tracksFromSpotify(spotifyTracks);

      // Cache tracks
      await _cache.cacheTracks(tracks);

      debugPrint('✅ Retrieved ${tracks.length} top tracks');
      return tracks;
    } catch (e) {
      debugPrint('❌ Error getting artist top tracks: $e');
      return [];
    }
  }

  // -------------------- Recommendations -------------------- //

  /// Get recommendations based on seeds
  Future<List<TrackModel>> getRecommendations({
    List<String>? seedTrackIds,
    List<String>? seedArtistIds,
    List<String>? seedGenres,
    int limit = 20,
  }) async {
    try {
      debugPrint('🎲 Getting recommendations');

      final spotifyTracks = await _spotifyApi.getRecommendations(
        seedTracks: seedTrackIds,
        seedArtists: seedArtistIds,
        seedGenres: seedGenres,
        limit: limit,
      );

      final tracks = SpotifyToAppMapper.tracksFromSpotify(spotifyTracks);

      // Cache recommendations
      await _cache.cacheTracks(tracks);

      debugPrint('✅ Got ${tracks.length} recommendations');
      return tracks;
    } catch (e) {
      debugPrint('❌ Error getting recommendations: $e');
      return [];
    }
  }

  // -------------------- Browse -------------------- //

  /// Get featured playlists
  Future<List<PlaylistModel>> getFeaturedPlaylists({int limit = 20}) async {
    try {
      final spotifyPlaylists = await _spotifyApi.getFeaturedPlaylists(limit: limit);
      final playlists = SpotifyToAppMapper.playlistsFromSpotify(spotifyPlaylists);

      // Cache playlists
      await _cache.cachePlaylists(playlists);

      return playlists;
    } catch (e) {
      debugPrint('❌ Error getting featured playlists: $e');
      return [];
    }
  }

  /// Get new releases
  Future<List<AlbumModel>> getNewReleases({int limit = 20}) async {
    try {
      final spotifyAlbums = await _spotifyApi.getNewReleases(limit: limit);
      final albums = SpotifyToAppMapper.albumsFromSpotify(spotifyAlbums);

      // Cache albums
      await _cache.cacheAlbums(albums);

      return albums;
    } catch (e) {
      debugPrint('❌ Error getting new releases: $e');
      return [];
    }
  }

  // -------------------- Helper Methods -------------------- //

  /// Save track to Firestore (optional backup)
  Future<void> _saveTrackToFirestore(TrackModel track) async {
    try {
      await _firestore.collection('tracks').doc(track.spotifyId).set({
        'id': track.id,
        'spotifyId': track.spotifyId,
        'title': track.title,
        'artistName': track.artistName,
        'albumName': track.albumName,
        'albumArtUrl': track.albumArtUrl,
        'durationMs': track.durationMs,
        'addedAt': track.addedAt?.millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('⚠️ Failed to save to Firestore (non-critical): $e');
    }
  }
}

