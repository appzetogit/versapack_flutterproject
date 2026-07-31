import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _applicationId = 'com.fooddelivery.app';
const _pendingOrderPrefsKey = 'pending_overlay_order';

/// Floating "bubble" over the home screen for a new-order alert that arrives
/// while the app is backgrounded — the Rapido/Uber-style overlay, distinct
/// from the lock-screen full-screen-intent notification which already
/// covers the locked-device case.
class OrderOverlayService {
  static Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return false;
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  static Future<void> requestPermission() async {
    if (!Platform.isAndroid) return;
    if (!await FlutterOverlayWindow.isPermissionGranted()) {
      await FlutterOverlayWindow.requestPermission();
    }
  }

  /// Persists [data] so the main isolate can pick it up on resume, then
  /// shows the bubble. Safe to call from the background FCM isolate.
  static Future<void> showForOrder(Map<String, dynamic> data) async {
    if (!Platform.isAndroid) return;
    if (!await FlutterOverlayWindow.isPermissionGranted()) return;

    final encoded = jsonEncode(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingOrderPrefsKey, encoded);

    // A second order UPDATES the open window instead of replacing it.
    //
    // Closing and immediately reopening tears down one Flutter engine while
    // starting another; the two overlap, and the new window can attach before the
    // old engine has released — leaving a window on screen with nothing rendering
    // in it. That window is match-parent and consumes touches, so the home screen
    // becomes unusable. shareData pushes the new order into the engine already
    // running, so there is only ever one.
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.shareData(encoded);
      return;
    }

    await FlutterOverlayWindow.showOverlay(
      height: WindowSize.matchParent,
      width: WindowSize.matchParent,
      alignment: OverlayAlignment.center,
      flag: OverlayFlag.defaultFlag,
      enableDrag: false,
      positionGravity: PositionGravity.auto,
      overlayTitle: 'New order',
    );
  }

  static Future<void> openAppWithOrder(Map<String, dynamic> data) async {
    if (!Platform.isAndroid) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingOrderPrefsKey, jsonEncode(data));
    await reopenApp();
  }

  static Future<void> close() async {
    if (!Platform.isAndroid) return;
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  static Future<Map<String, dynamic>?> consumePendingOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingOrderPrefsKey);
    if (raw == null) return null;
    await prefs.remove(_pendingOrderPrefsKey);
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> reopenApp() async {
    const intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      package: _applicationId,
      componentName: '$_applicationId.MainActivity',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_REORDER_TO_FRONT],
    );
    await intent.launch();
  }
}

class OrderBubbleApp extends StatelessWidget {
  const OrderBubbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: _OrderOverlayUI(),
      ),
    );
  }
}

class _OrderOverlayUI extends StatefulWidget {
  const _OrderOverlayUI();

  @override
  State<_OrderOverlayUI> createState() => _OrderOverlayUIState();
}

class _OrderOverlayUIState extends State<_OrderOverlayUI> {
  Map<String, dynamic>? _orderData;

