import 'package:flutter/foundation.dart';
import 'spotify_token_manager.dart';

/// Spotify Authentication Service (Simplified)
/// No OAuth - uses static API token from environment variables
/// For user authentication, use Firebase Auth instead
class SpotifyAuthService {
  SpotifyAuthService._();
  static final SpotifyAuthService instance = SpotifyAuthService._();

  final SpotifyTokenManager _tokenManager = SpotifyTokenManager.instance;

  // -------------------- Token Access -------------------- //

  /// Get API token for Spotify requests
  String? getAccessToken() {
    return _tokenManager.getApiToken();
  }

  /// Check if Spotify API is configured
  Future<bool> get isConfigured async {
    return _tokenManager.hasToken();
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final accessToken = getAccessToken();
    
    if (accessToken == null) {
      throw Exception(
        'Spotify API token not configured. Please add SPOTIFY_API_TOKEN to your .env file.\n'
        'Get your token from: https://developer.spotify.com/console/'
      );
    }

    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  /// Validate API token configuration
  bool validateToken() {
    final isValid = _tokenManager.isTokenValid();
    
    if (!isValid) {
      debugPrint('❌ Invalid Spotify API token configuration');
      debugPrint('Please add a valid SPOTIFY_API_TOKEN to your .env file');
    } else {
      debugPrint('✅ Spotify API token is configured');
    }
    
    return isValid;
  }
}
