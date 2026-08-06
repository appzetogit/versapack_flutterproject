import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../di/app_providers.dart';
import '../../../../navigation/route_paths.dart';
import '../../notifications/notifications_provider.dart';
import '../../profile/profile_home/profile_screen.dart';

/// The yellow brand plate at the top of Home: wordmark, notifications, wallet,
/// delivery address and the search entry point.
class AppzetoHeader extends ConsumerWidget {
  const AppzetoHeader({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(selectedAddressProvider);
    final unread = ref.watch(
      notificationsProvider.select((s) => s.unreadCount),
    );
    final wallet = ref.watch(walletProvider);

    return Container(
      color: context.semantic.brandSurface,
      padding: EdgeInsets.only(
        top: MediaQuery.viewPaddingOf(context).top + AppSpacing.sm,
        bottom: AppSpacing.lg,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                _IconTap(
                  icon: Icons.menu_rounded,
                  onTap: onMenuTap,
                  semanticLabel: 'Menu',
                ),
                const SizedBox(width: AppSpacing.md),
                const _Wordmark(),
                const Spacer(),
                _BellButton(
                  count: unread,
                  onTap: () => context.push(RoutePaths.notifications),
                ),
                const SizedBox(width: AppSpacing.sm),
                _WalletPill(
                  balance: wallet.valueOrNull?.balance ?? 0,
                  onTap: () => context.push(RoutePaths.profile),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: GestureDetector(
              onTap: () => context.push(RoutePaths.addresses),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: context.semantic.onBrandSurface,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      address == null
                          ? 'Set your delivery address'
                          : '${address.label.wireValue} - ${address.shortLine}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium!
                          .copyWith(color: context.semantic.onBrandSurface),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: context.semantic.onBrandSurface,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _SearchBar(onTap: () => context.push(RoutePaths.search)),
          ),
        ],
      ),
    );
  }
}

/// "appzeto" — black stem, green tail.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final base = context.text.headlineMedium!.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'app',
            style: base.copyWith(color: context.semantic.onBrandSurface),
          ),
          TextSpan(
            text: 'zeto',
            style: base.copyWith(color: context.colors.primary),
          ),
        ],
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Icon(icon, size: 26, color: context.semantic.onBrandSurface),
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppRadii.rMd,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 23,
              color: context.colors.onSurface,
            ),
          ),
          if (count > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 19),
                decoration: BoxDecoration(
                  color: context.semantic.danger,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: context.colors.surface, width: 1.6),
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: context.text.labelSmall!.copyWith(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WalletPill extends StatelessWidget {
  const _WalletPill({required this.balance, required this.onTap});

  final double balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadii.rMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 20,
              color: context.colors.onSurface,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(balance.asCurrency, style: context.text.price),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 19,
              color: context.semantic.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadii.rMd,
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 24,
              color: context.colors.onSurface,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Search for "milk, eggs, bread"',
                style: context.text.bodyLarge!
                    .copyWith(color: context.semantic.textSecondary),
              ),
            ),
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 24,
              color: context.semantic.accent,
            ),
          ],
        ),
      ),
    );
  }
}
