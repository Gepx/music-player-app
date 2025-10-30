import 'package:flutter/foundation.dart';
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

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  // Load environment variables
  await EnvConfig.load();
  // Validate environment configuration
  EnvConfig.validateConfig();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // Initialize FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

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
