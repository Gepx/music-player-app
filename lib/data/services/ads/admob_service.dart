import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'interstitial_ad_manager.dart';

class AdMobService {
  AdMobService._();
  static final AdMobService instance = AdMobService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) {
      // google_mobile_ads is not supported on web.
      _initialized = true;
      return;
    }
    if (!Platform.isAndroid && !Platform.isIOS) {
      // Skip AdMob initialization on desktop for now.
      _initialized = true;
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _initialized = true;

      // Preload the first interstitial so it's ready when needed.
      InterstitialAdManager.instance.load();
    } catch (e) {
      debugPrint('⚠️ AdMob initialize failed: $e');
    }
  }
}

