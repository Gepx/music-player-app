import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';
import '../../models/auth_response.dart';
import '../database/local_database_service.dart';
import '../database/firestore_user_service.dart';
import '../database/firestore_service.dart';

/// Comprehensive Authentication Service
/// Handles Firebase Auth, Google Sign-In, JWT tokens, and local/cloud storage
/// 
/// Storage Hierarchy:
/// 1. Firebase Auth - Primary authentication
/// 2. Firestore - Cloud user data (synced across devices)
/// 3. SQLite - Local user data (offline access)
/// 4. Secure Storage - JWT tokens (sensitive data)
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalDatabaseService _localDb = LocalDatabaseService.instance;
  final FirestoreUserService _firestoreUser = FirestoreUserService.instance;

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

      // Save to all storage layers
      await _syncUserData(user);

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

      // Save to all storage layers and update last login
      await _syncUserData(user);

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

      // Save to all storage layers and update last login
      await _syncUserData(user);

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

  /// Get current user from storage (local first, then cloud)
  Future<UserModel?> getCurrentUser() async {
    try {
      // Try to get from local database first (fastest)
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
      
      // If not in local DB but Firebase user exists
      if (currentFirebaseUser != null) {
        // Try to fetch from Firestore
        try {
          final firestoreUser = await _firestoreUser.getUserById(
            currentFirebaseUser!.uid,
          );
          
          if (firestoreUser != null) {
            // Found in Firestore, save to local and return
            await _localDb.saveUser(firestoreUser);
            
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
        
        // Not in Firestore either, create from Firebase Auth
        final user = await _createUserModel(currentFirebaseUser!);
        await _syncUserData(user);
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

      // Update in all storage layers
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

      // Delete from all storage layers
      try {
        // Delete from Firestore
        await _firestoreUser.deleteUser(userId);
      } catch (e) {
        debugPrint('⚠️ Could not delete from Firestore: $e');
      }

      // Delete from local database
      await _localDb.deleteUser(userId);

      // Clear tokens
      await clearTokens();

      // Delete from Firebase (must be last)
      await user.delete();

      // Sign out from Google if needed
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
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

  /// Sync user data across all storage layers
  /// Local (SQLite) → Firestore → Secure Storage (tokens)
  Future<void> _syncUserData(UserModel user) async {
    try {
      // 1. Save to local database (SQLite)
      await _localDb.saveUser(user);
      debugPrint('✅ User saved to local database');

      // 2. Save to Firestore (cloud sync)
      try {
        await _firestoreUser.saveUser(user);
        await _firestoreUser.updateLastLogin(user.id);
        debugPrint('✅ User synced to Firestore');
      } catch (e) {
        debugPrint('⚠️ Could not sync to Firestore (offline?): $e');
        // Don't fail if Firestore sync fails (offline support)
      }

      // 3. Tokens are already handled in createUserModel and storeTokens
      debugPrint('✅ User data fully synced across all storage layers');
    } catch (e) {
      debugPrint('❌ Error syncing user data: $e');
      rethrow;
    }
  }

  /// Watch user changes in real-time from Firestore
  Stream<UserModel?> watchUser(String userId) {
    return _firestoreUser.watchUser(userId);
  }

  /// Force sync from Firestore to local
  Future<void> syncFromFirestore(String userId) async {
    try {
      debugPrint('🔄 Syncing user from Firestore...');
      
      final firestoreUser = await _firestoreUser.getUserById(userId);
      
      if (firestoreUser != null) {
        await _localDb.saveUser(firestoreUser);
        debugPrint('✅ User synced from Firestore to local');
      } else {
        debugPrint('⚠️ User not found in Firestore');
      }
    } catch (e) {
      debugPrint('❌ Error syncing from Firestore: $e');
      rethrow;
    }
  }

  /// Check health of all storage layers
  Future<Map<String, bool>> healthCheckAll() async {
    final results = <String, bool>{};

    // Check Firebase Auth
    try {
      results['firebaseAuth'] = _auth.currentUser != null;
    } catch (e) {
      results['firebaseAuth'] = false;
    }

    // Check Local Database
    try {
      results['localDatabase'] = await _localDb.healthCheck();
    } catch (e) {
      results['localDatabase'] = false;
    }

    // Check Firestore
    try {
      results['firestore'] = await FirestoreService.instance.healthCheck();
    } catch (e) {
      results['firestore'] = false;
    }

    // Check Secure Storage
    try {
      await _secureStorage.read(key: _userIdKey);
      results['secureStorage'] = true;
    } catch (e) {
      results['secureStorage'] = false;
    }

    debugPrint('🏥 Health check results: $results');
    return results;
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

