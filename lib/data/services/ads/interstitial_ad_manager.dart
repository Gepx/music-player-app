import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_player/data/services/premium/premium_service.dart';

class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  static const String _androidTestInterstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosTestInterstitialUnitId =
      'ca-app-pub-3940256099942544/4411468910';

  InterstitialAd? _ad;
  bool _isLoading = false;
  DateTime? _lastShownAt;

  bool get isReady => _ad != null;

  String? get _unitId {
    if (kIsWeb) return null;
    if (Platform.isIOS) return _iosTestInterstitialUnitId;
    if (Platform.isAndroid) return _androidTestInterstitialUnitId;
    return null; // Desktop platforms: skip interstitials for now.
  }

  Future<void> load() async {
    final unitId = _unitId;
    if (unitId == null) return;
    if (_isLoading || _ad != null) return;

    _isLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: unitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _ad = ad;
            _isLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('⚠️ Interstitial failed to load: $error');
            _ad = null;
            _isLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Interstitial load exception: $e');
      _ad = null;
      _isLoading = false;
    }
  }

  /// Show an interstitial if ready.
  ///
  /// Throttles shows to avoid spamming the user.
  Future<void> showIfReady({Duration minInterval = const Duration(seconds: 30)}) async {
    if (kIsWeb) return;
    if (PremiumService.instance.isPremium) return;

    final ad = _ad;
    if (ad == null) {
      // Try loading for next time.
      load();
      return;
    }

    final now = DateTime.now();
    if (_lastShownAt != null && now.difference(_lastShownAt!) < minInterval) {
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _lastShownAt = DateTime.now();
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('⚠️ Interstitial failed to show: $error');
        ad.dispose();
        _ad = null;
        load();
      },
    );

    try {
      await ad.show();
    } catch (e) {
      debugPrint('⚠️ Interstitial show exception: $e');
      ad.dispose();
      _ad = null;
      load();
    }
  }
}

