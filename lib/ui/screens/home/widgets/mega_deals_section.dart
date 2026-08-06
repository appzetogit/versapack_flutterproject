import 'package:flutter/material.dart';
import '../../../common/widgets/misc/app_network_image.dart';

class MegaDealsSection extends StatelessWidget {
  const MegaDealsSection({super.key, this.onShopNowTap, this.onItemTap});

  final VoidCallback? onShopNowTap;
  final ValueChanged<int>? onItemTap;

  static const _deals = [
    (
      name: 'Pampers',
      price: 599,
      strikePrice: 799,
      discount: '25% OFF',
      image: 'https://images.unsplash.com/photo-1519689680058-324335c77eba?w=400&q=80',
    ),
    (
      name: 'Surf Excel Matic',
      price: 189,
      strikePrice: 250,
      discount: '24% OFF',
      image: 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=400&q=80',
    ),
    (
      name: 'Tide Detergent',
      price: 199,
      strikePrice: 260,
      discount: '20% OFF',
      image: 'https://images.unsplash.com/photo-1610557892470-55d9e80c0bce?w=400&q=80',
    ),
    (
      name: 'Harpic Toilet Cleaner',
      price: 99,
      strikePrice: 125,
      discount: '20% OFF',
      image: 'https://images.unsplash.com/photo-1584813470613-5b1c1cad3d69?w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9E6), Color(0xFFFFF1C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE082), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Left Promo Callout
              SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MEGA DEALS',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Big savings on\ndaily essentials',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF333333),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Gift Box Graphic
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD400),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.card_giftcard_rounded, size: 30, color: Colors.black),
                          Positioned(
                            right: 3,
                            top: 3,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.black,
                              child: Text(
                                '%',
                                style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onShopNowTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Shop Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 11, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Right Deal Products List
              Expanded(
                child: SizedBox(
                  height: 142,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _deals.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = _deals[index];
                      return GestureDetector(
                        onTap: () => onItemTap?.call(index),
                        child: Container(
                          width: 98,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: AppNetworkImage(
                                      url: item.image,
                                      width: double.infinity,
                                      fallbackIcon: Icons.shopping_bag_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '₹${item.price}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '₹${item.strikePrice}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD400),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  item.discount,
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
