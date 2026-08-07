import 'package:flutter/material.dart';

import '../../../../core/extensions/num_extensions.dart';
import '../../../../domain/model/product.dart';
import '../../../common/widgets/loaders/shimmer_box.dart';
import '../../../common/widgets/misc/app_network_image.dart';
import '../../../common/widgets/misc/section_header.dart';

/// Bestsellers strip. Products are ranked from the live catalog by
/// `CatalogGroupingService`; ids are real, so the tap-through resolves.
class BestsellersRow extends StatelessWidget {
  const BestsellersRow({
    super.key,
    this.products = const [],
    this.isLoading = false,
    this.title = 'Bestsellers',
    this.onProductTap,
    this.onSeeAll,
    this.onAddTap,
  });

  final List<Product> products;
  final bool isLoading;
  final String title;
  final ValueChanged<String>? onProductTap;
  final VoidCallback? onSeeAll;
  final ValueChanged<Product>? onAddTap;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        SizedBox(
          height: 215,
          child: products.isEmpty
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, _) => const ShimmerBox(width: 140, height: 205),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () => onProductTap?.call(product.id),
                      child: _Card(product: product, onAddTap: onAddTap),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.product, this.onAddTap});

  final Product product;
  final ValueChanged<Product>? onAddTap;

  @override
  Widget build(BuildContext context) {
    final strike = product.strikePrice;
    final purchasable = product.isPurchasable;

    return Container(
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
          // Top image box with the yellow discount tag.
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
                clipBehavior: Clip.antiAlias,
                child: AppNetworkImage(
                  url: product.imageUrl,
                  fit: BoxFit.contain,
                  desaturated: !purchasable,
                ),
              ),
              if (product.isDiscounted)
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
                      '${product.discountPercent}% OFF',
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
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          Text(
            // Brand is optional upstream; the unit label always renders.
            product.brand.trim().isEmpty
                ? product.unitLabel
                : '${product.brand}\n${product.unitLabel}',
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.price.asCurrency,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    if (strike != null)
                      Text(
                        strike.asCurrency,
                        style: TextStyle(
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: purchasable ? () => onAddTap?.call(product) : null,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: purchasable
                        ? const Color(0xFF16A34A)
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: Colors.white,
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
