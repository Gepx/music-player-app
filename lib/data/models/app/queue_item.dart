import 'package:equatable/equatable.dart';
import 'track_model.dart';

/// Queue Item
/// Represents an item in the playback queue
class QueueItem extends Equatable {
  /// The track
  final TrackModel track;

  /// Position in queue
  final int position;

  /// Is this the currently playing track?
  final bool isCurrentlyPlaying;

  /// Was this track added manually or part of playlist/album?
  final bool isManuallyAdded;

  /// Source of the track (playlist name, album name, etc.)
  final String? source;

  /// Source ID (playlist ID, album ID, etc.)
  final String? sourceId;

  const QueueItem({
    required this.track,
    required this.position,
    this.isCurrentlyPlaying = false,
    this.isManuallyAdded = false,
    this.source,
    this.sourceId,
  });

  /// Copy with method
  QueueItem copyWith({
    TrackModel? track,
    int? position,
    bool? isCurrentlyPlaying,
    bool? isManuallyAdded,
    String? source,
    String? sourceId,
  }) {
    return QueueItem(
      track: track ?? this.track,
      position: position ?? this.position,
      isCurrentlyPlaying: isCurrentlyPlaying ?? this.isCurrentlyPlaying,
      isManuallyAdded: isManuallyAdded ?? this.isManuallyAdded,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  @override
  List<Object?> get props => [
        track,
        position,
        isCurrentlyPlaying,
        isManuallyAdded,
        source,
        sourceId,
      ];
}

