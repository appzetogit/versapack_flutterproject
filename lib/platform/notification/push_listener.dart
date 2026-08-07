import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/repository_providers.dart';
import '../../navigation/app_router.dart';
import '../../navigation/route_paths.dart';
import '../../ui/common/widgets/feedback/app_snackbar.dart';
import '../../ui/screens/notifications/notifications_provider.dart';
import 'notification_service.dart';

/// Where a tapped notification should land.
///
/// A freshly-placed order opens its detail page; every later order push is a
/// status change, which the tracking screen is the right home for. Anything
/// without an order id falls back to the inbox.
String routeForPush(PushMessage message) {
  final orderId = message.orderId;
  if (orderId.isEmpty) return RoutePaths.notifications;
  return message.type == 'order_created'
      ? RoutePaths.orderDetailsOf(orderId)
      : RoutePaths.orderTrackingOf(orderId);
}

/// Reacts to pushes: refreshes the inbox, surfaces foreground messages in-app,
/// and routes taps to the screen the notification is about.
///
/// Wraps the router's child so a `ScaffoldMessenger` and a live route always
/// exist by the time a message arrives.
class PushListener extends ConsumerStatefulWidget {
  const PushListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushListener> createState() => _PushListenerState();
}

class _PushListenerState extends ConsumerState<PushListener> {
  final _subscriptions = <StreamSubscription<PushMessage>>[];

  @override
  void initState() {
    super.initState();
    final service = ref.read(notificationServiceProvider);

    _subscriptions.add(service.onForegroundMessage.listen(_onForeground));
    _subscriptions.add(service.onNotificationTap.listen(_openFor));

    // A cold start from a notification: the router is not mounted yet, so this
    // is deferred to the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initial = await service.initialMessage();
      if (initial != null) _openFor(initial);
    });
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _onForeground(PushMessage message) {
    // The inbox is the source of truth for the badge and the list; a push means
    // the server has something new for it.
    ref.invalidate(notificationsProvider);

    if (!mounted) return;
    final text = message.title.isEmpty ? message.body : message.title;
    if (text.isEmpty) return;

    AppSnackbar.show(
      context,
      text,
      actionLabel: 'VIEW',
      onAction: () => _openFor(message),
    );
  }

  void _openFor(PushMessage message) {
    ref.invalidate(notificationsProvider);
    ref.read(appRouterProvider).push(routeForPush(message));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
