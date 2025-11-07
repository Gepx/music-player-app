import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Spotify Premium Authentication Service
/// Manages access token for Premium playback features (Web Playback SDK)
/// Uses a dedicated Premium account for all users
class SpotifyPremiumAuthService {
  SpotifyPremiumAuthService._();
  static final SpotifyPremiumAuthService instance = SpotifyPremiumAuthService._();

  String? _accessToken;
  DateTime? _tokenExpiry;
  bool _isRefreshing = false;

  // Getters for credentials from .env
  String get _clientId => dotenv.env['SPOTIFY_PREMIUM_CLIENT_ID'] ?? '';
  String get _clientSecret => dotenv.env['SPOTIFY_PREMIUM_CLIENT_SECRET'] ?? '';
  String get _refreshToken => dotenv.env['SPOTIFY_PREMIUM_REFRESH_TOKEN'] ?? '';

  /// Check if premium credentials are configured
  bool get isConfigured => _clientId.isNotEmpty && 
                           _clientSecret.isNotEmpty && 
                           _refreshToken.isNotEmpty;

  /// Get valid access token (refreshes if needed)
  Future<String?> getAccessToken() async {
    try {
      if (!isConfigured) {
        debugPrint('❌ Premium Spotify credentials not configured in .env');
        debugPrint('Run: dart tools/spotify_token_setup.dart');
        return null;
      }

      // Check if token is still valid
      if (_accessToken != null && _tokenExpiry != null) {
        final now = DateTime.now();
        final timeUntilExpiry = _tokenExpiry!.difference(now);
        
        // Token valid for at least 5 more minutes
        if (timeUntilExpiry.inMinutes > 5) {
          return _accessToken;
        }
      }

      // Token expired or about to expire - refresh it
      return await _refreshAccessToken();
    } catch (e) {
      debugPrint('❌ Error getting premium access token: $e');
      return null;
    }
  }

  /// Refresh the access token using refresh token
  Future<String?> _refreshAccessToken() async {
    if (_isRefreshing) {
      // Wait for ongoing refresh
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _accessToken;
    }

    _isRefreshing = true;

    try {
      debugPrint('🔄 Refreshing Premium Spotify access token...');

      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
      
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': _refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        
        // Token expires in 3600 seconds (1 hour)
        final expiresIn = data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        debugPrint('✅ Premium access token refreshed (expires in ${expiresIn}s)');
        return _accessToken;
      } else {
        debugPrint('❌ Failed to refresh token: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error refreshing premium token: $e');
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Initialize and get first token
  Future<void> initialize() async {
    try {
      if (!isConfigured) {
        debugPrint('⚠️ Premium Spotify not configured. Web Playback SDK will not work.');
        debugPrint('To enable full playback, run: dart tools/spotify_token_setup.dart');
        return;
      }

      debugPrint('🎵 Initializing Premium Spotify authentication...');
      final token = await getAccessToken();
      
      if (token != null) {
        debugPrint('✅ Premium Spotify authenticated successfully');
        
        // Validate and show account info
        await validateToken();
      } else {
        debugPrint('❌ Failed to authenticate Premium Spotify');
      }
    } catch (e) {
      debugPrint('❌ Error initializing Premium Spotify auth: $e');
    }
  }

  /// Validate token is working
  Future<bool> validateToken() async {
    try {
      final token = await getAccessToken();
      if (token == null) return false;

      // Test token by calling Spotify API
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Premium account: ${data['display_name']} (${data['product']})');
        
        if (data['product'] != 'premium') {
          debugPrint('⚠️ WARNING: Account is not Premium! Web Playback SDK requires Premium.');
          return false;
        }
        
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error validating premium token: $e');
      return false;
    }
  }

  /// Clear cached token (force refresh on next request)
  void clearToken() {
    _accessToken = null;
    _tokenExpiry = null;
    debugPrint('🗑️ Premium token cache cleared');
  }
}

