import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';
import '../../models/auth_response.dart';
import '../database/firestore_user_service.dart';

/// Comprehensive Authentication Service
/// Handles Firebase Auth, Google Sign-In, JWT tokens, and cloud storage
///
/// Storage Hierarchy:
/// 1. Firebase Auth - Primary authentication (Single Source of Truth)
/// 2. Firestore - Cloud user data (synced across devices)
/// 3. Secure Storage - JWT tokens (sensitive data)
///
/// ⛔ REMOVED: SQLite and Preferences from this auth flow.
///
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirestoreUserService _firestoreUser = FirestoreUserService.instance;
  // ⛔ REMOVED: final PreferencesService _prefs = PreferencesService.instance;

  // Secure storage keys
  static const String _jwtTokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  // -------------------- Getters -------------------- //

  /// Stream of authentication state changes
  /// THIS IS THE SINGLE SOURCE OF TRUTH FOR YOUR APP'S UI.
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
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
      }

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

      // Save to Firestore
      await _syncUserData(user);

      // ⛔ REMOVED: _prefs.saveLoginState(true, user.id);

      debugPrint('✅ User signed up successfully: ${user.email}');
      return AuthResponse.success(
        user,
        message: 'Account created successfully',
      );
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
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      final user = await _createUserModel(
        userCredential.user!,
        provider: 'email',
      );

      // Save to Firestore and update last login
      await _syncUserData(user);

      // ⛔ REMOVED: _prefs.saveLoginState(true, user.id);

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
      return AuthResponse.failure(message: 'An unexpected error occurred: $e');
    }
  }

  // -------------------- Third Party Provider -------------------- //

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);

        final provider =
            GoogleAuthProvider()
              ..setCustomParameters({'prompt': 'select_account'});
        final userCredential = await _auth.signInWithPopup(provider);
        final user = await _createUserModel(
          userCredential.user!,
          provider: 'google',
        );
        await _syncUserData(user);
        return AuthResponse.success(
          user,
          message: 'Successfully signed in with Google',
        );
      }

      await _ensureGoogleInitialized();

      GoogleSignInAccount? googleUser;

      try {
        final future = _googleSignIn.attemptLightweightAuthentication();
        if (future != null) {
          googleUser = await future;
        }
      } on GoogleSignInException catch (e) {
        if (e.code != GoogleSignInExceptionCode.canceled) {
          debugPrint('⚠️ Lightweight Google auth failed: ${e.code}');
        }
      }

      googleUser ??= await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        debugPrint('❌ Google auth missing ID token');
        return AuthResponse.failure(
          message: 'Unable to retrieve Google ID token',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = await _createUserModel(
        userCredential.user!,
        provider: 'google',
      );

      await _syncUserData(user);

      debugPrint('✅ Google sign-in successful: ${user.email}');
      return AuthResponse.success(user, message: 'Signed in with Google');
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('⚠️ Google sign-in cancelled by user');
        return AuthResponse.failure(message: 'Google sign-in cancelled');
      }
      debugPrint('❌ Google sign-in error: ${e.code} - ${e.description}');
      return AuthResponse.failure(
        message: e.description ?? 'Google sign-in failed',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Google sign-in Firebase error: ${e.code} - ${e.message}');
      return AuthResponse.failure(
        message: _getAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      debugPrint('❌ Unexpected Google sign-in error: $e');
      return AuthResponse.failure(message: 'Google sign-in failed');
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  Future<AuthResponse> signInWithFacebook() async {
    try {
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);

        await FacebookAuth.instance.webAndDesktopInitialize(
          appId: '844484934746673',
          cookie: true,
          xfbml: true,
          version: 'v16.0',
        );

        final provider = FacebookAuthProvider();
        provider.addScope('email');

        final userCredential = await _auth.signInWithPopup(provider);
        final user = await _createUserModel(
          userCredential.user!,
          provider: 'facebook',
        );

        await _syncUserData(user);

        return AuthResponse.success(
          user,
          message: 'Successfully signed in with Facebook!',
        );
      }

      final LoginResult facebookUser = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (facebookUser.status == LoginStatus.success) {
        final accessToken = facebookUser.accessToken!;
        final credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        final userCredential = await _auth.signInWithCredential(credential);

        final user = await _createUserModel(
          userCredential.user!,
          provider: 'facebook',
        );

        await _syncUserData(user);

        return AuthResponse(
          user: user,
          message: 'Signed in with Facebook',
          success: true,
        );
      } else if (facebookUser.status == LoginStatus.cancelled) {
        return AuthResponse.failure(message: 'Facebook sign-in cancelled');
      } else {
        return AuthResponse.failure(
          message: 'Facebook sign-in failed: ${facebookUser.message}',
        );
      }
    } catch (e) {
      debugPrint('❌ Facebook sign-in error: $e');
      return AuthResponse.failure(message: 'Facebook sign-in failed');
    }
  }

  // -------------------- JWT Token Management -------------------- //
  // (This section is fine, it's about secure token storage, not auth state)

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

  /// Get current user from storage (cloud first)
  Future<UserModel?> getCurrentUser() async {
    try {
      // The ONLY check we need is for the currentFirebaseUser.
      if (currentFirebaseUser != null) {
        // Try to fetch from Firestore
        try {
          final firestoreUser = await _firestoreUser.getUserById(
            currentFirebaseUser!.uid,
          );

          if (firestoreUser != null) {
            // Found in Firestore, attach tokens and return
            final jwtToken = await getJwtToken();
            final refreshToken = await getRefreshToken();

            return firestoreUser.copyWith(
              jwtToken: jwtToken,
              refreshToken: refreshToken,
            );
          }
        } catch (e) {
          debugPrint('⚠️ Could not fetch from Firestore: $e');
        }

        // Not in Firestore, create from Firebase Auth
        debugPrint('Creating user model from currentFirebaseUser');
        final user = await _createUserModel(currentFirebaseUser!);
        await _syncUserData(user); // Sync to Firestore

        // ⛔ REMOVED: _prefs.saveLoginState(true, user.id);

        return user;
      }

      // No Firebase user, so definitely not logged in.
      // ⛔ REMOVED: _prefs.clearLoginState();
      return null;
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      return null;
    }
  }

  /// Send password reset email
  Future<AuthResponse> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to: $email');
      return AuthResponse.success(null, message: 'Password reset email sent');
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

      // Update in Firestore
      final updatedUser = await _createUserModel(user);
      await _syncUserData(updatedUser);

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
      // Sign out from Google if possible
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('⚠️ Google sign-out skipped: $e');
      }

      // Sign out from Firebase
      await _auth.signOut();

      // Clear tokens
      await clearTokens();

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

      // Delete from all storage layers
      try {
        // Delete from Firestore
        await _firestoreUser.deleteUser(userId);
      } catch (e) {
        debugPrint('⚠️ Could not delete from Firestore: $e');
      }

      // Clear tokens
      await clearTokens();

      await user.delete();

      // Sign out from Google if needed
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('⚠️ Google sign-out skipped: $e');
      }

      debugPrint('✅ User account deleted from all storage');
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

  /// Sync user data to Firestore
  Future<void> _syncUserData(UserModel user) async {
    try {
      // 1. Save to Firestore (cloud sync)
      try {
        await _firestoreUser.saveUser(user);
        await _firestoreUser.updateLastLogin(user.id);
        debugPrint('✅ User synced to Firestore');
      } catch (e) {
        debugPrint('⚠️ Could not sync to Firestore (offline?): $e');
      }

      debugPrint('✅ User data synced to Firestore');
    } catch (e) {
      debugPrint('❌ Error syncing user data: $e');
      rethrow;
    }
  }

  /// Watch user changes in real-time from Firestore
  Stream<UserModel?> watchUser(String userId) {
    return _firestoreUser.watchUser(userId);
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
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
