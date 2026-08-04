import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/model/banner.dart';
import '../../../domain/model/product.dart';
import '../../../navigation/route_paths.dart';
import '../../common/widgets/cards/brand_card.dart';
import '../../common/widgets/cards/category_card.dart';
import '../../common/widgets/inputs/search_bar_widget.dart';
import '../../common/widgets/loaders/list_skeleton.dart';
import '../../common/widgets/loaders/product_card_skeleton.dart';
import '../../common/widgets/misc/section_header.dart';
import '../../common/widgets/states/error_state_widget.dart';
import '../../common/widgets/states/offline_banner.dart';
import '../product/product_listing/product_listing_args.dart';
import 'home_provider.dart';
import 'home_state.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/delivery_header.dart';
import 'widgets/flash_countdown.dart';
import 'widgets/product_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OfflineBanner(),
            DeliveryHeader(etaMinutes: state.etaMinutes),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: SearchBarWidget(
                readOnly: true,
                onTap: () => context.push(RoutePaths.search),
              ),
            ),
            Expanded(child: _body(context, ref, state)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, HomeState state) {
    if (state.failure != null && state.sections.isEmpty) {
      return ErrorStateWidget(
        failure: state.failure!,
        onRetry: () => ref.read(homeProvider.notifier).load(refresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).load(refresh: true),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: BannerCarousel(
                banners: state.banners,
                isLoading: state.isLoadingBanners,
                onTap: (banner) => _openBanner(context, banner),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _categories(context, state)),
          if (state.brands.isNotEmpty)
            SliverToBoxAdapter(child: _brands(context, state)),
          if (state.isLoadingSections && state.sections.isEmpty)
            const SliverToBoxAdapter(child: _SectionsSkeleton())
          else
            SliverList.builder(
              itemCount: state.sections.length,
              itemBuilder: (context, index) =>
                  _section(context, state.sections[index]),
            ),
          if (state.promoBanners.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: BannerCarousel(
                  banners: state.promoBanners,
                  height: 132,
                  onTap: (banner) => _openBanner(context, banner),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: _HomeFooter()),
        ],
      ),
    );
  }

  Widget _categories(BuildContext context, HomeState state) {
    if (state.isLoadingCategories && state.categories.isEmpty) {
      return const CategoryGridSkeleton(count: 8);
    }
    if (state.categories.isEmpty) return const SizedBox.shrink();

    // Two rows that scroll together horizontally — the quick-commerce standard,
    // and denser than a single strip.
    final categories = state.categories;
    final rows = [
      [for (var i = 0; i < categories.length; i += 2) categories[i]],
      [for (var i = 1; i < categories.length; i += 2) categories[i]],
    ];

    // A horizontal scroller needs a bounded height, and a hardcoded one clips
    // as soon as the user raises their font size. Derive it from the tile: the
    // image plate, the gap, two lines of label, and the row gap.
    const tileSize = 68.0;
    const labelLineHeight = 12 * 1.2;
    final labelBlock =
        MediaQuery.textScalerOf(context).scale(labelLineHeight) * 2;
    final rowHeight = tileSize + AppSpacing.sm + labelBlock + AppSpacing.md;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Shop by category',
          onSeeAll: () => context.push(RoutePaths.categories),
        ),
        SizedBox(
          height: rowHeight * rows.length,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                for (final row in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        for (final category in row)
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.md),
                            child: CategoryCard(
                              category: category,
                              size: tileSize,
                              onTap: () => context.push(
                                RoutePaths.subCategoryOf(category.id),
                                extra: category,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _brands(BuildContext context, HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Featured brands',
          onSeeAll: () => context.push(RoutePaths.brands),
        ),
        SizedBox(
          height: 146,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: state.brands.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final brand = state.brands[index];
              return BrandCard(
                brand: brand,
                onTap: () => context.push(
                  RoutePaths.productListing,
                  extra: ProductListingArgs.forBrand(brand),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _section(BuildContext context, HomeSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: section.title,
          subtitle: section.subtitle.isEmpty ? null : section.subtitle,
          trailing: section.countdownEndsAt == null
              ? null
              : FlashCountdown(endsAt: section.countdownEndsAt!),
          onSeeAll: section.countdownEndsAt != null
              ? null
              : () => context.push(
                    RoutePaths.productListing,
                    extra: ProductListingArgs(
                      title: section.title,
                      categoryId: section.categoryId,
                      seedProducts: section.categoryId == null
                          ? section.products
                          : const <Product>[],
                    ),
                  ),
        ),
        ProductRow(
          products: section.products,
          heroTag: section.id,
          showRanks: section.showRanks,
          onProductTap: (product) => context.push(
            RoutePaths.productDetailsOf(product.id),
            extra: product,
          ),
        ),
      ],
    );
  }

  void _openBanner(BuildContext context, PromoBanner banner) {
    switch (banner.target) {
      case BannerTarget.offers:
        context.push(RoutePaths.coupons);
      case BannerTarget.category:
        context.push(RoutePaths.subCategoryOf(banner.targetId));
      case BannerTarget.products:
      case BannerTarget.restaurant:
        context.push(
          RoutePaths.productListing,
          extra: ProductListingArgs(
            title: banner.title.isEmpty ? 'Offers' : banner.title,
          ),
        );
      case BannerTarget.none:
        break;
    }
  }
}

class _SectionsSkeleton extends StatelessWidget {
  const _SectionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Loading fresh picks…'),
        ProductRowSkeleton(),
        SizedBox(height: AppSpacing.xl),
        SectionHeader(title: ' '),
        ProductRowSkeleton(),
      ],
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      child: Column(
        children: [
          Text(
            'SUVIO QUICK',
            style: context.text.displayMedium!.copyWith(
              color: context.semantic.border,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Delivered fresh, delivered fast.',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}
