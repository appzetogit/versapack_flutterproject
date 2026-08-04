import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/app_providers.dart';
import '../widgets/feedback/app_snackbar.dart';

/// Gives a screen a single guard for actions that need the network.
///
/// Screens mix this in and wrap network-dependent taps in [guardOnline] so an
/// offline user gets an explanation instead of a spinner that never resolves.
mixin ConnectivityAwareMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool get isOffline => ref.read(isOfflineProvider);

  /// Runs [action] when online; otherwise shows why it did not.
  Future<void> guardOnline(
    Future<void> Function() action, {
    String message = 'You are offline. Reconnect and try again.',
  }) async {
    if (isOffline) {
      if (mounted) AppSnackbar.error(context, message);
      return;
    }
    await action();
  }
}
