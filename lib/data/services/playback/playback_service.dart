import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/data/models/spotify/spotify_track.dart';
import 'package:music_player/data/services/music/recent_plays_service.dart';

/// Playback Service
/// Manages the current playing track, queue, and playback state
class PlaybackService extends ChangeNotifier {
  PlaybackService._() {
    _initAudioPlayer();
  }
  static final PlaybackService instance = PlaybackService._();

  // Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Current playback state
  SpotifyTrack? _currentTrack;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Queue management
  final List<SpotifyTrack> _queue = [];
  int _currentIndex = 0;

  // Playback mode
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;

  // Getters
  SpotifyTrack? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  List<SpotifyTrack> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  /// Initialize audio player and listeners
  void _initAudioPlayer() {
    // Listen to playback state changes
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();

      if (state.processingState == ProcessingState.completed) {
        debugPrint('🏁 Track completed');
        if (_repeatMode == RepeatMode.one) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else {
          playNext();
        }
      }
    });

    // Listen to position updates
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    // Listen to duration updates
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });
  }

  /// Play a track
  Future<void> playTrack(SpotifyTrack track, {List<SpotifyTrack>? playlist}) async {
    try {
      debugPrint('🎵 Playing track: ${track.name}');
      
      _currentTrack = track;
      // Log to recently played (fire-and-forget)
      // Ignore await to not block UI
      RecentPlaysService.instance.addRecent(track);
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

      notifyListeners();

      // Check if track has a preview URL
      if (track.previewUrl != null && track.previewUrl!.isNotEmpty) {
        debugPrint('🔊 Loading audio from: ${track.previewUrl}');
        await _audioPlayer.setUrl(track.previewUrl!);
        await _audioPlayer.play();
        _isPlaying = true;
        notifyListeners();
      } else {
        debugPrint('⚠️ No preview URL available for this track: ${track.name}');
        _isPlaying = false;
        notifyListeners();
        
        // Auto-skip to next track with preview after a short delay
        if (hasNext) {
          debugPrint('⏭️ Auto-skipping to next track...');
          await Future.delayed(const Duration(milliseconds: 1500));
          await playNext();
        }
      }
    } catch (e) {
      debugPrint('❌ Error playing track: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Play/Pause toggle
  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        debugPrint('⏸️ Paused');
      } else {
        await _audioPlayer.play();
        debugPrint('▶️ Playing');
      }
    } catch (e) {
      debugPrint('❌ Error toggling play/pause: $e');
    }
  }

  /// Play next track in queue
  Future<void> playNext() async {
    if (!hasNext) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = 0;
      } else {
        debugPrint('⏭️ No next track');
        return;
      }
    } else {
      _currentIndex++;
    }

    if (_currentIndex < _queue.length) {
      await playTrack(_queue[_currentIndex], playlist: _queue);
    }
  }

  /// Play previous track in queue
  Future<void> playPrevious() async {
    if (_currentPosition.inSeconds > 3) {
      // If more than 3 seconds into the track, restart it
      await _audioPlayer.seek(Duration.zero);
      debugPrint('⏮️ Restarting track');
      return;
    }

    if (!hasPrevious) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = _queue.length - 1;
      } else {
        debugPrint('⏮️ No previous track');
        return;
      }
    } else {
      _currentIndex--;
    }

    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      await playTrack(_queue[_currentIndex], playlist: _queue);
    }
  }

  /// Add track to end of queue
  void addToQueue(SpotifyTrack track) {
    _queue.add(track);
    debugPrint('➕ Added to queue: ${track.name}');
    notifyListeners();
  }

  /// Play track next (insert after current track)
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

  /// Toggle shuffle
  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    debugPrint('🔀 Shuffle: ${_isShuffleEnabled ? "ON" : "OFF"}');
    notifyListeners();
  }

  /// Toggle repeat mode
  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    debugPrint('🔁 Repeat: ${_repeatMode.name}');
    notifyListeners();
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      debugPrint('⏩ Seek to: ${position.inSeconds}s');
    } catch (e) {
      debugPrint('❌ Error seeking: $e');
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentPosition = Duration.zero;
      debugPrint('⏹️ Stopped');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error stopping: $e');
    }
  }

  /// Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Repeat Mode Enum
enum RepeatMode {
  off,   // No repeat
  all,   // Repeat all tracks in queue
  one,   // Repeat current track
}
