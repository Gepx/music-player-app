import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment Configuration
/// Manages environment variables from .env file
class EnvConfig {
  EnvConfig._();

  /// Load environment variables
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  /// Spotify Client ID
  static String? get spotifyClientId => dotenv.env['SPOTIFY_CLIENT_ID'];

  /// Spotify Client Secret
  static String? get spotifyClientSecret => dotenv.env['SPOTIFY_CLIENT_SECRET'];

  /// Firebase API Key
  static String? get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'];

  /// Firebase Project ID
  static String? get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'];

  /// Check if all required environment variables are set
  static bool validateConfig() {
    final hasSpotifyCredentials = 
        spotifyClientId != null && spotifyClientId!.isNotEmpty &&
        spotifyClientSecret != null && spotifyClientSecret!.isNotEmpty;
    
    if (!hasSpotifyCredentials) {
      print('⚠️ Warning: SPOTIFY_CLIENT_ID or SPOTIFY_CLIENT_SECRET is not configured in .env');
      print('Get your credentials from: https://developer.spotify.com/dashboard');
      return false;
    }
    
    return true;
  }
}

