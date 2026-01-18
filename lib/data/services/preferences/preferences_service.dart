import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// User Preferences Service
/// Handles app settings and user preferences using SharedPreferences
class PreferencesService {
  PreferencesService._();
  static final PreferencesService instance = PreferencesService._();

  SharedPreferences? _prefs;

  // -------------------- Preference Keys -------------------- //

  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _volumeKey = 'volume';
  static const String _playbackSpeedKey = 'playback_speed';
  static const String _autoPlayKey = 'auto_play';
  static const String _shuffleKey = 'shuffle_mode';
  static const String _repeatKey = 'repeat_mode';
  static const String _audioQualityKey = 'audio_quality';
  static const String _downloadQualityKey = 'download_quality';
  static const String _streamOverCellularKey = 'stream_over_cellular';
  static const String _downloadOverCellularKey = 'download_over_cellular';
  static const String _lastPlayedSongKey = 'last_played_song';
  static const String _lastPlaylistKey = 'last_playlist';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _userLoggedInKey = 'user_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _onBoardingCompletedKey = 'onboarding_completed';
  static const String _isPremiumKey = 'is_premium';

  // -------------------- Initialization -------------------- //

  /// Initialize SharedPreferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('✅ Preferences initialized');
    } catch (e) {
      debugPrint('❌ Error initializing preferences: $e');
      rethrow;
    }
  }

  /// Get SharedPreferences instance
  Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // OnBoarding
  Future<bool> hasCompleteOnBoarding() async {
    final p = await prefs;
    return p.getBool(_onBoardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted([bool value = true]) async {
    final p = await prefs;
    await p.setBool(_onBoardingCompletedKey, value);
  }

  // User Session
  Future<void> saveLoginState(bool isLoggedIn, String? userId) async {
    final p = await prefs;
    await p.setBool(_userLoggedInKey, isLoggedIn);
    if (userId != null) {
      await p.setString(_userIdKey, userId);
    }
  }

  Future<bool> checkLoginStatus() async {
    final p = await prefs;
    return p.getBool(_userLoggedInKey) ?? false;
  }

  // -------------------- Theme Settings -------------------- //

  /// Get theme mode (system, light, dark)
  Future<String> getThemeMode() async {
    final p = await prefs;
    return p.getString(_themeKey) ?? 'system';
  }

  /// Set theme mode
  Future<bool> setThemeMode(String mode) async {
    final p = await prefs;
    final result = await p.setString(_themeKey, mode);
    debugPrint('🎨 Theme mode set to: $mode');
    return result;
  }

  /// Get ThemeMode enum from stored string
  Future<ThemeMode> getThemeModeEnum() async {
    final mode = await getThemeMode();
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // -------------------- Language Settings -------------------- //

  /// Get language code
  Future<String> getLanguage() async {
    final p = await prefs;
    return p.getString(_languageKey) ?? 'en';
  }

  /// Set language code
  Future<bool> setLanguage(String languageCode) async {
    final p = await prefs;
    final result = await p.setString(_languageKey, languageCode);
    debugPrint('🌍 Language set to: $languageCode');
    return result;
  }

  // -------------------- Audio Settings -------------------- //

  /// Get volume (0.0 to 1.0)
  Future<double> getVolume() async {
    final p = await prefs;
    return p.getDouble(_volumeKey) ?? 0.7;
  }

  /// Set volume
  Future<bool> setVolume(double volume) async {
    final p = await prefs;
    return await p.setDouble(_volumeKey, volume.clamp(0.0, 1.0));
  }

  /// Get playback speed (0.5 to 2.0)
  Future<double> getPlaybackSpeed() async {
    final p = await prefs;
    return p.getDouble(_playbackSpeedKey) ?? 1.0;
  }

  /// Set playback speed
  Future<bool> setPlaybackSpeed(double speed) async {
    final p = await prefs;
    return await p.setDouble(_playbackSpeedKey, speed.clamp(0.5, 2.0));
  }

  /// Get audio quality (low, medium, high)
  Future<String> getAudioQuality() async {
    final p = await prefs;
    return p.getString(_audioQualityKey) ?? 'high';
  }

  /// Set audio quality
  Future<bool> setAudioQuality(String quality) async {
    final p = await prefs;
    final result = await p.setString(_audioQualityKey, quality);
    debugPrint('🎵 Audio quality set to: $quality');
    return result;
  }

  /// Get download quality (low, medium, high)
  Future<String> getDownloadQuality() async {
    final p = await prefs;
    return p.getString(_downloadQualityKey) ?? 'high';
  }

  /// Set download quality
  Future<bool> setDownloadQuality(String quality) async {
    final p = await prefs;
    return await p.setString(_downloadQualityKey, quality);
  }

  // -------------------- Playback Settings -------------------- //

  /// Get auto-play setting
  Future<bool> getAutoPlay() async {
    final p = await prefs;
    return p.getBool(_autoPlayKey) ?? true;
  }

  /// Set auto-play
  Future<bool> setAutoPlay(bool enabled) async {
    final p = await prefs;
    return await p.setBool(_autoPlayKey, enabled);
  }

  /// Get shuffle mode
  Future<bool> getShuffleMode() async {
    final p = await prefs;
    return p.getBool(_shuffleKey) ?? false;
  }

  /// Set shuffle mode
  Future<bool> setShuffleMode(bool enabled) async {
    final p = await prefs;
    return await p.setBool(_shuffleKey, enabled);
  }

  /// Get repeat mode (off, one, all)
  Future<String> getRepeatMode() async {
    final p = await prefs;
    return p.getString(_repeatKey) ?? 'off';
  }

  /// Set repeat mode
  Future<bool> setRepeatMode(String mode) async {
    final p = await prefs;
    return await p.setString(_repeatKey, mode);
  }

  // -------------------- Network Settings -------------------- //

  /// Get stream over cellular setting
  Future<bool> getStreamOverCellular() async {
    final p = await prefs;
    return p.getBool(_streamOverCellularKey) ?? false;
  }

  /// Set stream over cellular
  Future<bool> setStreamOverCellular(bool enabled) async {
    final p = await prefs;
    final result = await p.setBool(_streamOverCellularKey, enabled);
    debugPrint('📱 Stream over cellular: $enabled');
    return result;
  }

  /// Get download over cellular setting
  Future<bool> getDownloadOverCellular() async {
    final p = await prefs;
    return p.getBool(_downloadOverCellularKey) ?? false;
  }

  /// Set download over cellular
  Future<bool> setDownloadOverCellular(bool enabled) async {
    final p = await prefs;
    return await p.setBool(_downloadOverCellularKey, enabled);
  }

  // -------------------- Last Played Settings -------------------- //

  /// Get last played song ID
  Future<String?> getLastPlayedSong() async {
    final p = await prefs;
    return p.getString(_lastPlayedSongKey);
  }

  /// Set last played song ID
  Future<bool> setLastPlayedSong(String songId) async {
    final p = await prefs;
    return await p.setString(_lastPlayedSongKey, songId);
  }

  /// Get last playlist ID
  Future<String?> getLastPlaylist() async {
    final p = await prefs;
    return p.getString(_lastPlaylistKey);
  }

  /// Set last playlist ID
  Future<bool> setLastPlaylist(String playlistId) async {
    final p = await prefs;
    return await p.setString(_lastPlaylistKey, playlistId);
  }

  // -------------------- Notification Settings -------------------- //

  /// Get notifications enabled setting
  Future<bool> getNotificationsEnabled() async {
    final p = await prefs;
    return p.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Set notifications enabled
  Future<bool> setNotificationsEnabled(bool enabled) async {
    final p = await prefs;
    return await p.setBool(_notificationsEnabledKey, enabled);
  }

  // -------------------- Clear Settings -------------------- //

  /// Clear all preferences
  Future<bool> clearAll() async {
    try {
      final p = await prefs;
      await p.clear();
      debugPrint('✅ All preferences cleared');
      return true;
    } catch (e) {
      debugPrint('❌ Error clearing preferences: $e');
      return false;
    }
  }

  // Clear User Session
  Future<void> clearLoginState() async {
    final p = await prefs;
    await p.remove(_userLoggedInKey);
    await p.remove(_userIdKey);
  }

  // -------------------- Premium Settings -------------------- //

  Future<bool> getIsPremium() async {
    final p = await prefs;
    return p.getBool(_isPremiumKey) ?? false;
  }

  Future<void> setIsPremium(bool value) async {
    final p = await prefs;
    await p.setBool(_isPremiumKey, value);
  }

  /// Clear specific preference
  Future<bool> remove(String key) async {
    try {
      final p = await prefs;
      return await p.remove(key);
    } catch (e) {
      debugPrint('❌ Error removing preference: $e');
      return false;
    }
  }
}
