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
  
  // Pending track to play once player is ready
  SpotifyTrack? _pendingTrack;
  List<SpotifyTrack>? _pendingPlaylist;
  
  // Callback to control the actual player (set by WebPlaybackPlayerWeb)
  VoidCallback? _onTogglePlayPause;
  VoidCallback? _onPause;
  VoidCallback? _onResume;
  VoidCallback? _onPlayNext;
  VoidCallback? _onPlayPrevious;
  void Function(String uri)? _onPlayUri;
  void Function(int positionMs)? _onSeek;

  // Used to prevent race conditions when switching tracks quickly.
  int _playRequestId = 0;
  int? _pendingPlayRequestId;

  // Retry control to avoid infinite loops on playback errors
  int _retryCount = 0;
  DateTime? _lastRetryAt;

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
    
    // If there's a pending track and callbacks are ready, try to play it
    if (_pendingTrack != null && _onPlayUri != null) {
      debugPrint('🔄 Device ready, playing pending track: ${_pendingTrack!.name}');
      final pending = _pendingTrack;
      final pendingPlaylist = _pendingPlaylist;
      _pendingTrack = null;
      _pendingPlaylist = null;
      // Use the existing playTrack logic but don't set as pending again
      _playPendingTrack(pending!, playlist: pendingPlaylist);
    } else if (_pendingTrack != null) {
      debugPrint('⏳ Device ready but callbacks not set yet, waiting...');
    }
  }
  
  /// Play a pending track (internal method, doesn't set pending state)
  void _playPendingTrack(SpotifyTrack track, {List<SpotifyTrack>? playlist}) {
    if (_onPlayUri != null && _deviceId != null) {
      debugPrint('▶️ Playing pending track via callback: ${track.name}');
      // Hard-cut any existing audio first (best effort)
      _onPause?.call();
      _onPlayUri!.call('spotify:track:${track.id}');
    } else {
      debugPrint('⚠️ Cannot play pending track - callbacks or device not ready');
    }
  }

  /// Queue the current track for a retry if playback fails
  void queueCurrentTrackForRetry() {
    final current = _currentTrack;
    if (current == null) return;

    // Throttle retries and cap attempts to prevent infinite loops.
    final now = DateTime.now();
    if (_lastRetryAt != null && now.difference(_lastRetryAt!) < const Duration(seconds: 2)) {
      debugPrint('⏳ Retry throttled');
      return;
    }
    _lastRetryAt = now;
    if (_retryCount >= 3) {
      debugPrint('🛑 Retry limit reached; stopping playback to avoid loop');
      stop();
      return;
    }
    _retryCount++;

    debugPrint('🔁 Scheduling retry for track: ${current.name}');
    final pending = current;
    final pendingPlaylist = List<SpotifyTrack>.from(_queue);
    _pendingTrack = pending;
    _pendingPlaylist = pendingPlaylist;

    if (_onPlayUri != null && _deviceId != null) {
      _pendingTrack = null;
      _pendingPlaylist = null;
      _playPendingTrack(pending, playlist: pendingPlaylist);
    }
  }

  /// Play a track
  Future<void> playTrack(SpotifyTrack track, {List<SpotifyTrack>? playlist}) async {
    try {
      debugPrint('🎵 Playing track: ${track.name}');

      final requestId = ++_playRequestId;
      // New manual play resets retry counters.
      _retryCount = 0;
      _lastRetryAt = null;
      
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

      _currentPosition = Duration.zero;
      _isPlaying = true;
      notifyListeners();

      // Log to recent plays
      RecentPlaysService.instance.addRecent(track);

      // Hard-cut any existing audio immediately to avoid hearing the tail of the previous track.
      // Then trigger playback if callbacks are set (for web playback SDK).
      if (_onPlayUri != null && _deviceId != null) {
        // Best effort pause (explicit pause preferred over toggle).
        if (_onPause != null) {
          _onPause!.call();
        } else if (_onTogglePlayPause != null && _isPlaying) {
          // Fallback: toggle only if we believe we are playing.
          _onTogglePlayPause!.call();
        }

        // Only play if this is still the latest request (prevents stale async calls).
        if (requestId == _playRequestId) {
          _onPlayUri!.call('spotify:track:${track.id}');
        }
      } else {
        // Player not ready yet, store as pending to play once ready
        debugPrint('⚠️ Playback callbacks not ready yet (deviceId: $_deviceId, onPlayUri: ${_onPlayUri != null})');
        debugPrint('📋 Queuing track to play once player is ready: ${track.name}');
        _pendingTrack = track;
        _pendingPlaylist = playlist;
        _pendingPlayRequestId = requestId;
      }

      debugPrint('✅ Track loaded: ${track.name}');
    } catch (e) {
      debugPrint('❌ Error playing track: $e');
      _isPlaying = false;
      notifyListeners();
      queueCurrentTrackForRetry();
    }
  }

  /// Set player control callbacks (called by WebPlaybackPlayerWeb)
  void setPlayerControls({
    VoidCallback? onTogglePlayPause,
    VoidCallback? onPause,
    VoidCallback? onResume,
    VoidCallback? onPlayNext,
    VoidCallback? onPlayPrevious,
    void Function(String uri)? onPlayUri,
    void Function(int positionMs)? onSeek,
  }) {
    _onTogglePlayPause = onTogglePlayPause;
    _onPause = onPause;
    _onResume = onResume;
    _onPlayNext = onPlayNext;
    _onPlayPrevious = onPlayPrevious;
    _onPlayUri = onPlayUri;
    _onSeek = onSeek;
    
    // If callbacks are now set and there's a pending track, try to play it
    if (_onPlayUri != null && _deviceId != null && _pendingTrack != null) {
      debugPrint('🔄 Callbacks ready, playing pending track: ${_pendingTrack!.name}');
      final pending = _pendingTrack;
      final pendingPlaylist = _pendingPlaylist;
      final pendingRequestId = _pendingPlayRequestId;
      _pendingTrack = null;
      _pendingPlaylist = null;
      _pendingPlayRequestId = null;

      // Only play if this pending request is still the latest request.
      if (pendingRequestId == null || pendingRequestId == _playRequestId) {
        _playPendingTrack(pending!, playlist: pendingPlaylist);
      } else {
        debugPrint('⏭️ Skipping stale pending track request');
      }
    }
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

  /// Explicit pause (preferred over toggle for UX)
  void pause() {
    if (_onPause != null) {
      _onPause!();
      _isPlaying = false;
      notifyListeners();
    } else {
      debugPrint('⚠️ Pause not available; falling back to toggle');
      togglePlayPause();
    }
  }

  /// Explicit resume
  void resume() {
    if (_onResume != null) {
      _onResume!();
      _isPlaying = true;
      notifyListeners();
    } else {
      debugPrint('⚠️ Resume not available; falling back to toggle');
      togglePlayPause();
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
    
    // Actually seek the player if callback is available
    if (_onSeek != null) {
      _onSeek!(position.inMilliseconds);
    }
    
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

  /// Update total duration (called from WebView)
  void updateTotalDuration(Duration duration) {
    _totalDuration = duration;
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

