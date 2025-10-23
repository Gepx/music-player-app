import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

/// Music Playback Service
/// Handles audio playback using just_audio package
class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // -------------------- Getters -------------------- //

  /// Get audio player instance
  AudioPlayer get player => _audioPlayer;

  /// Get current playback state
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  /// Get current position
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  /// Get duration
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  /// Get current position
  Duration get currentPosition => _audioPlayer.position;

  /// Get total duration
  Duration? get duration => _audioPlayer.duration;

  /// Check if playing
  bool get isPlaying => _audioPlayer.playing;

  /// Get current volume (0.0 to 1.0)
  double get volume => _audioPlayer.volume;

  /// Get current speed
  double get speed => _audioPlayer.speed;

  /// Get loop mode
  LoopMode get loopMode => _audioPlayer.loopMode;

  // -------------------- Playback Controls -------------------- //

  /// Load and play audio from URL
  Future<Duration?> playFromUrl(String url) async {
    try {
      debugPrint('🎵 Loading audio from: $url');
      final duration = await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      debugPrint('✅ Audio loaded and playing');
      return duration;
    } catch (e) {
      debugPrint('❌ Error playing audio: $e');
      return null;
    }
  }

  /// Load and play audio from file path
  Future<Duration?> playFromFile(String filePath) async {
    try {
      debugPrint('🎵 Loading audio from file: $filePath');
      final duration = await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.play();
      debugPrint('✅ Audio loaded and playing');
      return duration;
    } catch (e) {
      debugPrint('❌ Error playing audio: $e');
      return null;
    }
  }

  /// Play audio
  Future<void> play() async {
    try {
      await _audioPlayer.play();
      debugPrint('▶️ Playing audio');
    } catch (e) {
      debugPrint('❌ Error playing: $e');
    }
  }

  /// Pause audio
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      debugPrint('⏸️ Paused audio');
    } catch (e) {
      debugPrint('❌ Error pausing: $e');
    }
  }

  /// Stop audio
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      debugPrint('⏹️ Stopped audio');
    } catch (e) {
      debugPrint('❌ Error stopping: $e');
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await play();
    }
  }

  // -------------------- Seeking -------------------- //

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      debugPrint('⏩ Seeked to: ${position.inSeconds}s');
    } catch (e) {
      debugPrint('❌ Error seeking: $e');
    }
  }

  /// Skip forward by duration
  Future<void> skipForward({Duration duration = const Duration(seconds: 10)}) async {
    final newPosition = currentPosition + duration;
    if (this.duration != null && newPosition <= this.duration!) {
      await seek(newPosition);
    } else if (this.duration != null) {
      await seek(this.duration!);
    }
  }

  /// Skip backward by duration
  Future<void> skipBackward({Duration duration = const Duration(seconds: 10)}) async {
    final newPosition = currentPosition - duration;
    if (newPosition >= Duration.zero) {
      await seek(newPosition);
    } else {
      await seek(Duration.zero);
    }
  }

  // -------------------- Volume & Speed Control -------------------- //

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      debugPrint('🔊 Volume set to: $volume');
    } catch (e) {
      debugPrint('❌ Error setting volume: $e');
    }
  }

  /// Set playback speed (0.5 to 2.0)
  Future<void> setSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed.clamp(0.5, 2.0));
      debugPrint('⚡ Speed set to: ${speed}x');
    } catch (e) {
      debugPrint('❌ Error setting speed: $e');
    }
  }

  // -------------------- Loop Mode -------------------- //

  /// Set loop mode
  Future<void> setLoopMode(LoopMode mode) async {
    try {
      await _audioPlayer.setLoopMode(mode);
      debugPrint('🔁 Loop mode set to: $mode');
    } catch (e) {
      debugPrint('❌ Error setting loop mode: $e');
    }
  }

  /// Toggle loop mode
  Future<void> toggleLoopMode() async {
    final currentMode = _audioPlayer.loopMode;
    LoopMode newMode;
    
    switch (currentMode) {
      case LoopMode.off:
        newMode = LoopMode.one;
        break;
      case LoopMode.one:
        newMode = LoopMode.all;
        break;
      case LoopMode.all:
        newMode = LoopMode.off;
        break;
    }
    
    await setLoopMode(newMode);
  }

  // -------------------- Playlist Management -------------------- //

  /// Load playlist from URLs
  Future<void> setPlaylist(List<String> urls) async {
    try {
      final playlist = ConcatenatingAudioSource(
        children: urls.map((url) => AudioSource.uri(Uri.parse(url))).toList(),
      );
      await _audioPlayer.setAudioSource(playlist);
      debugPrint('✅ Playlist loaded with ${urls.length} tracks');
    } catch (e) {
      debugPrint('❌ Error loading playlist: $e');
    }
  }

  /// Play next track in playlist
  Future<void> playNext() async {
    try {
      if (_audioPlayer.hasNext) {
        await _audioPlayer.seekToNext();
        debugPrint('⏭️ Playing next track');
      }
    } catch (e) {
      debugPrint('❌ Error playing next: $e');
    }
  }

  /// Play previous track in playlist
  Future<void> playPrevious() async {
    try {
      if (_audioPlayer.hasPrevious) {
        await _audioPlayer.seekToPrevious();
        debugPrint('⏮️ Playing previous track');
      }
    } catch (e) {
      debugPrint('❌ Error playing previous: $e');
    }
  }

  // -------------------- Cleanup -------------------- //

  /// Dispose audio player
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      debugPrint('🗑️ Audio player disposed');
    } catch (e) {
      debugPrint('❌ Error disposing player: $e');
    }
  }
}

