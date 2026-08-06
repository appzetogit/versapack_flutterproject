import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../di/app_providers.dart';
import '../../../../domain/model/category.dart';
import '../../../../domain/model/product.dart';
import '../../../../domain/model/sub_category.dart';
import '../../../../navigation/route_paths.dart';
import '../../../common/cart_actions.dart';
import '../../../common/widgets/loaders/product_card_skeleton.dart';
import '../../../common/widgets/misc/app_network_image.dart';
import '../../../common/widgets/states/empty_state_widget.dart';
import '../../../common/widgets/states/error_state_widget.dart';
import '../../cart/widgets/cart_summary_bar.dart';
import 'sub_category_provider.dart';

class SubCategoryScreen extends ConsumerWidget {
  const SubCategoryScreen({super.key, required this.categoryId, this.category});

  final String categoryId;
  final Category? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subCategoryProvider(categoryId));
    final title = category?.name ?? 'Chips & Namkeen';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CartSummaryBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Top Quick-Commerce Header
            _buildHeader(context, title),

            // Horizontal Filter & Sort Chips Row
            _buildFilterBar(),

            // Main Body: Subcategory Rail on left, Product Grid on right
            Expanded(
              child: switch (state) {
                _ when state.failure != null && state.allProducts.isEmpty =>
                  ErrorStateWidget(
                    failure: state.failure!,
                    onRetry: () =>
                        ref.read(subCategoryProvider(categoryId).notifier).load(),
                  ),
                _ when state.isLoading && state.allProducts.isEmpty =>
                  const _LoadingLayout(),
                _ when state.isEmpty => EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: 'Nothing here yet',
                    message:
                        'We are still stocking this category near you. Try another one.',
                    actionLabel: 'All categories',
                    onAction: () => context.push(RoutePaths.categories),
                  ),
                _ => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Rail (SubCategories)
                      _SubCategoryRail(
                        categoryId: categoryId,
                        selectedId: state.selectedId,
                        items: state.subCategories,
                      ),

                      // Right Product Grid (2 Columns)
                      Expanded(
                        child: Container(
                          color: const Color(0xFFF9FAFB),
                          child: GridView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: state.visibleProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.505,
                            ),
                            itemBuilder: (context, index) {
                              final product = state.visibleProducts[index];
                              return _BrowseProductCard(
                                product: product,
                                isAd: index == 0,
                                heroTag: 'sub-$categoryId',
                                onTap: () => context.push(
                                  RoutePaths.productDetailsOf(product.id),
                                  extra: product,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String categoryTitle) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          // Back Button Circle
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 10),
          // Title & Delivery location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      "Delivering to : ",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C831F), // Zepto/Blinkit Green
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "New Palasia, Indore Divisi...",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A5568),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16, color: Colors.black54),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Search Circle Button
          InkWell(
            onTap: () => context.push(RoutePaths.search),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.search_rounded, size: 20, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 8),
          // Share Circle Button
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.ios_share_rounded, size: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'label': 'Filters', 'hasLeading': true, 'icon': Icons.tune_rounded},
      {'label': 'Sort', 'hasLeading': true, 'icon': Icons.swap_vert_rounded},
      {'label': 'Diet Preference', 'hasLeading': false},
      {'label': 'Brand', 'hasLeading': false},
      {'label': 'Price', 'hasLeading': false},
    ];

    return Container(
      height: 44,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filters[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item['hasLeading'] == true) ...[
                  Icon(item['icon'] as IconData, size: 14, color: Colors.black87),
                  const SizedBox(width: 4),
                ],
                Text(
                  item['label'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.black54),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SubCategoryRail extends ConsumerWidget {
  const _SubCategoryRail({
    required this.categoryId,
    required this.selectedId,
    required this.items,
  });

  final String categoryId;
  final String selectedId;
  final List<SubCategory> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 78,
      color: const Color(0xFFF7F8FA),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final sub = items[index];
          final selected = sub.id == selectedId || (selectedId == 'all' && index == 0);

          return GestureDetector(
            onTap: () =>
                ref.read(subCategoryProvider(categoryId).notifier).select(sub.id),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: selected ? const Color(0xFF0C831F) : const Color(0xFFEDF2F7),
                            width: selected ? 1.5 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF0C831F).withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: AppNetworkImage(
                            url: sub.imageUrl,
                            fit: BoxFit.cover,
                            fallbackIcon: Icons.grid_view_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          sub.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            height: 1.2,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? Colors.black : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Green indicator bar on the right side when selected
                if (selected)
                  Positioned(
                    top: 10,
                    bottom: 10,
                    right: 0,
                    width: 3.5,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF0C831F),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BrowseProductCard extends ConsumerStatefulWidget {
  const _BrowseProductCard({
    required this.product,
    required this.onTap,
    this.heroTag,
    this.isAd = false,
  });

  final Product product;
  final VoidCallback onTap;
  final String? heroTag;
  final bool isAd;

  @override
  ConsumerState<_BrowseProductCard> createState() => _BrowseProductCardState();
}

class _BrowseProductCardState extends ConsumerState<_BrowseProductCard> {
  final _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final quantity = ref.watch(cartProvider.select((s) => s.cart.quantityOf(product.id)));
    final isWishlisted = ref.watch(isWishlistedProvider(product.id));

    final hasDiscount = product.strikePrice != null && product.strikePrice! > product.price;
    final optionsText = product.hasVariants
        ? '${product.variants.length} options'
        : (product.unitLabel.contains('options') ? product.unitLabel : null);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEBEBEB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Stack Container
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 125,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppNetworkImage(
                      key: _imageKey,
                      url: product.imageUrl,
                      fit: BoxFit.contain,
                      fallbackIcon: Icons.fastfood_rounded,
                    ),
                  ),
                ),
                // Wishlist Heart (Top Right)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => CartActions.toggleWishlist(context, ref, product),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 15,
                        color: isWishlisted ? const Color(0xFFE53935) : const Color(0xFF757575),
                      ),
                    ),
                  ),
                ),
                // Ad Badge & Carousel Dots (Bottom Left)
                Positioned(
                  left: 4,
                  bottom: 6,
                  child: Row(
                    children: [
                      if (widget.isAd || product.id.contains('1')) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'Ad',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      // Carousel Dots Indicator
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 2.5),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 2.5),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Green Veg Icon (Bottom Right of Image)
                Positioned(
                  right: 4,
                  bottom: 6,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF0C831F), width: 1.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0C831F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                // ADD Button Overlay (Positioned at bottom-right of image)
                Positioned(
                  right: 2,
                  bottom: -10,
                  child: _buildAddButton(context, quantity, product, optionsText),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Unit / Weight
            Text(
              product.unitLabel,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF616161),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 3),

            // Price Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₹${product.price.toInt()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 4),
                  Text(
                    '₹${product.strikePrice!.toInt()}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9E9E9E),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),

            // Discount Badge (e.g., "5% OFF on MRP")
            if (product.discountPercent > 0)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  '${product.discountPercent}% OFF on MRP',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0), // Vivid Blue
                  ),
                ),
              ),

            const SizedBox(height: 3),

            // Product Name
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
                height: 1.25,
              ),
            ),

            const SizedBox(height: 4),

            // Ratings & Order Count
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB300)),
                const SizedBox(width: 2),
                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB300)),
                const SizedBox(width: 2),
                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB300)),
                const SizedBox(width: 2),
                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB300)),
                const SizedBox(width: 2),
                const Icon(Icons.star_half_rounded, size: 13, color: Color(0xFFFFB300)),
                const SizedBox(width: 4),
                Text(
                  _formatRatingCount(product.ratingCount),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 3),

            // Delivery Time Row
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF616161)),
                const SizedBox(width: 3),
                Text(
                  '${product.deliveryMinutes ?? 11} mins',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatRatingCount(int count) {
    if (count >= 100000) {
      return '${(count / 100000).toStringAsFixed(1)} lac';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count > 0 ? '$count' : '1.8 lac';
  }

  Widget _buildAddButton(
    BuildContext context,
    int quantity,
    Product product,
    String? optionsText,
  ) {
    if (quantity == 0) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CartActions.add(
            context,
            ref,
            product: product,
            sourceKey: _imageKey,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 66,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0C831F), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ADD',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0C831F),
                    letterSpacing: 0.3,
                  ),
                ),
                if (optionsText != null)
                  Text(
                    optionsText,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: 66,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF0C831F),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C831F).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => CartActions.decrement(ref, product),
            child: const Icon(Icons.remove, size: 14, color: Colors.white),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => CartActions.increment(ref, product),
            child: const Icon(Icons.add, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _LoadingLayout extends StatelessWidget {
  const _LoadingLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 78, color: const Color(0xFFF7F8FA)),
        const Expanded(child: ProductGridSkeleton(count: 6)),
      ],
    );
  }
}

