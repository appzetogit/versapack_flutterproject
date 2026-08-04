import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../di/app_providers.dart';
import '../../../../navigation/route_paths.dart';
import '../../../common/widgets/buttons/icon_button_circle.dart';

/// Pinned header: delivery promise, current address and quick actions.
class DeliveryHeader extends ConsumerWidget {
  const DeliveryHeader({super.key, required this.etaMinutes});

  final int etaMinutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(selectedAddressProvider);
    final user = ref.watch(authProvider).user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(RoutePaths.addresses),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 17,
                        color: context.semantic.accent,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Delivery in $etaMinutes mins',
                        style: context.text.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          address?.shortLine ?? 'Set your delivery address',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: context.semantic.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          IconButtonCircle(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            onPressed: () => context.push(RoutePaths.notifications),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () => context.push(RoutePaths.profile),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: context.colors.primary.withValues(alpha: 0.12),
              child: Text(
                (user?.displayName ?? 'S').substring(0, 1).toUpperCase(),
                style: context.text.titleMedium!
                    .copyWith(color: context.colors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
