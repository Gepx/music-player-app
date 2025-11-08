import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
    } catch (e) {
      debugPrint('⚠️ Failed to log app_open: $e');
    }
  }

  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (_) {}
  }

  Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (_) {}
  }

  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (_) {}
  }

  Future<void> setUser({required String userId, String? authProvider}) async {
    try {
      await _analytics.setUserId(id: userId);
      if (authProvider != null) {
        await _analytics.setUserProperty(
          name: 'auth_provider',
          value: authProvider,
        );
      }
    } catch (_) {}
  }

  Future<void> clearUser() async {
    try {
      await _analytics.setUserId(id: null);
    } catch (_) {}
  }

  // --------- Content & Playback Events --------- //
  Future<void> logViewPlaylist({
    required String playlistId,
    required String playlistName,
    int? trackCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'view_item',
        parameters: {
          'item_id': playlistId,
          'item_name': playlistName,
          'item_category': 'playlist',
          if (trackCount != null) 'value': trackCount,
        },
      );
    } catch (_) {}
  }

  Future<void> logPlayTrack({
    required String trackId,
    required String trackName,
    required String artistName,
    int? durationMs,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'play_track',
        parameters: {
          'track_id': trackId,
          'track_name': trackName,
          'artist_name': artistName,
          if (durationMs != null) 'duration_ms': durationMs,
        },
      );
    } catch (_) {}
  }

  Future<void> logAddToPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'add_to_playlist',
        parameters: {'playlist_id': playlistId, 'track_id': trackId},
      );
    } catch (_) {}
  }

  // --------- Search & Discovery --------- //

  Future<void> logSearch({required String query, int? resultCount}) async {
    try {
      await _analytics.logSearch(searchTerm: query);
      if (resultCount != null) {
        await _analytics.logEvent(
          name: 'search_results',
          parameters: {'query': query, 'result_count': resultCount},
        );
      }
    } catch (_) {}
  }

  // --------- Generic Custom Event --------- //

  Future<void> logCustom(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    try {
      // Cast to the expected Map<String, Object>? type if not null
      await _analytics.logEvent(
        name: name,
        parameters:
            parameters == null ? null : Map<String, Object>.from(parameters),
      );
    } catch (_) {}
  }
}
