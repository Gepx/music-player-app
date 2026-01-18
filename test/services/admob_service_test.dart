import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/services/ads/admob_service.dart';
import 'package:music_player/data/services/ads/interstitial_ad_manager.dart';

void main() {
  test('AdMobService initialize is safe on non-mobile platforms', () async {
    await AdMobService.instance.initialize();
  });

  test('InterstitialAdManager methods are safe to call', () async {
    await InterstitialAdManager.instance.load();
    await InterstitialAdManager.instance.showIfReady();
  });
}

