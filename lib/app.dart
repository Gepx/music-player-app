import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/data/services/services.dart';
import 'package:music_player/features/authentication/screens/auth_wrapper.dart';
import 'package:music_player/features/authentication/screens/onboarding/onboarding.dart';
import 'package:music_player/utils/theme/theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  bool? _hasOnboarded;
  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver _observer;

  @override
  void initState() {
    super.initState();
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
    _loadState();
    _logAppOpen();
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
      navigatorObservers: [_observer],
    );
  }

  /// Log basic app_open event once
  Future<void> _logAppOpen() async {
    await AnalyticsService.instance.logAppOpen();
  }
}
