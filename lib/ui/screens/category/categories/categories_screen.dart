import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../navigation/route_paths.dart';
import '../../../common/widgets/cards/category_card.dart';
import '../../../common/widgets/loaders/list_skeleton.dart';
import '../../../common/widgets/misc/staggered_entrance.dart';
import '../../../common/widgets/states/empty_state_widget.dart';
import '../../../common/widgets/states/error_state_widget.dart';
import '../../cart/widgets/cart_summary_bar.dart';
import 'categories_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('All categories')) : null,
      bottomNavigationBar: const CartSummaryBar(),
      body: SafeArea(
        child: categories.when(
          loading: () => const CategoryGridSkeleton(count: 12, columns: 3),
          error: (error, _) => ErrorStateWidget(
            failure: ErrorMapper.toFailure(error),
            onRetry: () => ref.invalidate(categoriesProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.category_outlined,
                title: 'No categories yet',
                message:
                    'Our catalog is being set up for your area. Check back shortly.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(categoriesProvider),
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.xl,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final category = items[index];
                  return StaggeredEntrance(
                    index: index,
                    child: CategoryCard(
                      category: category,
                      size: 84,
                      onTap: () => context.push(
                        RoutePaths.subCategoryOf(category.id),
                        extra: category,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
