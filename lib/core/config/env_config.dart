import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment Configuration
/// Manages environment variables from .env file
class EnvConfig {
  EnvConfig._();

  /// Load environment variables
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  /// Spotify API Token
  static String? get spotifyApiToken => dotenv.env['SPOTIFY_API_TOKEN'];

  /// Firebase API Key
  static String? get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'];

  /// Firebase Project ID
  static String? get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'];

  /// Check if all required environment variables are set
  static bool validateConfig() {
    final hasSpotifyToken = spotifyApiToken != null && spotifyApiToken!.isNotEmpty;
    
    if (!hasSpotifyToken) {
      print('⚠️ Warning: SPOTIFY_API_TOKEN is not configured in .env');
      print('Get your token from: https://developer.spotify.com/console/');
      return false;
    }
    
    return true;
  }
}

