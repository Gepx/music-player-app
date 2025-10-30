import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:music_player/app.dart';
import 'core/config/firebase_options.dart';
import 'core/config/env_config.dart';
import 'data/models/app/app_models.dart';
import 'data/services/spotify/spotify_cache_service.dart';
import 'data/services/preferences/preferences_service.dart';
import 'data/services/spotify/spotify_auth_service.dart';

void main() async {
  await dotenv.load(fileName: '.env');

  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await EnvConfig.load();

  // Validate environment configuration
  EnvConfig.validateConfig();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(TrackModelAdapter());
  Hive.registerAdapter(AlbumModelAdapter());
  Hive.registerAdapter(ArtistModelAdapter());
  Hive.registerAdapter(PlaylistModelAdapter());

  // Initialize services
  await PreferencesService.instance.init();
  await SpotifyCacheService.instance.initialize();

  // Validate Spotify API configuration
  SpotifyAuthService.instance.validateToken();

  runApp(const App());
}
