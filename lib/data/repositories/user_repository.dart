import 'package:music_player/data/models/auth_response.dart';
import 'package:music_player/data/models/user_model.dart';
import 'package:music_player/data/services/auth/auth_service.dart';

class UserRepository {
  UserRepository({AuthService? auth}) : _auth = auth ?? AuthService.instance;
  final AuthService _auth;

  Future<UserModel?> getCurrentUser() {
    return _auth.getCurrentUser();
  }

  Future<AuthResponse> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _auth.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmail(email: email, password: password);
  }

  Future<AuthResponse> signInWithGoogle() {
    return _auth.signInWithGoogle();
  }

  Future<AuthResponse> signInWithFacebook() {
    return _auth.signInWithFacebook();
  }

  Future<AuthResponse> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<AuthResponse> updatePasswordDirect({
    required String email,
    required String newPassword,
  }) {
    return _auth.updatePasswordDirect(email: email, newPassword: newPassword);
  }

  Future<AuthResponse> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) {
    return _auth.updateUserProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  Stream<UserModel?> watchUser(String userId) => _auth.watchUser(userId);

  Future<void> signOut() {
    return _auth.signOut();
  }
}
