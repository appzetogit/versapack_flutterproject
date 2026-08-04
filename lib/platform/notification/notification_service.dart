import '../permission/permission_service.dart';

/// Local/push notification scaffolding.
///
/// The backend owns delivery (FCM); the app has no messaging plugin in scope,
/// so this records the permission decision and exposes the token hook a real
/// implementation would fill in.
abstract interface class NotificationService {
  Future<bool> requestPermission();
  Future<String?> deviceToken();
}

class PlaceholderNotificationService implements NotificationService {
  PlaceholderNotificationService(this._permissions);

  final PermissionService _permissions;

  @override
  Future<bool> requestPermission() async =>
      await _permissions.requestNotifications() == PermissionStatus.granted;

  /// A real build returns the FCM token here, which verify-otp accepts as
  /// `fcmToken`.
  @override
  Future<String?> deviceToken() async => null;
}
