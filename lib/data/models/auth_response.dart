import 'user_model.dart';

/// Standardized Authentication Response
/// Used for consistent return values across all auth methods
class AuthResponse {
  final bool success;
  final UserModel? user;
  final String? message;
  final String? errorCode;

  AuthResponse({
    required this.success,
    this.user,
    this.message,
    this.errorCode,
  });

  /// Success response with user data
  factory AuthResponse.success(UserModel? user, {String? message}) {
    return AuthResponse(
      success: true,
      user: user,
      message: message ?? 'Authentication successful',
    );
  }

  /// Failure response with error details
  factory AuthResponse.failure({
    required String message,
    String? errorCode,
  }) {
    return AuthResponse(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  @override
  String toString() {
    return 'AuthResponse(success: $success, message: $message, errorCode: $errorCode)';
  }
}

