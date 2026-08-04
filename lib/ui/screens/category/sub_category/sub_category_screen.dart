import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/model/category.dart';
import '../../../../navigation/route_paths.dart';
import '../../../common/widgets/cards/product_card.dart';
import '../../../common/widgets/loaders/product_card_skeleton.dart';
import '../../../common/widgets/misc/app_network_image.dart';
import '../../../common/widgets/states/empty_state_widget.dart';
import '../../../common/widgets/states/error_state_widget.dart';
import '../../cart/widgets/cart_summary_bar.dart';
import 'sub_category_provider.dart';

/// Rail on the left, product grid on the right — the quick-commerce standard,
/// so switching sub-categories never costs a screen transition.
class SubCategoryScreen extends ConsumerWidget {
  const SubCategoryScreen({super.key, required this.categoryId, this.category});

  final String categoryId;
  final Category? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(category?.name ?? 'Browse'),
        actions: [
          IconButton(
            onPressed: () => context.push(RoutePaths.search),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
          ),
        ],
      ),
      bottomNavigationBar: const CartSummaryBar(),
      body: SafeArea(
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
              children: [
                _SubCategoryRail(
                  categoryId: categoryId,
                  selectedId: state.selectedId,
                  items: state.subCategories,
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.visibleProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, index) {
                      final product = state.visibleProducts[index];
                      return ProductCard(
                        product: product,
                        width: double.infinity,
                        heroTag: 'sub-$categoryId',
                        onTap: () => context.push(
                          RoutePaths.productDetailsOf(product.id),
                          extra: product,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
  final List items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 88,
      color: context.semantic.surfaceAlt,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final sub = items[index];
          final selected = sub.id == selectedId;

          return GestureDetector(
            onTap: () =>
                ref.read(subCategoryProvider(categoryId).notifier).select(sub.id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: selected ? context.colors.surface : null,
                border: Border(
                  left: BorderSide(
                    color: selected ? context.colors.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.rMd,
                    child: AppNetworkImage(
                      url: sub.imageUrl,
                      height: 46,
                      width: 46,
                      fallbackIcon: Icons.grid_view_rounded,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Text(
                      sub.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelMedium!.copyWith(
                        color: selected
                            ? context.colors.primary
                            : context.semantic.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
        Container(width: 88, color: context.semantic.surfaceAlt),
        const Expanded(child: ProductGridSkeleton(count: 6)),
      ],
    );
  }
}
