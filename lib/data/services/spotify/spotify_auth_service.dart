import 'package:flutter/foundation.dart';
import 'spotify_token_manager.dart';

/// Spotify Authentication Service (OAuth Client Credentials)
/// Uses OAuth 2.0 Client Credentials Flow with Client ID and Client Secret
/// Automatically manages token refresh
class SpotifyAuthService {
  SpotifyAuthService._();
  static final SpotifyAuthService instance = SpotifyAuthService._();

  final SpotifyTokenManager _tokenManager = SpotifyTokenManager.instance;

  // -------------------- Token Access -------------------- //

  /// Get API access token for Spotify requests (automatically refreshes if expired)
  Future<String?> getAccessToken() async {
    return await _tokenManager.getAccessToken();
  }

  /// Check if Spotify API credentials are configured
  Future<bool> get isConfigured async {
    return _tokenManager.hasCredentials();
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final accessToken = await getAccessToken();
    
    if (accessToken == null) {
      throw Exception(
        'Spotify API credentials not configured or token request failed.\n'
        'Please add SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET to your .env file.\n'
        'Get your credentials from: https://developer.spotify.com/dashboard'
      );
    }

    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  /// Validate API credentials configuration
  Future<bool> validateToken() async {
    final hasCredentials = _tokenManager.hasCredentials();
    
    if (!hasCredentials) {
      debugPrint('❌ Spotify credentials not configured');
      debugPrint('Please add SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET to your .env file');
      return false;
    }

    // Try to get a token
    final token = await getAccessToken();
    if (token != null) {
      debugPrint('✅ Spotify API configured and token obtained successfully');
      return true;
    } else {
      debugPrint('❌ Failed to obtain Spotify access token');
      return false;
    }
  }

  /// Force refresh the access token
  Future<void> refreshToken() async {
    _tokenManager.clearToken();
    await getAccessToken();
  }

  /// Get token info for debugging
  Map<String, dynamic> getTokenInfo() {
    return _tokenManager.getTokenInfo();
  }
}
