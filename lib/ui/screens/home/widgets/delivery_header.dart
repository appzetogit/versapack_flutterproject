import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_extensions.dart';
import '../../../../di/app_providers.dart';
import '../../../../navigation/route_paths.dart';
import '../../notifications/notifications_provider.dart';
import '../../profile/profile_home/profile_screen.dart';
import '../../../../core/theme/app_theme.dart';

/// Pinned header: delivery promise, current address and quick actions.
class DeliveryHeader extends ConsumerWidget {
  const DeliveryHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(selectedAddressProvider);
    final unread = ref.watch(notificationsProvider.select((s) => s.unreadCount));
    final wallet = ref.watch(walletProvider);

    return Container(
      color: context.semantic.brandSurface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Menu | Appzeto Logo | Notification Badge | Wallet Badge
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => context.go(RoutePaths.profile),
                tooltip: 'Menu',
                icon: Icon(
                  Icons.menu_rounded,
                  size: 28,
                  color: context.semantic.onBrandSurface,
                ),
              ),
              const SizedBox(width: 12),
              // Appzeto Logo
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'app',
                      style: context.text.displaySmall!.copyWith(fontWeight: FontWeight.w900, color: context.semantic.onBrandSurface),
                    ),
                    TextSpan(
                      text: 'zeto',
                      style: context.text.displaySmall!.copyWith(fontWeight: FontWeight.w900, color: context.semantic.success),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Notification Bell Card
              GestureDetector(
                onTap: () => context.push(RoutePaths.notifications),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                        color: context.semantic.onBrandSurface,
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: context.text.labelSmall!.copyWith(color: context.colors.surface, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Wallet Balance Card
              GestureDetector(
                onTap: () => context.go(RoutePaths.profile),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 18,
                        color: context.colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (wallet.valueOrNull?.balance ?? 0).asCurrency,
                        style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w800, color: context.semantic.onBrandSurface),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: context.semantic.onBrandSurface,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Location Row
          GestureDetector(
            onTap: () => context.push(RoutePaths.addresses),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: context.semantic.onBrandSurface,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    address == null
                        ? 'Set your delivery address'
                        : '${address.label.wireValue} - ${address.shortLine}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w700, color: context.semantic.onBrandSurface),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: context.semantic.onBrandSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
