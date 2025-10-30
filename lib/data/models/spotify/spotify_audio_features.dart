import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'spotify_audio_features.g.dart';

/// Spotify Audio Features Model
/// Contains audio feature information for a track
@JsonSerializable()
class SpotifyAudioFeatures extends Equatable {
  /// The Spotify ID for the track
  final String id;

  /// A confidence measure from 0.0 to 1.0 of whether the track is acoustic
  final double acousticness;

  /// Describes how suitable a track is for dancing (0.0 to 1.0)
  final double danceability;

  /// Energy is a measure from 0.0 to 1.0
  final double energy;

  /// Predicts whether a track contains no vocals (0.0 to 1.0)
  final double instrumentalness;

  /// Detects the presence of an audience in the recording (0.0 to 1.0)
  final double liveness;

  /// The overall loudness of a track in decibels (dB)
  final double loudness;

  /// Detects the presence of spoken words in a track (0.0 to 1.0)
  final double speechiness;

  /// A measure describing the musical positiveness conveyed by a track (0.0 to 1.0)
  final double valence;

  /// The overall estimated tempo of a track in BPM
  final double tempo;

  /// The key the track is in (0 = C, 1 = C♯/D♭, 2 = D, etc.)
  final int key;

  /// Mode indicates the modality (major or minor) of a track (1 = major, 0 = minor)
  final int mode;

  /// An estimated time signature (3 to 7 indicating 3/4 to 7/4 time)
  @JsonKey(name: 'time_signature')
  final int timeSignature;

  /// The duration of the track in milliseconds
  @JsonKey(name: 'duration_ms')
  final int durationMs;

  /// The object type (audio_features)
  final String? type;

  /// The Spotify URI for the track
  final String? uri;

  /// A link to the Web API endpoint providing full details
  @JsonKey(name: 'track_href')
  final String? trackHref;

  /// A link to the Web API endpoint providing full details
  @JsonKey(name: 'analysis_url')
  final String? analysisUrl;

  const SpotifyAudioFeatures({
    required this.id,
    required this.acousticness,
    required this.danceability,
    required this.energy,
    required this.instrumentalness,
    required this.liveness,
    required this.loudness,
    required this.speechiness,
    required this.valence,
    required this.tempo,
    required this.key,
    required this.mode,
    required this.timeSignature,
    required this.durationMs,
    this.type,
    this.uri,
    this.trackHref,
    this.analysisUrl,
  });

  factory SpotifyAudioFeatures.fromJson(Map<String, dynamic> json) =>
      _$SpotifyAudioFeaturesFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyAudioFeaturesToJson(this);

  @override
  List<Object?> get props => [
        id,
        acousticness,
        danceability,
        energy,
        instrumentalness,
        liveness,
        loudness,
        speechiness,
        valence,
        tempo,
        key,
        mode,
        timeSignature,
        durationMs,
        type,
        uri,
        trackHref,
        analysisUrl,
      ];
}

