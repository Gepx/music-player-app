import 'package:equatable/equatable.dart';

/// Generic Spotify API Response Wrapper
/// Used to wrap API responses with success/error states
class SpotifyResponseDto<T> extends Equatable {
  /// Whether the request was successful
  final bool success;

  /// The response data (if successful)
  final T? data;

  /// Error message (if failed)
  final String? message;

  /// HTTP status code
  final int? statusCode;

  /// Error code from Spotify API
  final String? errorCode;

  const SpotifyResponseDto({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errorCode,
  });

  /// Success factory
  factory SpotifyResponseDto.success(T data, {String? message}) {
    return SpotifyResponseDto(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
    );
  }

  /// Failure factory
  factory SpotifyResponseDto.failure({
    required String message,
    int? statusCode,
    String? errorCode,
  }) {
    return SpotifyResponseDto(
      success: false,
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }

  @override
  List<Object?> get props => [success, data, message, statusCode, errorCode];
}

/// Spotify API Error Response
class SpotifyError {
  final int status;
  final String message;

  const SpotifyError({
    required this.status,
    required this.message,
  });

  factory SpotifyError.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>?;
    return SpotifyError(
      status: error?['status'] as int? ?? 0,
      message: error?['message'] as String? ?? 'Unknown error',
    );
  }
}

