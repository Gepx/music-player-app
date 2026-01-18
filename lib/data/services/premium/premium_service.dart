import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';
import '../database/firestore_user_service.dart';
import '../preferences/preferences_service.dart';

/// PremiumService
/// - Tracks whether the current user is premium
/// - Provides a mock purchase flow that marks the user as premium in Firestore
/// - Used to disable ads when premium
class PremiumService extends ChangeNotifier {
  PremiumService._();
  static final PremiumService instance = PremiumService._();

  AuthService get _auth => AuthService.instance;
  FirestoreUserService get _firestoreUser => FirestoreUserService.instance;
  PreferencesService get _prefs => PreferencesService.instance;

  StreamSubscription<User?>? _authSub;
  StreamSubscription? _userSub;

  bool _isPremium = false;
  bool _processing = false;

  bool get isPremium => _isPremium;
  bool get isProcessing => _processing;

  Future<void> init() async {
    // Load local cache first for instant UI/ad gating.
    try {
      _isPremium = await _prefs.getIsPremium();
      notifyListeners();
    } catch (_) {}

    _authSub ??= _auth.authStateChanges.listen((user) {
      _userSub?.cancel();
      _userSub = null;

      if (user == null) {
        _setPremium(false);
        return;
      }

      _userSub = _firestoreUser.watchUser(user.uid).listen((model) {
        _setPremium(model?.isPremium ?? false);
      });
    });

    // Kick initial state.
    final current = _auth.currentFirebaseUser;
    if (current != null) {
      _userSub ??= _firestoreUser.watchUser(current.uid).listen((model) {
        _setPremium(model?.isPremium ?? false);
      });
    }
  }

  Future<void> disposeService() async {
    await _authSub?.cancel();
    await _userSub?.cancel();
    _authSub = null;
    _userSub = null;
  }

  Future<void> purchasePremiumMock() async {
    final user = _auth.currentFirebaseUser;
    if (user == null) {
      throw Exception('Please sign in to subscribe.');
    }
    if (_processing) return;
    if (_isPremium) return;

    _processing = true;
    notifyListeners();

    try {
      // Fake processing delay.
      await Future.delayed(const Duration(seconds: 2));

      await _firestoreUser.updatePremiumStatus(
        userId: user.uid,
        isPremium: true,
      );

      _setPremium(true);
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  Future<void> cancelPremiumMock() async {
    final user = _auth.currentFirebaseUser;
    if (user == null) {
      throw Exception('Please sign in.');
    }
    if (_processing) return;

    _processing = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      await _firestoreUser.updatePremiumStatus(
        userId: user.uid,
        isPremium: false,
      );
      _setPremium(false);
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  void _setPremium(bool value) {
    if (_isPremium == value) return;
    _isPremium = value;
    // Persist locally for next launch.
    // ignore: unawaited_futures
    _prefs.setIsPremium(value);
    notifyListeners();
  }
}

