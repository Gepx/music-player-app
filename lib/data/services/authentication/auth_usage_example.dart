/// Authentication Service Usage Examples
/// This file demonstrates how to use the standardized authentication system

import 'auth_service.dart';

/// Example: Email/Password Sign Up
Future<void> exampleSignUp() async {
  final authService = AuthService.instance;
  
  final response = await authService.signUpWithEmail(
    email: 'user@example.com',
    password: 'securePassword123',
    displayName: 'John Doe',
  );
  
  if (response.success) {
    print('User signed up: ${response.user?.email}');
    print('JWT Token: ${response.user?.jwtToken}');
  } else {
    print('Sign up failed: ${response.message}');
  }
}

/// Example: Email/Password Sign In
Future<void> exampleSignIn() async {
  final authService = AuthService.instance;
  
  final response = await authService.signInWithEmail(
    email: 'user@example.com',
    password: 'securePassword123',
  );
  
  if (response.success && response.user != null) {
    print('Signed in: ${response.user!.displayNameOrEmail}');
    // User data is automatically saved to local SQLite database
  } else {
    print('Sign in failed: ${response.message}');
  }
}

/// Example: Google Sign In
Future<void> exampleGoogleSignIn() async {
  final authService = AuthService.instance;
  
  final response = await authService.signInWithGoogle();
  
  if (response.success && response.user != null) {
    print('Google sign-in successful: ${response.user!.email}');
    print('Display Name: ${response.user!.displayName}');
    print('Photo URL: ${response.user!.photoUrl}');
  } else {
    print('Google sign-in failed: ${response.message}');
  }
}

/// Example: Get Current User
Future<void> exampleGetCurrentUser() async {
  final authService = AuthService.instance;
  
  // Get from local database with JWT token attached
  final user = await authService.getCurrentUser();
  
  if (user != null) {
    print('Current User: ${user.email}');
    print('Provider: ${user.provider}');
    print('Last Login: ${user.lastLoginAt}');
    print('Is Authenticated: ${user.isAuthenticated}');
  } else {
    print('No user signed in');
  }
}

/// Example: Get JWT Token
Future<void> exampleGetJwtToken() async {
  final authService = AuthService.instance;
  
  // Get stored JWT token
  final jwtToken = await authService.getJwtToken();
  
  // Or get fresh Firebase ID token
  final firebaseToken = await authService.getFirebaseIdToken(forceRefresh: true);
  
  print('Stored JWT: $jwtToken');
  print('Firebase ID Token: $firebaseToken');
}

/// Example: Update Profile
Future<void> exampleUpdateProfile() async {
  final authService = AuthService.instance;
  
  final response = await authService.updateUserProfile(
    displayName: 'Jane Doe',
    photoUrl: 'https://example.com/photo.jpg',
  );
  
  if (response.success) {
    print('Profile updated successfully');
  }
}

/// Example: Password Reset
Future<void> examplePasswordReset() async {
  final authService = AuthService.instance;
  
  final response = await authService.sendPasswordResetEmail('user@example.com');
  
  if (response.success) {
    print('Password reset email sent');
  }
}

/// Example: Sign Out
Future<void> exampleSignOut() async {
  final authService = AuthService.instance;
  
  await authService.signOut();
  print('User signed out');
  // This signs out from Firebase, Google, and clears JWT tokens
  // User data remains in local database for offline access
}

/// Example: Delete Account
Future<void> exampleDeleteAccount() async {
  final authService = AuthService.instance;
  
  final response = await authService.deleteAccount();
  
  if (response.success) {
    print('Account deleted successfully');
    // This deletes from Firebase, local database, and clears all tokens
  }
}

/// Example: Listen to Auth State Changes
void exampleAuthStateListener() {
  final authService = AuthService.instance;
  
  authService.authStateChanges.listen((firebaseUser) {
    if (firebaseUser != null) {
      print('User signed in: ${firebaseUser.email}');
    } else {
      print('User signed out');
    }
  });
}

