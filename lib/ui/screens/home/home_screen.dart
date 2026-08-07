import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/model/banner.dart';
import '../../../navigation/route_paths.dart';
import '../../common/widgets/inputs/search_bar_widget.dart';
import '../../common/widgets/states/error_state_widget.dart';
import '../../common/widgets/states/offline_banner.dart';
import '../product/product_listing/product_listing_args.dart';
import 'home_provider.dart';
import 'home_state.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/bestsellers_row.dart';
import 'widgets/delivery_header.dart';
import 'widgets/mega_deals_section.dart';
import 'widgets/offer_coupons_row.dart';
import 'widgets/quick_category_row.dart';
import 'widgets/shop_by_category_row.dart';

import 'package:flutter/services.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Column(
          children: [
            const OfflineBanner(),
            Container(
              color: const Color(0xFFFFD400),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const DeliveryHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                      child: SearchBarWidget(
                        readOnly: true,
                        onTap: () => context.push(RoutePaths.search),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _body(context, ref, state)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, HomeState state) {
    if (state.failure != null && state.sections.isEmpty && state.categories.isEmpty) {
      return ErrorStateWidget(
        failure: state.failure!,
        onRetry: () => ref.read(homeProvider.notifier).load(refresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).load(refresh: true),
      child: CustomScrollView(
        slivers: [
          // 1. Quick category icon strip.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: QuickCategoryRow(
                categories: state.categories,
                isLoading: state.isLoadingCategories,
                onAllTap: () => context.go(RoutePaths.categories),
                onCategoryTap: (catId) =>
                    context.push(RoutePaths.subCategoryOf(catId)),
              ),
            ),
          ),

          // 2. Hero Promotional Banner ("Groceries in 10 minutes")
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: BannerCarousel(
                banners: state.banners,
                isLoading: state.isLoadingBanners,
                onTap: (banner) => _openBanner(context, banner),
              ),
            ),
          ),

          // 3. Live offer cards.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: OfferCouponsRow(
                coupons: state.coupons,
                isLoading: state.isLoadingCoupons,
                onOfferTap: (_) => context.push(RoutePaths.coupons),
              ),
            ),
          ),

          // 4. Shop by category.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ShopByCategoryRow(
                categories: state.categories,
                isLoading: state.isLoadingCategories,
                onSeeAll: () => context.go(RoutePaths.categories),
                onCategoryTap: (catId) =>
                    context.push(RoutePaths.subCategoryOf(catId)),
              ),
            ),
          ),

          // 5. Bestsellers, ranked from the live catalog.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: BestsellersRow(
                products: state.productsOf('best-sellers'),
                isLoading: state.isLoadingSections,
                onSeeAll: () => context.push(RoutePaths.productListing),
                onProductTap: (id) =>
                    context.push(RoutePaths.productDetailsOf(id)),
              ),
            ),
          ),

          // 6. Mega deals — the flash-sale (deepest discount) products.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: MegaDealsSection(
                deals: state.productsOf('flash'),
                isLoading: state.isLoadingSections,
                onShopNowTap: () => context.push(RoutePaths.productListing),
                onItemTap: (product) =>
                    context.push(RoutePaths.productDetailsOf(product.id)),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: _HomeFooter()),
        ],
      ),
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
            'appzeto',
            style: context.text.displayMedium!.copyWith(
              color: context.semantic.border,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Fresh essentials, delivered to your doorstep.',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}
