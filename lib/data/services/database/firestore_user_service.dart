import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import 'firestore_service.dart';

/// Firestore User Service
/// Handles user data operations in Cloud Firestore
class FirestoreUserService {
  FirestoreUserService._();
  static final FirestoreUserService instance = FirestoreUserService._();

  final FirestoreService _firestore = FirestoreService.instance;

  // -------------------- User Operations -------------------- //

  /// Save or update user in Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      // Don't store JWT tokens in Firestore (security)
      final userData = user.toJson();
      userData.remove('jwtToken');
      userData.remove('refreshToken');

      await _firestore.users.doc(user.id).set(
        userData,
        SetOptions(merge: true), // Merge to preserve existing data
      );
      debugPrint('✅ User saved to Firestore: ${user.email}');
    } catch (e) {
      debugPrint('❌ Error saving user to Firestore: $e');
      rethrow;
    }
  }

  /// Get user from Firestore by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.users.doc(userId).get();
      
      if (!doc.exists) {
        debugPrint('⚠️ User not found in Firestore: $userId');
        return null;
      }

      final data = doc.data();
      if (data == null) return null;

      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error getting user from Firestore: $e');
      return null;
    }
  }

  /// Get user from Firestore by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore.users
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('⚠️ User not found in Firestore: $email');
        return null;
      }

      return UserModel.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      debugPrint('❌ Error getting user by email from Firestore: $e');
      return null;
    }
  }

  /// Update user's last login time
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.users.doc(userId).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Updated last login in Firestore for user: $userId');
    } catch (e) {
      debugPrint('❌ Error updating last login in Firestore: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;

      if (updates.isEmpty) return;

      await _firestore.users.doc(userId).update(updates);
      debugPrint('✅ User profile updated in Firestore');
    } catch (e) {
      debugPrint('❌ Error updating user profile in Firestore: $e');
      rethrow;
    }
  }

  /// Delete user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.users.doc(userId).delete();
      debugPrint('✅ User deleted from Firestore: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting user from Firestore: $e');
      rethrow;
    }
  }

  /// Listen to user changes in real-time
  Stream<UserModel?> watchUser(String userId) {
    return _firestore.users.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return UserModel.fromJson(snapshot.data()!);
    });
  }

  /// Sync user data from Firebase Auth to Firestore
  Future<void> syncUserData(UserModel user) async {
    try {
      final firestoreUser = await getUserById(user.id);

      if (firestoreUser == null) {
        // User doesn't exist in Firestore, create
        await saveUser(user);
      } else {
        // User exists, update only if data is newer
        final shouldUpdate = user.lastLoginAt != null &&
            (firestoreUser.lastLoginAt == null ||
                user.lastLoginAt!.isAfter(firestoreUser.lastLoginAt!));

        if (shouldUpdate) {
          await saveUser(user);
        }
      }

      debugPrint('✅ User data synced to Firestore');
    } catch (e) {
      debugPrint('❌ Error syncing user data: $e');
      // Don't rethrow - sync errors shouldn't block auth
    }
  }

  /// Batch save multiple users
  Future<void> saveUsers(List<UserModel> users) async {
    try {
      final batch = _firestore.batch();

      for (final user in users) {
        final userData = user.toJson();
        userData.remove('jwtToken');
        userData.remove('refreshToken');

        batch.set(
          _firestore.users.doc(user.id),
          userData,
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      debugPrint('✅ ${users.length} users saved to Firestore');
    } catch (e) {
      debugPrint('❌ Error batch saving users to Firestore: $e');
      rethrow;
    }
  }

  /// Check if user exists in Firestore
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore.users.doc(userId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ Error checking user existence: $e');
      return false;
    }
  }

  /// Get total user count (admin/debug only)
  Future<int> getUserCount() async {
    try {
      final snapshot = await _firestore.users.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ Error getting user count: $e');
      return 0;
    }
  }
}

