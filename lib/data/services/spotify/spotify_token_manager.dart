import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Spotify Token Manager (Simplified)
/// Manages Spotify API token from environment variables
/// No OAuth - uses static API token from .env
class SpotifyTokenManager {
  SpotifyTokenManager._();
  static final SpotifyTokenManager instance = SpotifyTokenManager._();

  // -------------------- Token Retrieval -------------------- //

  /// Get Spotify API token from environment variables
  String? getApiToken() {
    try {
      final token = dotenv.env['SPOTIFY_API_TOKEN'];
      
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ SPOTIFY_API_TOKEN not found in .env file');
        return null;
      }
      
      return token;
    } catch (e) {
      debugPrint('❌ Error getting Spotify API token: $e');
      return null;
    }
  }

  /// Check if API token is configured
  bool hasToken() {
    final token = getApiToken();
    return token != null && token.isNotEmpty;
  }

  /// Validate token format (basic check)
  bool isTokenValid() {
    final token = getApiToken();
    if (token == null || token.isEmpty) return false;
    
    // Basic validation - Spotify tokens are usually long strings
    return token.length > 20;
  }
}
