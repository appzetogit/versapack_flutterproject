import 'package:flutter/material.dart';

/// "20% OFF" flag on a product card. Rendered only when there is a discount.
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({super.key, required this.percent, this.compact = false});

  final int percent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (percent <= 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFD600),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Text(
        '$percent% OFF',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
