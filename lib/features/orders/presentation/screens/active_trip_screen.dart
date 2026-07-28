import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:food_user_application/core/error/result.dart';
import 'package:food_user_application/core/services/haptic_service.dart';
import 'package:food_user_application/core/services/location_service.dart';
import 'package:food_user_application/core/utils/map_launcher.dart';
import 'package:food_user_application/core/utils/polyline_decoder.dart';
import 'package:food_user_application/features/auth/application/auth_controller.dart';
import 'package:food_user_application/features/auth/application/auth_state.dart';
import 'package:food_user_application/features/orders/application/active_trip_visibility_controller.dart';
import 'package:food_user_application/features/orders/application/orders_controller.dart';
import 'package:food_user_application/features/orders/application/orders_state.dart';
import 'package:food_user_application/features/chat/presentation/screens/chat_screen.dart';
import 'package:food_user_application/features/orders/data/models/delivery_order.dart';
import 'package:food_user_application/features/orders/data/orders_repository.dart';
import 'package:food_user_application/features/orders/presentation/widgets/collect_payment_sheet.dart';
import 'package:food_user_application/features/support/data/support_repository.dart';

const _tripOnlineGreen = Color(0xFF1EBE5D);

/// Full-screen "active trip" map view, stacked over the app by [main.dart]'s
/// overlay builder whenever there is an active order and the trip hasn't
/// been minimized. Mirrors [IncomingOrderScreen]'s overlay pattern so it
/// works regardless of the current GoRouter location, and automatically
/// reappears if the app is relaunched mid-delivery.
class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  GoogleMapController? _mapController;
  List<LatLng> _routePoints = [];
  LatLng? _routeDestination;
  double? _etaMins;
  String? _routeKey;
  Timer? _routeRefreshTimer;
  BitmapDescriptor? _bikeMarkerIcon;
  StreamSubscription<Position>? _positionSub;
  bool _routeFetchInFlight = false;
  DeliveryOrder? _lastOrder;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
    _positionSub = ref.read(locationServiceProvider).positionStream.listen(_onPositionUpdate);
  }

  @override
  void dispose() {
    _routeRefreshTimer?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    final frame = await codec.getNextFrame();
    final bytes = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _loadMarkerIcon() async {
    try {
      final bytes = await _getBytesFromAsset('assets/image/bike.png', 80);
      if (!mounted) return;
      setState(() => _bikeMarkerIcon = BitmapDescriptor.fromBytes(bytes));
    } catch (_) {
      // Falls back to the native blue dot if the asset fails to decode.
    }
  }

  void _onPositionUpdate(Position position) {
    if (_routePoints.isEmpty && !_routeFetchInFlight && _lastOrder != null) {
      _fetchRoute(_lastOrder!, _targetFor(_lastOrder!));
    }
  }

  void _maybeFetchRoute(DeliveryOrder order) {
    _lastOrder = order;
    final target = _targetFor(order);
    final key = '${order.id}::$target';
    if (key == _routeKey) return;
    _routeKey = key;
    _fetchRoute(order, target);

    _routeRefreshTimer?.cancel();
    _routeRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final ordersState = ref.read(ordersControllerProvider);
      if (ordersState is OrdersLoaded && ordersState.hasActiveOrder) {
        _fetchRoute(ordersState.currentOrder!, target);
      }
    });
  }

  String _targetFor(DeliveryOrder order) {
    final navigateToRestaurant = order.currentPhase == 'en_route_to_pickup' ||
        order.currentPhase == 'at_pickup';
    return navigateToRestaurant ? 'restaurant' : 'customer';
  }

  Future<void> _fetchRoute(DeliveryOrder order, String target) async {
    final pos = ref.read(locationServiceProvider).lastPosition;
    if (pos == null || _routeFetchInFlight) return;
    _routeFetchInFlight = true;
    final result = await ref.read(ordersRepositoryProvider).getRoute(
          order.id,
          lat: pos.latitude,
          lng: pos.longitude,
          target: target,
        );
    _routeFetchInFlight = false;
    if (!mounted) return;
    result.when(
      success: (data) {
        final encoded = data['polyline'] as String?;
        final points = (encoded != null && encoded.isNotEmpty)
            ? decodePolyline(encoded)
            : <LatLng>[];
        final destLoc = target == 'restaurant'
            ? order.restaurant.location
            : order.deliveryAddress.location;
        final destination = destLoc != null
            ? LatLng(destLoc.lat, destLoc.lng)
            : (points.isNotEmpty ? points.last : null);
        setState(() {
          _routePoints = points;
          _routeDestination = destination;
          _etaMins = (data['durationMins'] as num?)?.toDouble();
        });
        if (destination != null && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFor(LatLng(pos.latitude, pos.longitude), destination),
              80,
            ),
          );
        }
      },
      failure: (_) {},
    );
  }

  LatLngBounds _boundsFor(LatLng a, LatLng b) {
    return LatLngBounds(
      southwest: LatLng(
        a.latitude < b.latitude ? a.latitude : b.latitude,
        a.longitude < b.longitude ? a.longitude : b.longitude,
      ),
      northeast: LatLng(
        a.latitude > b.latitude ? a.latitude : b.latitude,
        a.longitude > b.longitude ? a.longitude : b.longitude,
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runAction(Future<Result<DeliveryOrder, AppError>> Function() call) async {
    final result = await call();
    result.when(success: (_) {}, failure: (error) => _showSnack(error.message));
  }

  ({String label, IconData icon, Future<void> Function() action})? _actionFor(DeliveryOrder order) {
    final controller = ref.read(ordersControllerProvider.notifier);
    switch (order.currentPhase) {
      case 'en_route_to_pickup':
        return (
          label: 'Reached pickup',
          icon: Icons.storefront_outlined,
          action: () => _runAction(() => controller.reachedPickup(order.id)),
        );
      case 'at_pickup':
        return (
          label: 'Confirm pickup',
          icon: Icons.check_circle_outline,
          action: () => _runAction(() => controller.confirmPickup(order.id)),
        );
      case 'en_route_to_delivery':
        return (
          label: 'Reached drop',
          icon: Icons.flag_outlined,
          action: () => _runAction(() => controller.reachedDrop(order.id)),
        );
      case 'at_drop':
        if (order.dropOtpRequired && !order.dropOtpVerified) {
          return (
            label: 'Verify OTP',
            icon: Icons.password_outlined,
            action: () => _promptDropOtp(order),
          );
        }
        if (!order.isPaid) {
          return (
            label: 'Collect payment',
            icon: Icons.payments_outlined,
            action: () => _showCollectPaymentSheet(order),
          );
        }
        return (
          label: 'Complete delivery',
          icon: Icons.done_all_rounded,
          action: () => _completeDelivery(order),
        );
      default:
        return null;
    }
  }

  Future<void> _completeDelivery(DeliveryOrder order) async {
    final result = await ref.read(ordersControllerProvider.notifier).completeOrder(order.id);
    result.when(
      success: (_) {
        ref.read(activeTripVisibilityControllerProvider.notifier).show();
        if (mounted) context.go('/main');
      },
      failure: (error) => _showSnack(error.message),
    );
  }

  Future<void> _promptDropOtp(DeliveryOrder order) async {
    final controller = ref.read(ordersControllerProvider.notifier);
    final otpController = TextEditingController();
    final otp = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Verify Drop OTP'),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(hintText: 'Enter 6-digit OTP'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(otpController.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    if (otp == null || otp.isEmpty) return;
    final result = await controller.verifyDropOtp(order.id, otp);
    result.when(success: (_) {}, failure: (error) => _showSnack(error.message));
  }

  Future<void> _showCollectPaymentSheet(DeliveryOrder order) async {
    final collected = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CollectPaymentSheet(order: order),
    );
    if (collected == true) {
      ref.read(ordersControllerProvider.notifier).refreshCurrent();
    }
  }

  void _openChat(DeliveryOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(order: order)),
    );
  }

  Future<void> _dial(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showEmergencyHelp() async {
    final result = await ref.read(supportRepositoryProvider).getEmergencyHelp();
    if (!mounted) return;
    result.when(
      success: (data) {
        final phone = data['accidentHelpline'] as String? ?? data['medicalEmergency'] as String?;
        if (phone != null && phone.isNotEmpty) {
          _dial(phone);
        } else {
          _showSnack('No emergency contact available');
        }
      },
      failure: (error) => _showSnack(error.message),
    );
  }

  Widget _buildMap(DeliveryOrder order) {
    final authState = ref.watch(authControllerProvider);
    final isBike = authState is AuthAuthenticated &&
        (authState.user.vehicleType?.toLowerCase() == 'bike' ||
            authState.user.vehicleType?.toLowerCase() == 'two_wheeler');
    final useCustomMarker = isBike && _bikeMarkerIcon != null;

    return StreamBuilder<Position>(
      stream: ref.read(locationServiceProvider).positionStream,
      initialData: ref.read(locationServiceProvider).lastPosition,
      builder: (context, snapshot) {
        final pos = snapshot.data;
        final initialTarget = pos != null
            ? LatLng(pos.latitude, pos.longitude)
            : (_routeDestination ?? const LatLng(0, 0));
        final isPickupPhase = _targetFor(order) == 'restaurant';

        return GoogleMap(
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: CameraPosition(target: initialTarget, zoom: 15),
          markers: {
            if (_routeDestination != null)
              Marker(
                markerId: const MarkerId('trip_destination'),
                position: _routeDestination!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  isPickupPhase ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueViolet,
                ),
              ),
            if (useCustomMarker && pos != null)
              Marker(
                markerId: const MarkerId('delivery_partner'),
                position: LatLng(pos.latitude, pos.longitude),
                icon: _bikeMarkerIcon!,
                anchor: const Offset(0.5, 0.5),
                rotation: pos.heading,
                flat: true,
              ),
          },
          polylines: {
            if (_routePoints.length > 1)
              Polyline(
                polylineId: const PolylineId('active_trip_route'),
                points: _routePoints,
                color: Theme.of(context).primaryColor,
                width: 5,
              ),
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          compassEnabled: false,
          mapToolbarEnabled: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersControllerProvider);

    ref.listen<OrdersState>(ordersControllerProvider, (previous, next) {
      if (next is OrdersLoaded && next.hasActiveOrder) {
        _maybeFetchRoute(next.currentOrder!);
      }
    });

    if (ordersState is! OrdersLoaded || !ordersState.hasActiveOrder) {
      return const SizedBox.shrink();
    }
    final order = ordersState.currentOrder!;

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeFetchRoute(order));

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E1E1E);
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final isPickupPhase = _targetFor(order) == 'restaurant';
    final title = isPickupPhase ? 'Reach pickup' : 'Reach drop';
    final etaLabel = _etaMins != null
        ? '${_etaMins!.round()} mins away'
        : (order.tripDurationMins != null
            ? '${order.tripDurationMins!.toStringAsFixed(0)} mins away'
            : null);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(activeTripVisibilityControllerProvider.notifier).hide();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: _buildMap(order)),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    _circleIconButton(
                      Icons.arrow_back_rounded,
                      () => ref.read(activeTripVisibilityControllerProvider.notifier).hide(),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp, color: Colors.black87),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    _circleIconButton(Icons.chat_bubble_outline_rounded, () => _openChat(order)),
                    SizedBox(width: 8.w),
                    _circleIconButton(Icons.report_problem_outlined, _showEmergencyHelp),
                    SizedBox(width: 8.w),
                    _circleIconButton(
                      Icons.refresh_rounded,
                      () {
                        ref.read(ordersControllerProvider.notifier).refreshCurrent();
                        _routeKey = null;
                        _maybeFetchRoute(order);
                      },
                    ),
                    SizedBox(width: 8.w),
                    _circleIconButton(
                      Icons.call_rounded,
                      () => _dial(isPickupPhase ? (order.restaurant.phone ?? '') : order.customerPhone),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16.w,
              bottom: 280.h,
              child: GestureDetector(
                onTap: () {
                  HapticService.light();
                  final pos = ref.read(locationServiceProvider).lastPosition;
                  if (pos != null && _mapController != null) {
                    _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)));
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Icon(Icons.my_location_rounded, color: Colors.black87, size: 22.sp),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: _buildBottomCard(theme, isDarkMode, textColor, subTextColor, order, etaLabel, isPickupPhase),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        onTap();
      },
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 20.sp),
      ),
    );
  }

  Widget _buildBottomCard(
    ThemeData theme,
    bool isDarkMode,
    Color textColor,
    Color? subTextColor,
    DeliveryOrder order,
    String? etaLabel,
    bool isPickupPhase,
  ) {
    final action = _actionFor(order);
    final name = isPickupPhase ? order.restaurant.name : order.customerName;
    final address = isPickupPhase ? order.restaurant.address : order.deliveryAddress.fullAddress;
    final destLat = isPickupPhase ? order.restaurant.location?.lat : order.deliveryAddress.location?.lat;
    final destLng = isPickupPhase ? order.restaurant.location?.lng : order.deliveryAddress.location?.lng;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    isPickupPhase ? 'Pick up' : 'Drop',
                    style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w800, fontSize: 11.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp, color: textColor)),
                      if (address.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(address, style: TextStyle(fontSize: 12.sp, color: subTextColor)),
                        ),
                      if (etaLabel != null)
                        Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_rounded, size: 14.sp, color: subTextColor),
                              SizedBox(width: 4.w),
                              Text(etaLabel, style: TextStyle(fontSize: 12.sp, color: subTextColor)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(height: 1, color: isDarkMode ? Colors.white12 : Colors.black12),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _dial(isPickupPhase ? (order.restaurant.phone ?? '') : order.customerPhone),
                    icon: Icon(Icons.call_outlined, size: 18.sp),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 44.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (destLat != null && destLng != null) {
                        MapLauncher.launchGoogleMaps(destLat, destLng);
                      } else {
                        _showSnack('Location not available');
                      }
                    },
                    icon: Icon(Icons.map_outlined, size: 18.sp),
                    label: const Text('Map'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 44.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: action?.action,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tripOnlineGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _tripOnlineGreen.withOpacity(0.4),
                  elevation: 0,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action?.icon ?? Icons.hourglass_empty_rounded, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      action?.label ?? 'Processing…',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
