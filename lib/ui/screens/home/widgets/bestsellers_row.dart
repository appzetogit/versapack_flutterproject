import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/route_paths.dart';
import '../../../common/widgets/misc/section_header.dart';

class BestsellersRow extends StatelessWidget {
  const BestsellersRow({super.key, this.onProductTap});

  final ValueChanged<String>? onProductTap;

  static const _products = [
    (
      id: 'p1',
      title: 'Amul Gold',
      subtitle: 'Full Cream Milk',
      weight: '1 L',
      price: 64,
      strikePrice: 80,
      discount: '20% OFF',
      assetPath: 'assets/images/prod_amul_gold.png',
      imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&q=80',
      icon: Icons.local_drink_rounded,
    ),
    (
      id: 'p2',
      title: 'Aashirvaad Atta',
      subtitle: 'Whole Wheat Atta',
      weight: '5 kg',
      price: 249,
      strikePrice: 300,
      discount: '17% OFF',
      assetPath: 'assets/images/prod_aashirvaad_atta.png',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80',
      icon: Icons.grain_rounded,
    ),
    (
      id: 'p3',
      title: "Lay's Classic",
      subtitle: 'Salted',
      weight: '52 g',
      price: 20,
      strikePrice: 25,
      discount: '22% OFF',
      assetPath: 'assets/images/prod_lays_classic.png',
      imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&q=80',
      icon: Icons.fastfood_rounded,
    ),
    (
      id: 'p4',
      title: 'Fortune Sunlite',
      subtitle: 'Refined Oil',
      weight: '1 L',
      price: 120,
      strikePrice: 142,
      discount: '15% OFF',
      assetPath: 'assets/images/prod_fortune_oil.png',
      imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&q=80',
      icon: Icons.opacity_rounded,
    ),
    (
      id: 'p5',
      title: 'Coca Cola',
      subtitle: 'Soft Drink',
      weight: '750 ml',
      price: 40,
      strikePrice: 49,
      discount: '18% OFF',
      assetPath: 'assets/images/prod_coca_cola.png',
      imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400&q=80',
      icon: Icons.liquor_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Bestsellers',
          onSeeAll: () => context.push(RoutePaths.productListing),
        ),
        SizedBox(
          height: 215,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = _products[index];
              return GestureDetector(
                onTap: () => onProductTap?.call(product.id),
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(9),
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
                      // Top Image Box with Yellow Discount Tag
                      Stack(
                        children: [
                          Container(
                            height: 96,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              product.assetPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD400),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                product.discount,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${product.subtitle}\n${product.weight}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          height: 1.1,
                        ),
                      ),
                      const Spacer(),
                      // Price row + Green Add Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${product.price}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '₹${product.strikePrice}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
