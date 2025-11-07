import 'package:flutter/foundation.dart';
import 'package:music_player/data/models/spotify/spotify_track.dart';
import 'package:music_player/data/services/music/recent_plays_service.dart';
import 'package:music_player/data/services/spotify/spotify_premium_auth_service.dart';

/// Spotify Web Playback SDK Service
/// Manages full track playback using Spotify Web Playback SDK
class WebPlaybackSDKService extends ChangeNotifier {
  WebPlaybackSDKService._();
  static final WebPlaybackSDKService instance = WebPlaybackSDKService._();

  // Playback state
  SpotifyTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isReady = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  final List<SpotifyTrack> _queue = [];
  int _currentIndex = 0;
  String? _deviceId;
  
  // Callback to control the actual player (set by WebPlaybackPlayerWeb)
  VoidCallback? _onTogglePlayPause;
  VoidCallback? _onPlayNext;
  VoidCallback? _onPlayPrevious;
  void Function(String uri)? _onPlayUri;

  // Getters
  SpotifyTrack? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get isReady => _isReady;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  List<SpotifyTrack> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;
  String? get deviceId => _deviceId;

  /// Initialize the Web Playback SDK
  Future<void> initialize() async {
    try {
      debugPrint('🎵 Initializing Web Playback SDK...');
      
      // The actual SDK initialization will be done in the WebView
      // This method prepares the service
      _isReady = true;
      // Don't notify listeners during initialization to avoid setState during build
      // Listeners will be notified when actual playback state changes
      
      debugPrint('✅ Web Playback SDK service ready');
    } catch (e) {
      debugPrint('❌ Failed to initialize Web Playback SDK: $e');
      rethrow;
    }
  }

  /// Set device ID from Web Playback SDK
  void setDeviceId(String deviceId) {
    _deviceId = deviceId;
    debugPrint('🎵 Device ID set: $deviceId');
    notifyListeners();
  }

  /// Play a track
  Future<void> playTrack(SpotifyTrack track, {List<SpotifyTrack>? playlist}) async {
    try {
      debugPrint('🎵 Playing track: ${track.name}');
      
      _currentTrack = track;
      _totalDuration = Duration(milliseconds: track.durationMs);

      // Set up queue if playlist provided
      if (playlist != null && playlist.isNotEmpty) {
        _queue.clear();
        _queue.addAll(playlist);
        _currentIndex = playlist.indexWhere((t) => t.id == track.id);
        if (_currentIndex == -1) _currentIndex = 0;
      } else {
        // Single track playback
        _queue.clear();
        _queue.add(track);
        _currentIndex = 0;
      }

      _isPlaying = true;
      notifyListeners();

      // Log to recent plays
      RecentPlaysService.instance.addRecent(track);

      debugPrint('✅ Track loaded: ${track.name}');
    } catch (e) {
      debugPrint('❌ Error playing track: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Set player control callbacks (called by WebPlaybackPlayerWeb)
  void setPlayerControls({
    VoidCallback? onTogglePlayPause,
    VoidCallback? onPlayNext,
    VoidCallback? onPlayPrevious,
    void Function(String uri)? onPlayUri,
  }) {
    _onTogglePlayPause = onTogglePlayPause;
    _onPlayNext = onPlayNext;
    _onPlayPrevious = onPlayPrevious;
    _onPlayUri = onPlayUri;
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (_onTogglePlayPause != null) {
      _onTogglePlayPause!();
    } else {
      _isPlaying = !_isPlaying;
      debugPrint('🎵 ${_isPlaying ? "Playing" : "Paused"}');
      notifyListeners();
    }
  }

  /// Play next track
  void playNext() {
    if (!hasNext) {
      debugPrint('⏭️ No next track');
      return;
    }

    _currentIndex++;
    if (_currentIndex < _queue.length) {
      final next = _queue[_currentIndex];
      _currentTrack = next;
      _totalDuration = Duration(milliseconds: next.durationMs);
      _isPlaying = true;
      notifyListeners();

      RecentPlaysService.instance.addRecent(next);

      // Prefer direct URI play via SDK if available
      if (_onPlayUri != null) {
        _onPlayUri!.call('spotify:track:${next.id}');
      } else if (_onPlayNext != null) {
        _onPlayNext!();
      }
    }
  }

  /// Play previous track
  void playPrevious() {
    if (!hasPrevious) {
      debugPrint('⏮️ No previous track');
      return;
    }

    _currentIndex--;
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      final prev = _queue[_currentIndex];
      _currentTrack = prev;
      _totalDuration = Duration(milliseconds: prev.durationMs);
      _isPlaying = true;
      notifyListeners();

      RecentPlaysService.instance.addRecent(prev);

      if (_onPlayUri != null) {
        _onPlayUri!.call('spotify:track:${prev.id}');
      } else if (_onPlayPrevious != null) {
        _onPlayPrevious!();
      }
    }
  }

  /// Seek to position
  void seekTo(Duration position) {
    _currentPosition = position;
    debugPrint('⏩ Seeking to: ${position.inSeconds}s');
    notifyListeners();
  }

  /// Update position (called from WebView)
  void updatePosition(Duration position) {
    _currentPosition = position;
    notifyListeners();
  }

  /// Update playing state (called from WebView)
  void updatePlayingState(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }

  /// Add track to queue
  void addToQueue(SpotifyTrack track) {
    _queue.add(track);
    debugPrint('➕ Added to queue: ${track.name}');
    notifyListeners();
  }

  /// Play track next (insert after current)
  void addPlayNext(SpotifyTrack track) {
    final insertIndex = _currentIndex + 1;
    _queue.insert(insertIndex, track);
    debugPrint('⏭️ Play next: ${track.name}');
    notifyListeners();
  }

  /// Remove track from queue
  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length && index != _currentIndex) {
      final track = _queue.removeAt(index);
      debugPrint('➖ Removed from queue: ${track.name}');
      
      // Adjust current index if necessary
      if (index < _currentIndex) {
        _currentIndex--;
      }
      
      notifyListeners();
    }
  }

  /// Clear queue except current track
  void clearQueue() {
    if (_currentTrack != null) {
      _queue.clear();
      _queue.add(_currentTrack!);
      _currentIndex = 0;
      debugPrint('🗑️ Queue cleared');
      notifyListeners();
    }
  }

  /// Get Spotify Premium access token for Web Playback SDK
  Future<String?> getAccessToken() async {
    try {
      final token = await SpotifyPremiumAuthService.instance.getAccessToken();
      if (token == null) {
        debugPrint('⚠️ Premium access token not available');
        debugPrint('Run: dart tools/spotify_token_setup.dart');
      }
      return token;
    } catch (e) {
      debugPrint('❌ Failed to get premium access token: $e');
      return null;
    }
  }

  /// Stop playback
  void stop() {
    _isPlaying = false;
    _currentPosition = Duration.zero;
    debugPrint('⏹️ Playback stopped');
    notifyListeners();
  }

  /// Dispose
  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

