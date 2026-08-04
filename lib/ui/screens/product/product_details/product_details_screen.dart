import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../di/app_providers.dart';
import '../../../../di/repository_providers.dart';
import '../../../../di/service_providers.dart';
import '../../../../domain/model/coupon.dart';
import '../../../../domain/model/product.dart';
import '../../../../navigation/route_paths.dart';
import '../../../common/cart_actions.dart';
import '../../../common/widgets/badges/delivery_time_badge.dart';
import '../../../common/widgets/badges/discount_badge.dart';
import '../../../common/widgets/buttons/icon_button_circle.dart';
import '../../../common/widgets/buttons/primary_button.dart';
import '../../../common/widgets/feedback/app_snackbar.dart';
import '../../../common/widgets/loaders/full_page_loader.dart';
import '../../../common/widgets/misc/quantity_stepper.dart';
import '../../../common/widgets/misc/rating_stars.dart';
import '../../../common/widgets/misc/section_header.dart';
import '../../../common/widgets/states/error_state_widget.dart';
import '../../home/widgets/product_row.dart';
import 'product_details_provider.dart';
import 'product_details_state.dart';
import 'widgets/product_image_carousel.dart';
import 'widgets/product_info_tabs.dart';
import 'widgets/reviews_section.dart';
import 'widgets/write_review_sheet.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.product,
    this.heroTag,
  });

  final String productId;
  final Product? product;
  final String? heroTag;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  late final ProductDetailsArgs _args = ProductDetailsArgs(
    productId: widget.productId,
    product: widget.product,
  );

  final _imageKey = GlobalKey();

  Future<void> _addToCart(ProductDetailsState state) async {
    final product = state.product;
    if (product == null) return;

    await CartActions.add(
      context,
      ref,
      product: product,
      variant: state.selectedVariant,
      addons: state.selectedAddons,
      quantity: state.quantity,
      sourceKey: _imageKey,
      // Add-ons are chosen inline on this screen, so do not re-prompt.
      askForAddons: false,
    );
  }

  Future<void> _writeReview(ProductDetailsState state) async {
    final product = state.product;
    if (product == null) return;

    final draft = await WriteReviewSheet.show(
      context,
      productName: product.name,
      orders: state.rateableOrders,
    );
    if (draft == null || !mounted) return;

    try {
      await ref.read(productDetailsProvider(_args).notifier).submitReview(
            orderId: draft.orderId,
            rating: draft.rating,
            comment: draft.comment,
          );
      if (mounted) AppSnackbar.success(context, 'Thanks for your review');
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Could not submit your review');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailsProvider(_args));

    if (state.isLoading && state.product == null) {
      return const Scaffold(body: FullPageLoader(message: 'Loading product…'));
    }

    final product = state.product;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorStateWidget(
          failure: state.failure ??
              const NotFoundFailure('We could not load this product right now.'),
          onRetry: () => ref.read(productDetailsProvider(_args).notifier).load(),
        ),
      );
    }

    final inCartQuantity =
        ref.watch(cartProvider.select((s) => s.cart.quantityOf(product.id)));

    return Scaffold(
      bottomNavigationBar: _StickyAddBar(
        state: state,
        inCartQuantity: inCartQuantity,
        onAdd: () => _addToCart(state),
        onViewCart: () => context.push(RoutePaths.cart),
      ),
      body: CustomScrollView(
        slivers: [
          _appBar(context, product, state),
          SliverToBoxAdapter(child: _header(context, product, state)),
          SliverToBoxAdapter(child: _variants(context, state)),
          SliverToBoxAdapter(child: _addons(context, state)),
          SliverToBoxAdapter(child: _deliveryAndOffers(context, product)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ProductInfoTabs(product: product),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Ratings & reviews'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: ReviewsSection(
                    summary: state.ratingSummary,
                    reviews: state.reviews,
                    canWrite: state.canRate,
                    onWrite: () => _writeReview(state),
                  ),
                ),
              ],
            ),
          ),
          if (state.related.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'You may also like'),
                  ProductRow(
                    products: state.related,
                    heroTag: 'related-${product.id}',
                    onProductTap: (p) => context.push(
                      RoutePaths.productDetailsOf(p.id),
                      extra: p,
                    ),
                  ),
                ],
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _appBar(
    BuildContext context,
    Product product,
    ProductDetailsState state,
  ) {
    final isWishlisted = ref.watch(isWishlistedProvider(product.id));

    return SliverAppBar(
      pinned: true,
      expandedHeight: 360,
      backgroundColor: context.colors.surface,
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: IconButtonCircle(
          icon: Icons.arrow_back_rounded,
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
      ),
      actions: [
        IconButtonCircle(
          icon: isWishlisted
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          foreground: isWishlisted ? context.semantic.danger : null,
          tooltip: 'Save',
          onPressed: () => CartActions.toggleWishlist(context, ref, product),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButtonCircle(
          icon: Icons.ios_share_rounded,
          tooltip: 'Share',
          onPressed: () => Share.share(
            '${product.name} on Suvio Quick — ${product.price.asCurrency}\n'
            'suvio://product/${product.id}',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          key: _imageKey,
          color: context.colors.surface,
          padding: const EdgeInsets.only(top: 60, bottom: AppSpacing.lg),
          child: ProductImageCarousel(
            images: product.gallery,
            heroTag: '${widget.heroTag ?? 'product'}-${product.id}',
            height: 250,
            desaturated: !product.isPurchasable,
          ),
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    Product product,
    ProductDetailsState state,
  ) {
    final stockLabel = ref.watch(stockServiceProvider).stockLabel(product);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VegIndicator(isVeg: product.isVeg),
              const SizedBox(width: AppSpacing.sm),
              if (product.brand.isNotEmpty)
                Text(
                  product.brand.toUpperCase(),
                  style: context.text.labelSmall!
                      .copyWith(color: context.semantic.textSecondary),
                ),
              const Spacer(),
              if (product.rating > 0)
                RatingStars(rating: product.rating, count: product.ratingCount),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(product.name, style: context.text.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            state.selectedVariant?.name ?? product.unitLabel,
            style: context.text.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                state.effectiveUnitPrice.asCurrency,
                style: context.text.displaySmall,
              ),
              const SizedBox(width: AppSpacing.md),
              if (state.effectiveStrikePrice != null) ...[
                Text(
                  state.effectiveStrikePrice!.asCurrency,
                  style: context.text.mrp.copyWith(fontSize: 15),
                ),
                const SizedBox(width: AppSpacing.md),
                DiscountBadge(
                  percent: state.effectiveUnitPrice
                      .discountPercentFrom(state.effectiveStrikePrice),
                ),
              ],
            ],
          ),
          Text('Inclusive of all taxes', style: context.text.bodySmall),
          if (stockLabel.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: product.isPurchasable
                    ? context.semantic.warningSoft
                    : context.semantic.dangerSoft,
                borderRadius: AppRadii.rSm,
              ),
              child: Text(
                stockLabel,
                style: context.text.labelMedium!.copyWith(
                  color: product.isPurchasable
                      ? context.semantic.warning
                      : context.semantic.danger,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _variants(BuildContext context, ProductDetailsState state) {
    final product = state.product!;
    if (!product.hasVariants) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Choose a pack'),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: product.variants.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final variant = product.variants[index];
              final selected = state.selectedVariant?.id == variant.id;

              return GestureDetector(
                onTap: () => ref
                    .read(productDetailsProvider(_args).notifier)
                    .selectVariant(variant),
                child: Container(
                  width: 118,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: selected
                        ? context.colors.primary.withValues(alpha: 0.08)
                        : context.colors.surface,
                    borderRadius: AppRadii.rMd,
                    border: Border.all(
                      color: selected
                          ? context.colors.primary
                          : context.semantic.border,
                      width: selected ? 1.6 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        variant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(variant.price.asCurrency, style: context.text.price),
                      if (variant.isDiscounted)
                        Text(
                          variant.comparePrice!.asCurrency,
                          style: context.text.mrp.copyWith(fontSize: 10.5),
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

  Widget _addons(BuildContext context, ProductDetailsState state) {
    if (state.addonGroups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Add extras',
          subtitle: 'Optional add-ons for this item',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              for (final group in state.addonGroups)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: AppRadii.rLg,
                    border: Border.all(color: context.semantic.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name.isEmpty ? 'Extras' : group.name,
                        style: context.text.titleMedium,
                      ),
                      if (group.selectionLabel.isNotEmpty)
                        Text(group.selectionLabel, style: context.text.bodySmall),
                      const SizedBox(height: AppSpacing.sm),
                      for (final addon in group.options)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: state.selectedAddons.any((a) => a.id == addon.id),
                          onChanged: (_) => ref
                              .read(productDetailsProvider(_args).notifier)
                              .toggleAddon(group, addon),
                          title: Text(addon.name, style: context.text.bodyLarge),
                          secondary: Text(
                            '+ ${addon.price.asCurrency}',
                            style: context.text.titleSmall,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deliveryAndOffers(BuildContext context, Product product) {
    final address = ref.watch(selectedAddressProvider);
    final coupons = ref.watch(_productCouponsProvider(product.sellerId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.semantic.surfaceAlt,
              borderRadius: AppRadii.rLg,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delivery_dining_rounded,
                  size: 20,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivered in ~${product.deliveryMinutes ?? 10} mins',
                        style: context.text.titleSmall,
                      ),
                      Text(
                        address?.shortLine ?? 'Add an address for an exact time',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          coupons.maybeWhen(
            data: (list) => list.isEmpty
                ? const SizedBox.shrink()
                : _OfferTeaser(coupon: list.first),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Offers valid at this product's seller, for the "use CODE to save" teaser.
final _productCouponsProvider =
    FutureProvider.family<List<Coupon>, String>((ref, sellerId) async {
  if (sellerId.isEmpty) return const [];
  try {
    return await ref.watch(couponRepositoryProvider).available(sellerId: sellerId);
  } catch (_) {
    return const [];
  }
});

class _OfferTeaser extends StatelessWidget {
  const _OfferTeaser({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.semantic.successSoft,
        borderRadius: AppRadii.rLg,
        border: Border.all(color: context.semantic.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_rounded,
            size: 18,
            color: context.semantic.success,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use ${coupon.code} — ${coupon.title}',
                  style: context.text.titleSmall!
                      .copyWith(color: context.semantic.success),
                ),
                if (coupon.minOrderValue > 0)
                  Text(
                    'On orders above ${coupon.minOrderValue.asCurrency}',
                    style: context.text.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom bar: quantity, live line price, and add/view-cart.
class _StickyAddBar extends ConsumerWidget {
  const _StickyAddBar({
    required this.state,
    required this.inCartQuantity,
    required this.onAdd,
    required this.onViewCart,
  });

  final ProductDetailsState state;
  final int inCartQuantity;
  final VoidCallback onAdd;
  final VoidCallback onViewCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = state.product;
    if (product == null) return const SizedBox.shrink();

    final purchasable = product.isPurchasable && product.sellerAcceptingOrders;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.semantic.border)),
      ),
      child: Row(
        children: [
          if (purchasable) ...[
            QuantityStepper(
              quantity: state.quantity,
              height: 44,
              canIncrement: state.quantity < product.maxOrderableQty,
              onIncrement: () => ref
                  .read(productDetailsProvider(
                    ProductDetailsArgs(productId: product.id, product: product),
                  ).notifier)
                  .setQuantity(state.quantity + 1),
              onDecrement: () => ref
                  .read(productDetailsProvider(
                    ProductDetailsArgs(productId: product.id, product: product),
                  ).notifier)
                  .setQuantity(state.quantity - 1),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: PrimaryButton(
              label: !purchasable
                  ? 'Out of stock'
                  : inCartQuantity > 0
                      ? 'View cart'
                      : 'Add ${state.totalPrice.asCurrency}',
              icon: purchasable && inCartQuantity == 0
                  ? Icons.add_shopping_cart_rounded
                  : null,
              onPressed: !purchasable
                  ? null
                  : inCartQuantity > 0
                      ? onViewCart
                      : onAdd,
            ),
          ),
        ],
      ),
    );
  }
}
