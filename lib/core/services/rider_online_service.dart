import 'dart:io';

import 'package:flutter/services.dart';

/// Starts and stops the Android foreground service that keeps the app's process
/// alive while the rider is online.
///
/// Android freezes a backgrounded process, which is why location went stale and
/// why the overlay engine had to cold-start on every order. A foreground service
/// is the only supported way to opt out of that, and the permanent "You're online"
/// notification is the price Android charges for the guarantee.
///
/// Deliberately never throws. Going online is the rider's livelihood and must not
/// fail because an OEM refused to start a service — losing the keep-alive is a
/// degradation, not a blocker.
class RiderOnlineService {
  static const MethodChannel _channel =
      MethodChannel('app.fooddelivery/rider_online');

  /// Call only once location permission has been granted. A service typed
  /// `location` throws on start without it, which would take the app down.
  static Future<bool> start() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('start') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (_) {
      // Nothing useful to do — the notification is at worst orphaned until the
      // process dies, and the rider is offline server-side either way.
    }
  }
}
