import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import 'order_overlay_service.dart';

/// Dedicated channel for incoming-order alerts — separate from
/// [FcmService._channel] because it needs call-category / full-screen-intent
/// semantics that a plain order-status-update notification shouldn't have.
const _incomingOrdersChannel = AndroidNotificationChannel(
  'incoming_orders_channel_v3',
  'Incoming Orders',
  description: 'Full-screen incoming order alerts that require immediate action',
  importance: Importance.max,
  sound: RawResourceAndroidNotificationSound('tujh_bin1'),
  playSound: true,
);

/// Must stay top-level / static so the Dart VM can invoke it in the
/// background isolate when a push arrives while the app is killed.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] != 'new_order') return;

  if (await OrderOverlayService.hasPermission()) {
    await OrderOverlayService.showForOrder(message.data);
  } else {
    // A fresh isolate — the channel/plugin registered by FcmService.initialize()
    // in the main isolate doesn't exist here, so set both up again.
    final localNotifications = FlutterLocalNotificationsPlugin();
    await localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );
    await localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_incomingOrdersChannel);

    final pickup = message.data['pickupAddress'] as String? ?? 'Restaurant';
    final drop = message.data['dropAddress'] as String? ?? 'Customer';
    final price = message.data['price'] as String? ?? '';
    final distance = message.data['distance'] as String? ?? '';
    final body = 'From: $pickup\nTo: $drop\nEarnings: ₹$price | Dist: ${distance}km';

    await localNotifications.show(
      message.hashCode,
      message.data['restaurantName'] as String? ?? 'New order',
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _incomingOrdersChannel.id,
          _incomingOrdersChannel.name,
          channelDescription: _incomingOrdersChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.call,
          fullScreenIntent: true,
          ongoing: true,
          sound: const RawResourceAndroidNotificationSound('tujh_bin1'),
          playSound: true,
          styleInformation: BigTextStyleInformation(body),
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'accept',
              'Accept',
              showsUserInterface: true,
              cancelNotification: true,
            ),
            const AndroidNotificationAction(
              'reject',
              'Reject',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

}

class FcmService {
  FcmService(this._dio, this._tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _notificationTapController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationReceivedController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onNotificationTap =>
      _notificationTapController.stream;
      
  Stream<Map<String, dynamic>> get onNotificationReceived =>
      _notificationReceivedController.stream;

  static const _channel = AndroidNotificationChannel(
    'orders_channel',
    'Order Updates',
    description: 'New order alerts and delivery status updates',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _handleLocalNotificationPayload(payload);
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(_channel);
      await androidPlugin?.createNotificationChannel(_incomingOrdersChannel);

      // Android 14+ revokes USE_FULL_SCREEN_INTENT by default for apps
      // without calling/alarm functionality, even though it's declared in
      // the manifest — without this explicit grant, fullScreenIntent
      // notifications silently downgrade to a normal heads-up banner on
      // both the lock screen and home screen. No-ops (returns true) if
      // already granted or on pre-Android 14 devices.
      await androidPlugin?.requestFullScreenIntentPermission();

      // Overlay bubble permission ("display over other apps") — powers the
      // floating home-screen bubble for new orders that arrive while the
      // app is backgrounded (see OrderOverlayService). Separate from the
      // full-screen-intent permission above, which only covers the locked-
      // device case.
      await OrderOverlayService.requestPermission();
    }

    // Cold start via the full-screen-intent notification (lock screen /
    // killed app) — onDidReceiveNotificationResponse above isn't guaranteed
    // to fire for the launching notification itself, so check explicitly.
    final launchDetails = await _localNotifications.getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload;
    if ((launchDetails?.didNotificationLaunchApp ?? false) && launchPayload != null) {
      _handleLocalNotificationPayload(launchPayload);
    }

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _handleNotificationOpen(initialMessage);

    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);
  }

  /// Payload from a locally-shown notification — the full-screen incoming-
  /// order alert encodes the whole data map as JSON; older/other local
  /// notifications may still carry a bare orderId string.
  void _handleLocalNotificationPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        _notificationTapController.add(Map<String, dynamic>.from(decoded));
        return;
      }
    } catch (_) {
      // Not JSON — fall through to the legacy plain-orderId form.
    }
    _notificationTapController.add({'orderId': payload});
  }

  Future<void> registerToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    await _tokenStorage.saveFcmToken(token);
    try {
      await _dio.post(
        ApiEndpoints.fcmTokenSaveMobile,
        data: {'token': token, 'platform': 'mobile'},
      );
    } catch (_) {
      // Best-effort — token is also sent at OTP verify / registration.
    }
  }

  Future<void> removeToken() async {
    try {
      await _dio.delete(ApiEndpoints.fcmTokenRemove);
    } catch (_) {
      // Ignore — logging out locally regardless.
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    _notificationReceivedController.add(message.data);
    // 'new_order' pushes are already handled by the full-screen incoming-
    // order overlay (driven by the line above) — showing the plain tray
    // notification too would duplicate/compete with it.
    if (message.data['type'] == 'new_order') return;
    final notification = message.notification;
    if (notification == null) return;
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['orderId'] as String?,
    );
  }

  void _handleNotificationOpen(RemoteMessage message) {
    _notificationTapController.add(message.data);
  }

  void dispose() {
    _notificationTapController.close();
    _notificationReceivedController.close();
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) {
  final service = FcmService(
    ref.read(dioProvider),
    ref.read(tokenStorageProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
