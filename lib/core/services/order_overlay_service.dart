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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingOrderPrefsKey, jsonEncode(data));

    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
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
  late int _secondsLeft;
  // ignore: unused_field
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = 45;
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingOrderPrefsKey);
    if (raw != null) {
      if (mounted) {
        setState(() {
          _orderData = jsonDecode(raw);
        });
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_secondsLeft <= 1) {
          timer.cancel();
          FlutterOverlayWindow.closeOverlay();
        } else {
          setState(() => _secondsLeft--);
        }
      });
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
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
    if (_orderData == null) return const SizedBox.shrink();
    
    final total = (_orderData?['total'] as num?)?.toDouble() ?? 0.0;
    
    // Extract distances if available (mocked if not in payload)
    final pickupDistance = (_orderData?['pickupDistanceKm'] as num?)?.toDouble() ?? 0.0;
    final dropDistance = (_orderData?['dropDistanceKm'] as num?)?.toDouble() ?? 0.0;
    
    final restaurant = _orderData?['restaurant'] as Map<String, dynamic>?;
    final deliveryAddress = _orderData?['deliveryAddress'] as Map<String, dynamic>?;
    
    final pickupAddr = restaurant?['address'] as String? ?? 'Pickup Location';
    final dropAddr = deliveryAddress?['fullAddress'] as String? ?? 'Drop Location';

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
                          Text('${pickupDistance.toStringAsFixed(1)} Km', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text(pickupAddr, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          const SizedBox(height: 16),
                          Text('${dropDistance.toStringAsFixed(1)} Km', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
