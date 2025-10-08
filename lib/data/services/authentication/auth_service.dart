import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';
import '../../models/auth_response.dart';
import '../database/local_database_service.dart';

/// Comprehensive Authentication Service
/// Handles Firebase Auth, Google Sign-In, JWT tokens, and local storage
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalDatabaseService _localDb = LocalDatabaseService.instance;

  // Secure storage keys
  static const String _jwtTokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  // -------------------- Getters -------------------- //

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // -------------------- Email/Password Authentication -------------------- //

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Create user in Firebase
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      // Create user model
      final user = await _createUserModel(
        userCredential.user!,
        provider: 'email',
      );

      // Save to local database
      await _localDb.saveUser(user);

      debugPrint('✅ User signed up successfully: ${user.email}');
      return AuthResponse.success(user, message: 'Account created successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign up error: ${e.code} - ${e.message}');
      return AuthResponse.failure(
        message: _getAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      debugPrint('❌ Unexpected sign up error: $e');
      return AuthResponse.failure(message: 'An unexpected error occurred');
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      final user = await _createUserModel(
        userCredential.user!,
        provider: 'email',
      );

      // Save to local database and update last login
      await _localDb.saveUser(user);
      await _localDb.updateLastLogin(user.id);

      debugPrint('✅ User signed in successfully: ${user.email}');
      return AuthResponse.success(user, message: 'Signed in successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign in error: ${e.code} - ${e.message}');
      return AuthResponse.failure(
        message: _getAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      debugPrint('❌ Unexpected sign in error: $e');
      return AuthResponse.failure(message: 'An unexpected error occurred');
    }
  }

  // -------------------- Google Sign-In -------------------- //

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return AuthResponse.failure(message: 'Google sign-in cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Create user model
      final user = await _createUserModel(
        userCredential.user!,
        provider: 'google',
      );

      // Save to local database and update last login
      await _localDb.saveUser(user);
      await _localDb.updateLastLogin(user.id);

      debugPrint('✅ Google sign-in successful: ${user.email}');
      return AuthResponse.success(user, message: 'Signed in with Google');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Google sign-in error: ${e.code} - ${e.message}');
      return AuthResponse.failure(
        message: _getAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      debugPrint('❌ Unexpected Google sign-in error: $e');
      return AuthResponse.failure(message: 'Google sign-in failed');
    }
  }

  // -------------------- JWT Token Management -------------------- //

  /// Store JWT tokens securely
  Future<void> storeTokens({
    required String jwtToken,
    String? refreshToken,
  }) async {
    try {
      await _secureStorage.write(key: _jwtTokenKey, value: jwtToken);
      if (refreshToken != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      }
      if (currentFirebaseUser != null) {
        await _secureStorage.write(
          key: _userIdKey,
          value: currentFirebaseUser!.uid,
        );
      }
      debugPrint('✅ JWT tokens stored securely');
    } catch (e) {
      debugPrint('❌ Error storing tokens: $e');
      rethrow;
    }
  }

  /// Retrieve JWT token
  Future<String?> getJwtToken() async {
    try {
      return await _secureStorage.read(key: _jwtTokenKey);
    } catch (e) {
      debugPrint('❌ Error retrieving JWT token: $e');
      return null;
    }
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('❌ Error retrieving refresh token: $e');
      return null;
    }
  }

  /// Get Firebase ID token (can be used as JWT)
  Future<String?> getFirebaseIdToken({bool forceRefresh = false}) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) return null;

      final idToken = await user.getIdToken(forceRefresh);
      
      // Store the token
      if (idToken != null) {
        await storeTokens(jwtToken: idToken);
      }
      
      return idToken;
    } catch (e) {
      debugPrint('❌ Error getting Firebase ID token: $e');
      return null;
    }
  }

  /// Clear stored tokens
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: _jwtTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      debugPrint('✅ JWT tokens cleared');
    } catch (e) {
      debugPrint('❌ Error clearing tokens: $e');
    }
  }

  // -------------------- User Management -------------------- //

  /// Get current user from local database
  Future<UserModel?> getCurrentUser() async {
    try {
      // Try to get from local database
      final localUser = await _localDb.getCurrentUser();
      
      if (localUser != null) {
        // Attach JWT token from secure storage
        final jwtToken = await getJwtToken();
        final refreshToken = await getRefreshToken();
        
        return localUser.copyWith(
          jwtToken: jwtToken,
          refreshToken: refreshToken,
        );
      }
      
      // If not in local DB but Firebase user exists, create and save
      if (currentFirebaseUser != null) {
        final user = await _createUserModel(currentFirebaseUser!);
        await _localDb.saveUser(user);
        return user;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      return null;
    }
  }

  /// Send password reset email
  Future<AuthResponse> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to: $email');
      return AuthResponse.success(
        null,
        message: 'Password reset email sent',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset error: ${e.code}');
      return AuthResponse.failure(
        message: _getAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResponse.failure(message: 'Failed to send reset email');
    }
  }

  /// Update user profile
  Future<AuthResponse> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        return AuthResponse.failure(message: 'No user signed in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update in local database
      final updatedUser = await _createUserModel(user);
      await _localDb.saveUser(updatedUser);

      debugPrint('✅ User profile updated');
      return AuthResponse.success(updatedUser, message: 'Profile updated');
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      return AuthResponse.failure(message: 'Failed to update profile');
    }
  }

  // -------------------- Sign Out -------------------- //

  /// Sign out from all services
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      // Clear tokens
      await clearTokens();

      // Clear local database (optional - keep user data for offline access)
      // await _localDb.clearAllUsers();

      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// Delete user account
  Future<AuthResponse> deleteAccount() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        return AuthResponse.failure(message: 'No user signed in');
      }

      final userId = user.uid;

      // Delete from Firebase
      await user.delete();

      // Delete from local database
      await _localDb.deleteUser(userId);

      // Clear tokens
      await clearTokens();

      // Sign out from Google if needed
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      debugPrint('✅ User account deleted');
      return AuthResponse.success(
        null,
        message: 'Account deleted successfully',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Delete account error: ${e.code}');
      return AuthResponse.failure(
        message: _getAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      debugPrint('❌ Error deleting account: $e');
      return AuthResponse.failure(message: 'Failed to delete account');
    }
  }

  // -------------------- Helper Methods -------------------- //

  /// Create UserModel from Firebase User
  Future<UserModel> _createUserModel(
    User firebaseUser, {
    String? provider,
  }) async {
    final jwtToken = await getJwtToken();
    final refreshToken = await getRefreshToken();

    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      createdAt: firebaseUser.metadata.creationTime,
      lastLoginAt: DateTime.now(),
      jwtToken: jwtToken,
      refreshToken: refreshToken,
      provider: provider,
    );
  }

  /// Get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

