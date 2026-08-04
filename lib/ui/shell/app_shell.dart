import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';
import '../../di/app_providers.dart';
import '../../navigation/route_paths.dart';
import '../common/widgets/misc/fly_to_cart.dart';

/// Bottom-navigation shell for the five top-level destinations.
///
/// The cart tab's icon carries [cartAnchorKey] so the fly-to-cart animation
/// knows where to land from anywhere in the app.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (RoutePaths.home, Icons.home_outlined, Icons.home_rounded, 'Home'),
    (
      RoutePaths.categories,
      Icons.grid_view_outlined,
      Icons.grid_view_rounded,
      'Categories'
    ),
    (
      RoutePaths.cart,
      Icons.shopping_cart_outlined,
      Icons.shopping_cart_rounded,
      'Cart'
    ),
    (
      RoutePaths.orders,
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
      'Orders'
    ),
    (RoutePaths.profile, Icons.person_outline_rounded, Icons.person_rounded, 'You'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab pops it back to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (var i = 0; i < _destinations.length; i++)
            NavigationDestination(
              icon: _icon(context, i, selected: false, cartCount: cartCount),
              selectedIcon:
                  _icon(context, i, selected: true, cartCount: cartCount),
              label: _destinations[i].$4,
            ),
        ],
      ),
    );
  }

  Widget _icon(
    BuildContext context,
    int index, {
    required bool selected,
    required int cartCount,
  }) {
    final destination = _destinations[index];
    final isCart = destination.$1 == RoutePaths.cart;

    final icon = Icon(
      selected ? destination.$3 : destination.$2,
      key: isCart ? (selected ? null : cartAnchorKey) : null,
    );

    if (!isCart || cartCount == 0) return icon;

    return Badge(
      backgroundColor: context.semantic.accent,
      textColor: Colors.black,
      label: TweenAnimationBuilder<double>(
        key: ValueKey(cartCount),
        tween: Tween(begin: 0.6, end: 1),
        duration: AppDurations.medium,
        curve: Curves.elasticOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Text('$cartCount'),
      ),
      child: icon,
    );
  }
}
