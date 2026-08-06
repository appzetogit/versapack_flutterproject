import 'package:flutter/material.dart';

import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/model/product.dart';
import '../../../common/widgets/misc/app_network_image.dart';

/// The tinted "MEGA DEALS" rail: a pitch panel pinned left, then the deepest
/// discounts scrolling beside it.
class MegaDealsBanner extends StatelessWidget {
  const MegaDealsBanner({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onShopAll,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final VoidCallback onShopAll;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.semantic.brandSurfaceSoft,
        borderRadius: AppRadii.rLg,
      ),
      child: SizedBox(
        height: 168,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Pitch(onShopAll: onShopAll),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) => _DealTile(
                  product: products[index],
                  onTap: () => onProductTap(products[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch({required this.onShopAll});

  final VoidCallback onShopAll;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MEGA DEALS',
            style: context.text.titleMedium!
                .copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.2),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Big savings on daily essentials',
            style: context.text.bodySmall!
                .copyWith(color: context.semantic.onBrandSurface),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onShopAll,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.colors.onSurface,
                borderRadius: AppRadii.rPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shop Now',
                    style: context.text.labelMedium!
                        .copyWith(color: context.colors.surface),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: context.colors.surface,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DealTile extends StatelessWidget {
  const _DealTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadii.rMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(
              url: product.imageUrl,
              height: 62,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium,
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    product.price.asCurrency,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall!
                        .copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                if (product.strikePrice != null) ...[
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      product.strikePrice!.asCurrency,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.mrp.copyWith(fontSize: 9.5),
                    ),
                  ),
                ],
              ],
            ),
            if (product.discountPercent > 0) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: context.semantic.brandSurface,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '${product.discountPercent}% OFF',
                  style: context.text.labelSmall!.copyWith(
                    fontSize: 8,
                    color: context.semantic.onBrandSurface,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
