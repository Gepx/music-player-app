import 'package:flutter/foundation.dart';
import 'package:music_player/data/models/spotify/spotify_track.dart';
import 'package:music_player/data/services/music/recent_plays_service.dart';

/// Spotify Embed Service
/// Manages Spotify embed player URLs and state
class SpotifyEmbedService extends ChangeNotifier {
  SpotifyEmbedService._();
  static final SpotifyEmbedService instance = SpotifyEmbedService._();

  // Current playback state
  SpotifyTrack? _currentTrack;
  bool _isEmbedReady = false;
  final List<SpotifyTrack> _queue = [];
  int _currentIndex = 0;

  // Getters
  SpotifyTrack? get currentTrack => _currentTrack;
  bool get isEmbedReady => _isEmbedReady;
  List<SpotifyTrack> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  /// Get Spotify embed URL for a track
  String getEmbedUrl(String trackId) {
    return 'https://open.spotify.com/embed/track/$trackId?utm_source=generator&theme=0';
  }

  /// Load a track
  void loadTrack(SpotifyTrack track, {List<SpotifyTrack>? playlist}) {
    debugPrint('🎵 Loading track for embed: ${track.name}');
    
    _currentTrack = track;
    _isEmbedReady = false;

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

    // Log to recent plays (fire and forget)
    RecentPlaysService.instance.addRecent(track);
  }

  /// Mark embed as ready
  void setEmbedReady(bool ready) {
    _isEmbedReady = ready;
    notifyListeners();
  }

  /// Play next track in queue
  void playNext() {
    if (!hasNext) {
      debugPrint('⏭️ No next track');
      return;
    }

    _currentIndex++;
    if (_currentIndex < _queue.length) {
      loadTrack(_queue[_currentIndex], playlist: _queue);
    }
  }

  /// Play previous track in queue
  void playPrevious() {
    if (!hasPrevious) {
      debugPrint('⏮️ No previous track');
      return;
    }

    _currentIndex--;
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      loadTrack(_queue[_currentIndex], playlist: _queue);
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
}

