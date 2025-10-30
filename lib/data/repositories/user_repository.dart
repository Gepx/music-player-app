import 'package:flutter/foundation.dart';
import '../services/auth/auth_service.dart';
import '../models/user_model.dart';

/// User Repository
/// Manages user data and authentication state
class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  final AuthService _authService = AuthService.instance;

  // -------------------- User Info -------------------- //

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _authService.getCurrentUser();
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({String? displayName, String? photoUrl}) async {
    try {
      final response = await _authService.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return response.success;
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      return false;
    }
  }

  // -------------------- Authentication -------------------- //

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    try {
      return _authService.isSignedIn;
    } catch (e) {
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    try {
      final response = await _authService.deleteAccount();
      return response.success;
    } catch (e) {
      debugPrint('❌ Error deleting account: $e');
      return false;
    }
  }
}

