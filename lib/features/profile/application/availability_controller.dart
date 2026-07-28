import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/error/result.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/socket_service.dart';
import '../../auth/application/auth_state.dart';
import '../../auth/application/auth_controller.dart';
import '../../orders/application/orders_controller.dart';
import '../../orders/application/orders_state.dart';
import '../data/profile_repository.dart';

class AvailabilityController extends Notifier<bool> {
  late final ProfileRepository _repository;
  StreamSubscription<Position>? _positionSub;
  Timer? _keepAliveTimer;
  DateTime _lastPing = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  bool build() {
    _repository = ref.read(profileRepositoryProvider);
    final authState = ref.read(authControllerProvider);
    final startedOnline = authState is AuthAuthenticated && authState.user.isOnline;

    ref.onDispose(() {
      _positionSub?.cancel();
      _keepAliveTimer?.cancel();
    });

    if (startedOnline) {
      Future.microtask(() {
        _startTracking();
        ref.read(ordersControllerProvider.notifier).startPolling();
      });
    }
    return startedOnline;
  }

  Future<Result<void, AppError>> toggle() async {
    if (state) {
      return goOffline();
    }
    return goOnline();
  }

  Future<Result<void, AppError>> goOnline() async {
    final locationService = ref.read(locationServiceProvider);
    final hasPermission = await locationService.ensurePermissions();
    if (!hasPermission) {
      return Result.failure(
        NetworkError('Location permission is required to go online'),
      );
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition();
      locationService.lastPosition = position;
    } catch (_) {
      // fall through — the availability ping will pick up the next fix
    }

    final result = await _repository.updateAvailability(
      true,
      lat: position?.latitude,
      lng: position?.longitude,
    );
    return result.when(
      success: (_) {
        state = true;
        ref.read(ordersControllerProvider.notifier).startPolling();
        _startTracking();
        return const Result.success(null);
      },
      failure: (error) => Result.failure(error),
    );
  }

  Future<Result<void, AppError>> goOffline() async {
    final result = await _repository.updateAvailability(false);
    _stopTracking();
    ref.read(ordersControllerProvider.notifier).stopPolling();
    state = false;
    return result.when(
      success: (_) => const Result.success(null),
      failure: (error) => Result.failure(error),
    );
  }

  void _startTracking() {
    final locationService = ref.read(locationServiceProvider);
    locationService.startTracking();
    _positionSub?.cancel();
    _positionSub = locationService.positionStream.listen(_onPosition);

    // The position stream only emits on movement (distanceFilter), so a
    // stationary rider would otherwise never refresh lastLocationAt and
    // silently drop out of dispatch once the backend's GPS staleness
    // window (10 min) elapses. Ping on a timer too, independent of movement.
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      final pos = ref.read(locationServiceProvider).lastPosition;
      if (pos == null) return;
      _lastPing = DateTime.now();
      _repository.updateAvailability(true, lat: pos.latitude, lng: pos.longitude);
    });
  }

  void _stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    ref.read(locationServiceProvider).stopTracking();
  }

  void _onPosition(Position position) {
    final now = DateTime.now();
    if (now.difference(_lastPing) < const Duration(seconds: 4)) return;
    _lastPing = now;

    _repository.updateAvailability(
      true,
      lat: position.latitude,
      lng: position.longitude,
    );

    final ordersState = ref.read(ordersControllerProvider);
    if (ordersState is OrdersLoaded && ordersState.currentOrder != null) {
      ref.read(socketServiceProvider).sendLocationUpdate(
        orderId: ordersState.currentOrder!.id,
        lat: position.latitude,
        lng: position.longitude,
        heading: position.heading,
        speed: position.speed,
        accuracy: position.accuracy,
      );
    }
  }
}

final availabilityControllerProvider =
    NotifierProvider<AvailabilityController, bool>(AvailabilityController.new);
