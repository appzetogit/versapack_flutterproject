import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_durations.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../di/app_providers.dart';
import '../common/widgets/misc/fly_to_cart.dart';

/// Bottom navigation for the five top-level destinations, with the delivery
/// promise raised into a centre badge that doubles as the cart entry point.
///
/// The badge carries [cartAnchorKey] so the fly-to-cart animation knows where
/// to land from anywhere in the app.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// The visual order differs from the router's branch order, so each item
  /// names its branch explicitly rather than relying on position.
  /// Router branches: 0 home · 1 categories · 2 cart · 3 orders · 4 profile.
  static const _cartBranchIndex = 2;

  static const _left = [
    (0, Icons.home_outlined, Icons.home_rounded, 'Home'),
    (3, Icons.replay_outlined, Icons.replay_rounded, 'Order Again'),
  ];

  static const _right = [
    (1, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Categories'),
    (4, Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    final current = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.semantic.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                for (final item in _left)
                  Expanded(
                    child: _NavItem(
                      spec: item,
                      selected: current == item.$1,
                      onTap: () => _go(item.$1),
                    ),
                  ),
                Expanded(
                  child: _CentreBadge(
                    count: cartCount,
                    onTap: () => _go(_cartBranchIndex),
                  ),
                ),
                for (final item in _right)
                  Expanded(
                    child: _NavItem(
                      spec: item,
                      selected: current == item.$1,
                      onTap: () => _go(item.$1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _go(int index) => navigationShell.goBranch(
        index,
        // Tapping the active tab pops it back to its root.
        initialLocation: index == navigationShell.currentIndex,
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  /// (branch index, unselected icon, selected icon, label)
  final (int, IconData, IconData, String) spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? context.colors.primary : context.semantic.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: spec.$4,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? spec.$3 : spec.$2, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              spec.$4,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall!.copyWith(color: color, fontWeight: selected ? FontWeight.w800 : FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// The raised disc: the delivery promise, and the cart's entry point.
class _CentreBadge extends StatelessWidget {
  const _CentreBadge({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: count > 0 ? 'Cart, $count items' : 'Cart',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -14),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  key: cartAnchorKey,
                  height: 62,
                  width: 62,
                  decoration: BoxDecoration(
                    color: context.semantic.brandSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.surface, width: 4.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '10\nmins',
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall!.copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w900),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(count),
                      tween: Tween(begin: 0.6, end: 1),
                      duration: AppDurations.medium,
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 1,
                        ),
                        constraints: const BoxConstraints(minWidth: 20),
                        decoration: BoxDecoration(
                          // A count badge is an alert, and it sits on the
                          // yellow brand disc — the brand colour would vanish
                          // into it.
                          color: context.semantic.danger,
                          borderRadius: AppRadii.rPill,
                          border: Border.all(
                            color: context.colors.surface,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: context.text.labelSmall!
                              .copyWith(color: context.colors.surface),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
