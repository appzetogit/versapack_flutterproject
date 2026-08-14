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
import 'widgets/active_order_card.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/bestsellers_row.dart';
import 'widgets/delivery_header.dart';
import 'widgets/feature_highlights_row.dart';
import 'widgets/mega_deals_section.dart';
import 'widgets/offer_coupons_row.dart';
import '../../common/widgets/misc/section_header.dart';
import 'widgets/product_row.dart';
import 'widgets/quick_category_row.dart';
import 'widgets/shop_by_brand_row.dart';
import 'widgets/top_sellers_row.dart';

import 'package:flutter/services.dart';
import '../../common/widgets/misc/sound_refresh_indicator.dart';

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
        backgroundColor: context.colors.surface,
        body: Stack(
          children: [
            Column(
              children: [
                const OfflineBanner(),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFB300),
                        Color(0xFFFFC107),
                        Color(0xFFFFD54F),
                        Color(0xFFFFF8E1),
                        Colors.white,
                      ],
                      stops: [0.0, 0.4, 0.7, 0.9, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        const DeliveryHeader(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
                          child: SearchBarWidget(
                            readOnly: true,
                            categories: state.categories.map((c) => c.name).toList(),
                            onTap: () => context.push(RoutePaths.search),
                          ),
                        ),
                        const FeatureHighlightsRow(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Expanded(child: _body(context, ref, state)),
              ],
            ),

            // Active Order Floating Card above bottom navigation
            const Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: ActiveOrderFloatingCard(),
            ),
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

    return SoundRefreshIndicator(
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
          // 4. Top Sellers section (Exact screenshot UI design).
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: TopSellersRow(
                sellers: state.sellers,
                isLoading: state.isLoadingSections,
                onSeeAll: () => context.push(
                  RoutePaths.productListing,
                  extra: const ProductListingArgs(title: 'Top Sellers'),
                ),
                onSellerTap: (seller) => context.push(
                  RoutePaths.productListing,
                  extra: ProductListingArgs(
                    title: seller.name,
                    sellerId: seller.id,
                  ),
                ),
              ),
            ),
          ),

          // 5. Brands the live catalogue actually carries.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ShopByBrandRow(
                brands: state.brands,
                isLoading: state.isLoadingSections,
                onSeeAll: () => context.push(RoutePaths.brands),
                onBrandTap: (brand) => context.push(
                  RoutePaths.productListing,
                  extra: ProductListingArgs(
                    title: brand.name,
                    brandName: brand.name,
                  ),
                ),
              ),
            ),
          ),

          // 6. Bestsellers, ranked from the live catalog.
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

          // 7. Everything else the catalog gave us: trending, buy-it-again,
          //    recommended, and one row per category the backend returned.
          //    These were being fetched and thrown away.
          SliverList.builder(
            itemCount: state.rows.length,
            itemBuilder: (context, index) {
              final section = state.rows[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: section.title,
                      subtitle:
                          section.subtitle.isEmpty ? null : section.subtitle,
                      onSeeAll: () => context.push(
                        section.categoryId == null
                            ? RoutePaths.productListing
                            : RoutePaths.subCategoryOf(section.categoryId!),
                        extra: section.categoryId == null
                            ? ProductListingArgs(title: section.title)
                            : null,
                      ),
                    ),
                    ProductRow(
                      products: section.products,
                      heroTag: 'home-${section.id}',
                      showRanks: section.showRanks,
                      onProductTap: (product) =>
                          context.push(RoutePaths.productDetailsOf(product.id)),
                    ),
                  ],
                ),
              );
            },
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
              fontWeight: FontWeight.bold,
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
