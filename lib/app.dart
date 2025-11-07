import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/data/services/services.dart';
import 'package:music_player/features/authentication/screens/auth_wrapper.dart';
import 'package:music_player/features/authentication/screens/onboarding/onboarding.dart';
import 'package:music_player/features/testing/screens/spotify_api_test_screen.dart';
import 'package:music_player/utils/theme/theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  bool? _hasOnboarded;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = PreferencesService.instance;
    final onboarded = await prefs.hasCompleteOnBoarding();
    setState(() {
      _hasOnboarded = onboarded;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasOnboarded == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final home =
        !_hasOnboarded! ? const OnBoardingScreen() : const AuthWrapper();

    return GetMaterialApp(
      title: 'Flashback',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: FAppTheme.lightTheme,
      darkTheme: FAppTheme.darkTheme,
      home: home,
    );
  }
}