  /// FCM data values are always Strings, so parse rather than cast.
  static double _num(Object? v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString().trim() ?? '') ?? 0.0;
  }

  static String? _str(Object? v) {
    final text = v?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }
  late int _secondsLeft;
  // ignore: unused_field
  Timer? _timer;

  /// Closes the window if nothing has rendered shortly after it attached.
  ///
  /// This is the safety net for the whole feature. The window is match-parent and
  /// starts consuming touches the instant it attaches, but its content is only
  /// known after an async read — so ANY failure in between (missing payload, a
  /// decode error, a build exception) used to leave a full-screen invisible window
  /// swallowing every tap on the home screen, with nothing left running to remove
  /// it. In release that is worse than debug, because a build failure paints
  /// Flutter's blank release error widget rather than the red debug one.
  Timer? _watchdog;

  StreamSubscription<dynamic>? _dataSub;

  @override
  void initState() {
    super.initState();
    _secondsLeft = 45;

    _watchdog = Timer(const Duration(seconds: 5), () {
      if (_orderData == null) {
        debugPrint('[Overlay] Nothing rendered within 5s — closing to free the screen.');
        FlutterOverlayWindow.closeOverlay();
      }
    });

    // A second order arriving while this one is open updates it in place, rather
    // than a new window being stacked on top.
    _dataSub = FlutterOverlayWindow.overlayListener.listen((event) {
      try {
        final decoded = jsonDecode(event.toString());
        if (decoded is Map && mounted) {
          setState(() {
            _orderData = Map<String, dynamic>.from(decoded);
            _secondsLeft = 45; // the countdown belongs to the new order
          });
          _startCountdown();
        }
      } catch (e) {
        debugPrint('[Overlay] Ignoring unreadable shared data: $e');
      }
    });

    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendingOrderPrefsKey);

      // No payload means there is nothing to show — most often because the main
      // isolate consumed it on resume. Leaving the window attached in that state is
      // exactly what froze the home screen, so close rather than sit invisible.
      if (raw == null) {
        debugPrint('[Overlay] No pending order found — closing.');
        await FlutterOverlayWindow.closeOverlay();
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        await FlutterOverlayWindow.closeOverlay();
        return;
      }

      if (!mounted) return;
      setState(() => _orderData = Map<String, dynamic>.from(decoded));
      _startCountdown();
    } catch (e) {
      // Never swallowed: an exception here previously left the window attached
      // forever with nothing drawn.
      debugPrint('[Overlay] Failed to load order, closing: $e');
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        FlutterOverlayWindow.closeOverlay();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _watchdog?.cancel();
    _dataSub?.cancel();
    super.dispose();
  }

  Future<void> _accept() async {
    await OrderOverlayService.reopenApp();
    await FlutterOverlayWindow.closeOverlay();
  }

  Future<void> _reject() async {
    // In a full implementation, we might clear the shared prefs or make an API call to reject
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOrderPrefsKey);
    await FlutterOverlayWindow.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    // NEVER return an empty widget here.
    //
    // The window is already attached and already consuming touches by the time
    // build runs. Returning SizedBox.shrink() over a transparent Scaffold is
    // precisely the reported bug: a full-screen invisible layer that eats every tap
    // on the home screen with no way for the user to dismiss it. While the order is
    // still loading we paint a visible, tappable scrim instead — so the window is
    // always either useful or obviously dismissible, never invisible.
    if (_orderData == null) {
      return GestureDetector(
        onTap: () => FlutterOverlayWindow.closeOverlay(),
        child: Container(
          color: Colors.black.withValues(alpha: 0.55),
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 14),
              Text(
                'Loading new order...',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              SizedBox(height: 6),
              Text(
                'Tap anywhere to dismiss',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // This map came from an FCM push, where EVERY value is a String — FCM rejects
    // any other type in `data`. Casting them with `as num?` threw
    // "type 'String' is not a subtype of type 'num?' in type cast", so the overlay
    // rendered a red error box over the launcher instead of the order card. The
    // Accept/Reject buttons only looked broken because they were never drawn.
    final total = _num(_orderData?['total']);

    // The push carries ONE road distance for the whole trip, as `tripDistanceKm`
    // (with `distance` as an alias). There are no separate pickup/drop distances,
    // so the previous keys were always absent and both values were silently 0.
    final tripDistance = _num(_orderData?['tripDistanceKm'] ?? _orderData?['distance']);

    // Rider-to-restaurant distance is per-rider, so it only rides on the socket
    // payload — one FCM message is built for the whole broadcast and cannot carry
    // it. Render the line without a distance rather than a confident "0.0 Km".
    final pickupDistance = _num(_orderData?['pickupDistanceKm']);

    // The payload is flat: there is no nested `restaurant` or `deliveryAddress`
    // object to read an address out of, only these string fields.
    final pickupAddr = _str(_orderData?['pickupAddress']) ??
        _str(_orderData?['restaurantAddress']) ??
        _str(_orderData?['restaurantName']) ??
        'Pickup Location';
    final dropAddr = _str(_orderData?['dropAddress']) ??
        _str(_orderData?['customerAddress']) ??
        'Drop Location';

    return Stack(
      children: [
        // The Top Card
        Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.two_wheeler, size: 14, color: Colors.black87),
                      SizedBox(width: 4),
                      Text('Bike', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Earnings
                Row(
                  children: [
                    const Text('Extra ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
                    Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1EBE5D))),
                  ],
                ),
                const SizedBox(height: 20),
                // Timeline
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.circle, size: 12, color: Colors.black),
                        Container(width: 2, height: 40, color: Colors.grey[300]),
                        const Icon(Icons.arrow_drop_down, size: 20, color: Colors.black),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pickupDistance > 0)
                            Text('${pickupDistance.toStringAsFixed(1)} Km', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text(pickupAddr, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          const SizedBox(height: 16),
                          if (tripDistance > 0)
                            Text('${tripDistance.toStringAsFixed(1)} Km', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text(dropAddr, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    GestureDetector(
                      onTap: _reject,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                        child: const Icon(Icons.remove, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _accept,
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107), // Rapido yellow
                            borderRadius: BorderRadius.circular(27),
                          ),
                          child: const Center(
                            child: Text('Accept', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // The Bubble
        Positioned(
          bottom: 120,
          left: 16,
          child: GestureDetector(
            onTap: _accept,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1),
                ],
                border: Border.all(color: Colors.grey[200]!, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('rapido', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  const SizedBox(height: 2),
                  const Text('Captain', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
