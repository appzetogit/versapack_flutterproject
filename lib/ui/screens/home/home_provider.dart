import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../di/repository_providers.dart';
import '../../../di/service_providers.dart';
import '../../../domain/model/order.dart';
import '../../../domain/model/product.dart';
import 'home_state.dart';

/// Builds the home screen from the real catalog.
///
/// Sections are derived rather than fetched: the backend has no
/// "trending"/"best sellers" endpoints, so `CatalogGroupingService` ranks a
/// fetched catalog page. Documented in README → Backend Gaps.
class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    Future.microtask(load);
    return const HomeState();
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) state = state.copyWith(isRefreshing: true, clearFailure: true);

    // Banners, categories and the catalog load in parallel; each updates the
    // UI as it lands so no section waits on another.
    await Future.wait([
      _loadBanners(),
      _loadCatalog(),
    ]);

    if (refresh) state = state.copyWith(isRefreshing: false);
  }

  Future<void> _loadBanners() async {
    state = state.copyWith(isLoadingBanners: true);
    try {
      final content = ref.read(catalogContentRepositoryProvider);
      final results = await Future.wait([
        content.heroBanners(),
        content.promotionBanners(),
      ]);
      state = state.copyWith(
        banners: results[0],
        promoBanners: results[1],
        isLoadingBanners: false,
      );
    } catch (_) {
      // Banners are decoration; their failure must not take the page down.
      state = state.copyWith(isLoadingBanners: false);
    }
  }

  Future<void> _loadCatalog() async {
    state = state.copyWith(
      isLoadingCategories: true,
      isLoadingSections: true,
      clearFailure: true,
    );

    try {
      final categories = await ref.read(categoryRepositoryProvider).topLevel();
      state = state.copyWith(categories: categories, isLoadingCategories: false);

      final products = ref.read(productRepositoryProvider);
      final grouping = ref.read(catalogGroupingServiceProvider);

      final catalog = await products.list(pageSize: 50);
      final all = catalog.items;

      // One request per visible category row, in parallel.
      final rowCategories = categories.take(8).toList();
      final rows = await Future.wait(
        rowCategories.map(
          (c) => products
              .list(categoryId: c.id, pageSize: 12)
              .then((page) => page.items)
              .catchError((_) => <Product>[]),
        ),
      );

      final sections = <HomeSection>[
        HomeSection(
          id: 'flash',
          title: 'Flash sale',
          subtitle: 'Deepest discounts, while stock lasts',
          products: grouping.flashSale(all),
          countdownEndsAt: _endOfFlashWindow(),
        ),
        HomeSection(
          id: 'trending',
          title: 'Trending near you',
          products: all.where((p) => p.ratingCount > 0).take(12).toList(),
        ),
        HomeSection(
          id: 'recently-bought',
          title: 'Buy it again',
          subtitle: 'From your recent orders',
          products: await _recentlyBought(all),
        ),
        HomeSection(
          id: 'recommended',
          title: 'Recommended for you',
          products: grouping.recommended(all),
        ),
        HomeSection(
          id: 'best-sellers',
          title: 'Best sellers',
          products: grouping.bestSellers(all),
          showRanks: true,
        ),
        for (var i = 0; i < rowCategories.length; i++)
          HomeSection(
            id: 'category-${rowCategories[i].id}',
            title: rowCategories[i].name,
            products: rows[i],
            categoryId: rowCategories[i].id,
          ),
      ]..removeWhere((s) => s.isEmpty);

      state = state.copyWith(
        sections: sections,
        brands: grouping.brandsFrom(all).take(12).toList(),
        isLoadingSections: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCategories: false,
        isLoadingSections: false,
        failure: ErrorMapper.toFailure(e),
      );
    }
  }

  /// Products from the customer's own delivered orders, matched back to the
  /// live catalog so prices and stock are current.
  Future<List<Product>> _recentlyBought(List<Product> catalog) async {
    try {
      final orders = await ref.read(orderRepositoryProvider).list(pageSize: 10);
      final boughtIds = <String>{};
      for (final Order order in orders.items) {
        for (final line in order.lines) {
          boughtIds.add(line.itemId);
        }
      }
      return catalog.where((p) => boughtIds.contains(p.id)).take(12).toList();
    } catch (_) {
      // Signed-out or failed: the section simply does not render.
      return const [];
    }
  }

  /// Flash sale resets at the top of every fourth hour.
  DateTime _endOfFlashWindow() {
    final now = DateTime.now();
    final nextBoundary = ((now.hour ~/ 4) + 1) * 4;
    return DateTime(now.year, now.month, now.day).add(Duration(hours: nextBoundary));
  }
}

final homeProvider = NotifierProvider<HomeController, HomeState>(HomeController.new);
