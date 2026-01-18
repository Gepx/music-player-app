import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/services/permissions/permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PermissionService notifications methods do not throw', () async {
    final granted = await PermissionService.instance.notificationsGranted();
    expect(granted, isA<bool>());

    final requested = await PermissionService.instance.requestNotifications();
    expect(requested, isA<bool>());
  });
}

