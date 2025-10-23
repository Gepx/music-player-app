import '../../models/auth_response.dart';
import '../../models/user_model.dart';

/// Authentication Service Interface
/// Defines the contract for authentication operations
/// Useful for testing and mocking
abstract class IAuthService {
  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle();

  /// Send password reset email
  Future<AuthResponse> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<AuthResponse> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Sign out
  Future<void> signOut();

  /// Delete account
  Future<AuthResponse> deleteAccount();

  /// Get JWT token
  Future<String?> getJwtToken();

  /// Get Firebase ID token
  Future<String?> getFirebaseIdToken({bool forceRefresh = false});

  /// Check if user is signed in
  bool get isSignedIn;
}

