import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../di/app_providers.dart';
import '../../../../domain/model/product.dart';
import '../../../common/cart_actions.dart';
import '../../../common/widgets/misc/app_network_image.dart';
import '../../../common/widgets/misc/quantity_stepper.dart';

/// Product card in the Appzeto style: discount ribbon top-left, artwork on a
/// white plate, then name / variant / pack size, price row, and a round add
/// button that morphs into a stepper once the item is in the cart.
class BestsellerCard extends ConsumerStatefulWidget {
  const BestsellerCard({
    super.key,
    required this.product,
    required this.onTap,
    this.width = 152,
    this.heroTag = 'bestseller',
  });

  final Product product;
  final VoidCallback onTap;
  final double width;
  final String heroTag;

  @override
  ConsumerState<BestsellerCard> createState() => _BestsellerCardState();
}

class _BestsellerCardState extends ConsumerState<BestsellerCard> {
  final _imageKey = GlobalKey();

  Product get _product => widget.product;

  @override
  Widget build(BuildContext context) {
    final quantity = ref.watch(
      cartProvider.select((s) => s.cart.quantityOf(_product.id)),
    );
    final outOfStock = _product.stockStatus == StockStatus.outOfStock;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadii.rLg,
          border: Border.all(color: context.semantic.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Hero(
                    tag: '${widget.heroTag}-${_product.id}',
                    child: AppNetworkImage(
                      key: _imageKey,
                      url: _product.imageUrl,
                      height: 108,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      desaturated: outOfStock,
                    ),
                  ),
                ),
                if (_product.discountPercent > 0)
                  Positioned(
                    left: 0,
                    top: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.semantic.brandSurface,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                      child: Text(
                        '${_product.discountPercent}% OFF',
                        style: context.text.badgeLabel
                            .copyWith(color: context.semantic.onBrandSurface),
                      ),
                    ),
                  ),
                if (outOfStock)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        color: context.colors.surface.withValues(alpha: 0.92),
                        child: Text(
                          'Out of stock',
                          style: context.text.badgeLabel
                              .copyWith(color: context.semantic.textSecondary),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _product.brand.isEmpty ? _product.name : _product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    _product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _product.unitLabel,
                    style: context.text.bodySmall!
                        .copyWith(color: context.semantic.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                _product.price.asCurrency,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.price
                                    .copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            if (_product.strikePrice != null) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _product.strikePrice!.asCurrency,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.mrp
                                      .copyWith(fontSize: 11),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _AddControl(
                        product: _product,
                        quantity: quantity,
                        enabled: !outOfStock && _product.sellerAcceptingOrders,
                        imageKey: _imageKey,
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

/// Round green "+" that becomes a compact stepper once in the cart.
class _AddControl extends ConsumerWidget {
  const _AddControl({
    required this.product,
    required this.quantity,
    required this.enabled,
    required this.imageKey,
  });

  final Product product;
  final int quantity;
  final bool enabled;
  final GlobalKey imageKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSize(
      duration: AppDurations.medium,
      curve: Curves.easeOutBack,
      alignment: Alignment.centerRight,
      child: quantity > 0
          ? QuantityStepper(
              quantity: quantity,
              height: 30,
              compact: true,
              canIncrement: quantity < product.maxOrderableQty,
              onIncrement: () => CartActions.increment(ref, product),
              onDecrement: () => CartActions.decrement(ref, product),
            )
          : Semantics(
              button: true,
              label: 'Add ${product.name} to cart',
              child: GestureDetector(
                onTap: enabled
                    ? () => CartActions.add(
                          context,
                          ref,
                          product: product,
                          sourceKey: imageKey,
                        )
                    : null,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: enabled
                        ? context.colors.primary
                        : context.semantic.border,
                    borderRadius: AppRadii.rSm,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }
}
