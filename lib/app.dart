import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/features/authentication/screens/onboarding/onboarding.dart';
import 'package:music_player/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flashback',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: FAppTheme.lightTheme,
      darkTheme: FAppTheme.darkTheme,
      home: const OnBoardingScreen(),
    );
  }
}
