import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission Service
/// Central place to request/check app permissions.
///
/// CP3a focus: Notifications permission (Android 13+ / iOS).
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      const settings = InitializationSettings(android: android, iOS: ios);
      await _localNotifications.initialize(settings);
      _initialized = true;
    } catch (e) {
      debugPrint('⚠️ PermissionService init failed: $e');
    }
  }

  /// Returns true if notifications are currently granted.
  Future<bool> notificationsGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('⚠️ PermissionService notificationsGranted error: $e');
      return false;
    }
  }

  /// Request notifications permission.
  ///
  /// - On Android 13+ this triggers the POST_NOTIFICATIONS runtime prompt.
  /// - On iOS this triggers the system notification permission prompt.
  Future<bool> requestNotifications() async {
    await init();

    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('⚠️ PermissionService requestNotifications error: $e');
      return false;
    }
  }
}

