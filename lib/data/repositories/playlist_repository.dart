import 'package:flutter/foundation.dart';
import '../models/app/app_models.dart';
import '../services/spotify/spotify_services.dart';
import '../services/music/playlist_service.dart';
import '../mappers/spotify_to_app_mapper.dart';

/// Playlist Repository
/// Manages playlists from both Spotify and local storage
class PlaylistRepository {
  PlaylistRepository._();
  static final PlaylistRepository instance = PlaylistRepository._();

  final SpotifyApiService _spotifyApi = SpotifyApiService.instance;
  final SpotifyCacheService _cache = SpotifyCacheService.instance;
  final PlaylistService _localPlaylistService = PlaylistService.instance;

  // -------------------- Get Playlists -------------------- //

  /// Get all user playlists (Spotify + Local)
  Future<List<PlaylistModel>> getUserPlaylists({bool includeSpotify = true, bool includeLocal = true}) async {
    try {
      debugPrint('📚 Getting user playlists');

      final allPlaylists = <PlaylistModel>[];

      // Get Spotify playlists
      if (includeSpotify) {
        try {
          final spotifyPlaylists = await _spotifyApi.getUserPlaylists(limit: 50);
          final appPlaylists = SpotifyToAppMapper.playlistsFromSpotify(spotifyPlaylists.items);
          
          // Cache Spotify playlists
          await _cache.cachePlaylists(appPlaylists);
          
          allPlaylists.addAll(appPlaylists);
          debugPrint('✅ Got ${appPlaylists.length} Spotify playlists');
        } catch (e) {
          debugPrint('⚠️ Failed to get Spotify playlists, using cache: $e');
          // Fallback to cache
          final cachedPlaylists = await _cache.getAllCachedPlaylists();
          allPlaylists.addAll(cachedPlaylists.where((p) => p.isFromSpotify));
        }
      }

      // Get local playlists
      if (includeLocal) {
        try {
          // Get from local Firestore
          final localData = await _localPlaylistService.getUserPlaylists('current_user_id');
          
          // Convert Firestore data to PlaylistModel
          for (var data in localData) {
            final playlist = PlaylistModel(
              id: data['id'] as String,
              name: data['name'] as String,
              description: data['description'] as String?,
              ownerId: data['userId'] as String,
              ownerName: data['userId'] as String,
              trackIds: List<String>.from(data['songIds'] as List),
              createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
              updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int),
              isFromSpotify: false,
            );
            allPlaylists.add(playlist);
          }
          debugPrint('✅ Got ${localData.length} local playlists');
        } catch (e) {
          debugPrint('⚠️ Failed to get local playlists: $e');
        }
      }

      debugPrint('✅ Total playlists: ${allPlaylists.length}');
      return allPlaylists;
    } catch (e) {
      debugPrint('❌ Error getting user playlists: $e');
      return [];
    }
  }

  /// Get playlist by ID
  Future<PlaylistModel?> getPlaylist(String playlistId, {bool isFromSpotify = true}) async {
    try {
      debugPrint('📋 Getting playlist: $playlistId');

      // Check cache first
      var playlist = await _cache.getCachedPlaylist(playlistId);
      if (playlist != null) {
        debugPrint('✅ Playlist found in cache');
        return playlist;
      }

      if (isFromSpotify) {
        // Fetch from Spotify
        final spotifyPlaylist = await _spotifyApi.getPlaylist(playlistId);
        playlist = SpotifyToAppMapper.playlistFromSpotify(spotifyPlaylist);
        
        // Get tracks
        final tracks = await getPlaylistTracks(playlistId);
        playlist = playlist.copyWith(trackIds: tracks.map((t) => t.id).toList());
        
        // Cache playlist
        await _cache.cachePlaylist(playlist);
        
        debugPrint('✅ Playlist fetched from Spotify');
        return playlist;
      } else {
        // Fetch from local Firestore
        final data = await _localPlaylistService.getPlaylist(playlistId);
        if (data != null) {
          playlist = PlaylistModel(
            id: data['id'] as String,
            name: data['name'] as String,
            description: data['description'] as String?,
            ownerId: data['userId'] as String,
            ownerName: data['userId'] as String,
            trackIds: List<String>.from(data['songIds'] as List),
            createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int),
            isFromSpotify: false,
          );
          
          debugPrint('✅ Playlist fetched from local storage');
          return playlist;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error getting playlist: $e');
      return null;
    }
  }

  /// Get playlist tracks
  Future<List<TrackModel>> getPlaylistTracks(String playlistId, {bool isFromSpotify = true}) async {
    try {
      debugPrint('🎵 Getting playlist tracks: $playlistId');

      if (isFromSpotify) {
        final tracksPage = await _spotifyApi.getPlaylistTracks(playlistId, limit: 50);
        final tracks = SpotifyToAppMapper.tracksFromSpotify(tracksPage.items);
        
        // Cache tracks
        await _cache.cacheTracks(tracks);
        
        debugPrint('✅ Retrieved ${tracks.length} playlist tracks');
        return tracks;
      } else {
        // Get from local - would need to implement track fetching
        debugPrint('⚠️ Local playlist track fetching not fully implemented');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error getting playlist tracks: $e');
      return [];
    }
  }

  // -------------------- Create Playlist -------------------- //

  /// Create a new playlist
  Future<PlaylistModel?> createPlaylist({
    required String name,
    String? description,
    bool isPublic = false,
    bool createOnSpotify = false,
  }) async {
    try {
      debugPrint('📝 Creating playlist: $name');

      if (createOnSpotify) {
        // Create on Spotify
        final spotifyPlaylist = await _spotifyApi.createPlaylist(
          userId: 'me', // Current user
          name: name,
          description: description,
          public: isPublic,
        );
        
        final playlist = SpotifyToAppMapper.playlistFromSpotify(spotifyPlaylist);
        
        // Cache playlist
        await _cache.cachePlaylist(playlist);
        
        debugPrint('✅ Playlist created on Spotify');
        return playlist;
      } else {
        // Create locally
        final playlistId = await _localPlaylistService.createPlaylist(
          userId: 'current_user_id',
          name: name,
          description: description,
        );

        if (playlistId != null) {
          final playlist = PlaylistModel(
            id: playlistId,
            name: name,
            description: description,
            ownerId: 'current_user_id',
            ownerName: 'Me',
            isPublic: isPublic,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isFromSpotify: false,
          );

          // Cache playlist
          await _cache.cachePlaylist(playlist);

          debugPrint('✅ Playlist created locally');
          return playlist;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error creating playlist: $e');
      return null;
    }
  }

  // -------------------- Modify Playlist -------------------- //

  /// Add tracks to playlist
  Future<bool> addTracksToPlaylist(PlaylistModel playlist, List<TrackModel> tracks) async {
    try {
      debugPrint('➕ Adding ${tracks.length} tracks to playlist: ${playlist.name}');

      if (playlist.isFromSpotify && playlist.spotifyId != null) {
        // Add to Spotify playlist
        final trackUris = tracks
            .map((t) => SpotifyToAppMapper.getTrackUri(t))
            .where((uri) => uri != null)
            .cast<String>()
            .toList();

        if (trackUris.isEmpty) {
          debugPrint('⚠️ No valid Spotify URIs found');
          return false;
        }

        final success = await _spotifyApi.addTracksToPlaylist(playlist.spotifyId!, trackUris);
        
        if (success) {
          // Update cache
          final updatedTrackIds = [...playlist.trackIds, ...tracks.map((t) => t.id)];
          final updatedPlaylist = playlist.copyWith(
            trackIds: updatedTrackIds,
            updatedAt: DateTime.now(),
          );
          await _cache.cachePlaylist(updatedPlaylist);
          
          debugPrint('✅ Tracks added to Spotify playlist');
          return true;
        }
      } else {
        // Add to local playlist
        final success = await _localPlaylistService.addSongToPlaylist(
          playlistId: playlist.id,
          songId: tracks.first.id, // Single track for now
        );

        if (success) {
          // Update cache
          final updatedTrackIds = [...playlist.trackIds, ...tracks.map((t) => t.id)];
          final updatedPlaylist = playlist.copyWith(
            trackIds: updatedTrackIds,
            updatedAt: DateTime.now(),
          );
          await _cache.cachePlaylist(updatedPlaylist);

          debugPrint('✅ Tracks added to local playlist');
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error adding tracks to playlist: $e');
      return false;
    }
  }

  /// Remove track from playlist
  Future<bool> removeTrackFromPlaylist(PlaylistModel playlist, String trackId) async {
    try {
      debugPrint('🗑️ Removing track from playlist: ${playlist.name}');

      if (!playlist.isFromSpotify) {
        // Remove from local playlist
        final success = await _localPlaylistService.removeSongFromPlaylist(
          playlistId: playlist.id,
          songId: trackId,
        );

        if (success) {
          // Update cache
          final updatedTrackIds = playlist.trackIds.where((id) => id != trackId).toList();
          final updatedPlaylist = playlist.copyWith(
            trackIds: updatedTrackIds,
            updatedAt: DateTime.now(),
          );
          await _cache.cachePlaylist(updatedPlaylist);

          debugPrint('✅ Track removed from playlist');
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error removing track from playlist: $e');
      return false;
    }
  }

  // -------------------- Delete Playlist -------------------- //

  /// Delete playlist
  Future<bool> deletePlaylist(PlaylistModel playlist) async {
    try {
      debugPrint('🗑️ Deleting playlist: ${playlist.name}');

      if (!playlist.isFromSpotify) {
        // Delete local playlist
        final success = await _localPlaylistService.deletePlaylist(playlist.id);
        
        if (success) {
          debugPrint('✅ Playlist deleted');
          return true;
        }
      } else {
        debugPrint('⚠️ Cannot delete Spotify playlists via API');
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error deleting playlist: $e');
      return false;
    }
  }
}

