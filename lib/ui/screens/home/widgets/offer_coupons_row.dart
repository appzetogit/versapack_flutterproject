import 'package:flutter/material.dart';

class OfferCouponsRow extends StatelessWidget {
  const OfferCouponsRow({super.key, this.onOrderNowTap});

  final ValueChanged<int>? onOrderNowTap;

  static const _offers = [
    (
      icon: Icons.percent_rounded,
      iconBg: Color(0xFFFFD400),
      title: 'FLAT ₹50 OFF',
      subtitle: 'on your first order\nabove ₹249',
    ),
    (
      icon: Icons.two_wheeler_rounded,
      iconBg: Color(0xFFFFF1C5),
      title: 'FREE DELIVERY',
      subtitle: 'on all orders\nabove ₹199',
    ),
    (
      icon: Icons.credit_card_rounded,
      iconBg: Color(0xFFFFE082),
      title: 'EXTRA 5% OFF',
      subtitle: 'on online\npayments',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _offers.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => onOrderNowTap?.call(i),
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
                      // Icon Badge Plate
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF3B3),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: i == 0
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
                                _offers[i].icon,
                                size: 18,
                                color: i == 1 ? const Color(0xFF16A34A) : Colors.black,
                              ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _offers[i].title,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _offers[i].subtitle,
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                          height: 1.15,
                        ),
                      ),
                      const Spacer(),
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
              ),
            ),
          ],
        ],
      ),
    );
  }
}
