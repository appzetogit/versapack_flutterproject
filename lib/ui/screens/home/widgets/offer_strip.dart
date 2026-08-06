import 'package:flutter/material.dart';

import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/model/coupon.dart';

/// The three promo tiles under the hero. Built from live coupons, so what is
/// advertised here is a code the customer can actually apply.
class OfferStrip extends StatelessWidget {
  const OfferStrip({super.key, required this.coupons, required this.onTap});

  final List<Coupon> coupons;
  final ValueChanged<Coupon> onTap;

  @override
  Widget build(BuildContext context) {
    if (coupons.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 122,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: coupons.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return _OfferCard(
            coupon: coupon,
            icon: _iconFor(index),
            onTap: () => onTap(coupon),
          );
        },
      ),
    );
  }

  static IconData _iconFor(int index) => switch (index % 3) {
        0 => Icons.percent_rounded,
        1 => Icons.delivery_dining_rounded,
        _ => Icons.credit_card_rounded,
      };
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.coupon,
    required this.icon,
    required this.onTap,
  });

  final Coupon coupon;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 268,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadii.rLg,
          border: Border.all(color: context.semantic.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: context.semantic.brandSurface.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 21, color: context.colors.onSurface),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    coupon.minOrderValue > 0
                        ? 'on orders above ${coupon.minOrderValue.asCurrency}'
                        : 'on your order',
                    maxLines: 2,
                    style: context.text.bodySmall,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'ORDER NOW',
                        style: context.text.labelMedium!
                            .copyWith(color: context.colors.primary),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: context.colors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
