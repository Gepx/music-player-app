import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Spotify Token Manager (OAuth Client Credentials Flow)
/// Manages Spotify API access tokens using Client ID and Client Secret
/// Implements OAuth 2.0 Client Credentials Flow
class SpotifyTokenManager {
  SpotifyTokenManager._();
  static final SpotifyTokenManager instance = SpotifyTokenManager._();

  String? _cachedToken;
  DateTime? _tokenExpiryTime;

  // Spotify OAuth endpoint
  static const String _tokenEndpoint = 'https://accounts.spotify.com/api/token';

  // -------------------- Token Retrieval -------------------- //

  /// Get Spotify API access token (requests new token if needed)
  Future<String?> getAccessToken() async {
    // Return cached token if still valid
    if (_cachedToken != null && _tokenExpiryTime != null) {
      if (DateTime.now().isBefore(_tokenExpiryTime!)) {
        return _cachedToken;
      }
    }

    // Request new token
    return await _requestNewToken();
  }

  /// Request a new access token from Spotify
  Future<String?> _requestNewToken() async {
    try {
      final clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
      final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'];

      if (clientId == null || clientSecret == null || 
          clientId.isEmpty || clientSecret.isEmpty) {
        debugPrint('⚠️ SPOTIFY_CLIENT_ID or SPOTIFY_CLIENT_SECRET not found in .env');
        return null;
      }

      // Encode credentials in base64
      final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

      // Make POST request to token endpoint
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cachedToken = data['access_token'];
        final expiresIn = data['expires_in'] as int; // seconds
        
        // Set expiry time with 5 minute buffer
        _tokenExpiryTime = DateTime.now().add(
          Duration(seconds: expiresIn - 300),
        );

        debugPrint('✅ Spotify access token obtained (expires in ${expiresIn}s)');
        return _cachedToken;
      } else {
        debugPrint('❌ Failed to get Spotify token: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error requesting Spotify token: $e');
      return null;
    }
  }

  /// Check if credentials are configured
  bool hasCredentials() {
    final clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
    final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'];
    return clientId != null && clientSecret != null && 
           clientId.isNotEmpty && clientSecret.isNotEmpty;
  }

  /// Clear cached token (force refresh on next request)
  void clearToken() {
    _cachedToken = null;
    _tokenExpiryTime = null;
  }

  /// Get token info (for debugging)
  Map<String, dynamic> getTokenInfo() {
    return {
      'hasToken': _cachedToken != null,
      'expiresAt': _tokenExpiryTime?.toIso8601String(),
      'isExpired': _tokenExpiryTime != null 
          ? DateTime.now().isAfter(_tokenExpiryTime!)
          : true,
    };
  }
}
