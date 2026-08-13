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
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Appzeto Logo | Notification Badge | Wallet Badge
          Row(
            children: [
              // Appzeto Logo
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'app',
                      style: context.text.displaySmall!.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1F2937),
                        fontSize: 32,
                        letterSpacing: -0.8,
                      ),
                    ),
                    TextSpan(
                      text: 'zeto',
                      style: context.text.displaySmall!.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF16A34A),
                        fontSize: 32,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Notification Bell Card
              GestureDetector(
                onTap: () => context.push(RoutePaths.notifications),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
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
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 19,
                        color: Color(0xFF1F2937),
                      ),
                      // No badge at zero — a count the inbox cannot back up
                      // sends the user to an empty screen.
                      if (unread > 0)
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: context.text.labelSmall!.copyWith(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Wallet Balance Card
              GestureDetector(
                onTap: () => context.push(RoutePaths.wallet),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
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
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                        color: Color(0xFF1F2937),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        (wallet.valueOrNull?.balance ?? 0).asCurrency,
                        style: context.text.titleSmall!.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
