import 'package:flutter/material.dart';

import '../../../../core/extensions/num_extensions.dart';
import '../../../../domain/model/coupon.dart';
import '../../../common/widgets/loaders/shimmer_box.dart';

/// The three offer cards under the hero banner, built from live offers.
class OfferCouponsRow extends StatelessWidget {
  const OfferCouponsRow({
    super.key,
    this.coupons = const [],
    this.isLoading = false,
    this.onOfferTap,
  });

  final List<Coupon> coupons;
  final bool isLoading;
  final ValueChanged<Coupon>? onOfferTap;

  /// The row is a fixed three-up grid.
  static const _slots = 3;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && coupons.isEmpty) return const SizedBox.shrink();

    final shown = coupons.take(_slots).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < (shown.isEmpty ? _slots : shown.length); i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: shown.isEmpty
                  ? const ShimmerBox(height: 108)
                  : _OfferCard(
                      coupon: shown[i],
                      index: i,
                      onTap: onOfferTap,
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.coupon, required this.index, this.onTap});

  final Coupon coupon;

  /// Only drives the decorative icon treatment, matching the original design.
  final int index;
  final ValueChanged<Coupon>? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(coupon),
      child: Container(
        height: 108,
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3B3),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: coupon.discountType == DiscountType.percentage
                  ? Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD400),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : Icon(
                      index == 1
                          ? Icons.two_wheeler_rounded
                          : Icons.credit_card_rounded,
                      size: 18,
                      color: index == 1
                          ? const Color(0xFF16A34A)
                          : Colors.black,
                    ),
            ),
            const SizedBox(height: 5),
            Text(
              _headline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                _subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                  height: 1.15,
                ),
              ),
            ),
            const Row(
              children: [
                Text(
                  'ORDER NOW',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF16A34A),
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 10,
                  color: Color(0xFF16A34A),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _headline => switch (coupon.discountType) {
        DiscountType.percentage =>
          '${coupon.discountValue.toStringAsFixed(0)}% OFF',
        DiscountType.flat => 'FLAT ${coupon.discountValue.asCurrency} OFF',
      };

  String get _subtitle {
    if (coupon.minOrderValue > 0) {
      return 'on orders above\n${coupon.minOrderValue.asCurrency}';
    }
    return coupon.title.trim().isEmpty ? 'Use code ${coupon.code}' : coupon.title;
  }
}
