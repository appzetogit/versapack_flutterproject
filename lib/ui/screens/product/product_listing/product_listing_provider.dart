import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../di/repository_providers.dart';
import '../../../../di/service_providers.dart';
import '../../../../domain/model/product.dart';
import '../../../../domain/repository/product_repository.dart';
import 'product_listing_args.dart';
import 'product_listing_state.dart';

/// Paginated, filterable listing.
///
/// The catalog endpoint accepts a query, category and veg/stock flags; price
/// range, brand and sort are applied by `SearchRankingService` over the pages
/// fetched so far.
class ProductListingController
    extends FamilyNotifier<ProductListingState, ProductListingArgs> {
  static const _pageSize = 20;

  final List<Product> _raw = [];

  @override
  ProductListingState build(ProductListingArgs args) {
    if (args.isSeeded) {
      _raw
        ..clear()
        ..addAll(args.seedProducts);
      return _rank(
        ProductListingState(
          filters: args.initialFilters,
          sort: args.initialSort,
          isLoading: false,
        ),
      );
    }

    Future.microtask(() => load(reset: true));
    return ProductListingState(
      filters: args.initialFilters,
      sort: args.initialSort,
    );
  }

  Future<void> load({bool reset = false}) async {
    if (reset) {
      _raw.clear();
      state = state.copyWith(isLoading: true, page: 1, clearFailure: true);
    }

    try {
      final page = await ref.read(productRepositoryProvider).list(
            query: arg.query,
            categoryId: state.filters.categoryId,
            vegOnly: state.filters.vegOnly,
            inStockOnly: state.filters.inStockOnly,
            page: reset ? 1 : state.page,
            pageSize: _pageSize,
          );

      _raw.addAll(page.items);
      state = _rank(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          hasMore: page.hasMore,
          page: page.page,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        failure: ErrorMapper.toFailure(e),
      );
    }
  }

  /// Triggered when the grid scrolls past ~80%.
  Future<void> loadMore() async {
    if (arg.isSeeded || state.isLoadingMore || state.isLoading || !state.hasMore) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, page: state.page + 1);
    await load();
  }

  void applyFilters(ProductFilters filters) {
    final needsRefetch = filters.vegOnly != state.filters.vegOnly ||
        filters.inStockOnly != state.filters.inStockOnly ||
        filters.categoryId != state.filters.categoryId;

    state = state.copyWith(filters: filters);
    if (needsRefetch && !arg.isSeeded) {
      load(reset: true);
    } else {
      state = _rank(state);
    }
  }

  void applySort(ProductSort sort) => state = _rank(state.copyWith(sort: sort));

  void clearFilters() => applyFilters(arg.initialFilters);

  /// Price bounds for the filter sheet's slider, from what we actually have.
  ({double min, double max}) get priceBounds {
    if (_raw.isEmpty) return (min: 0, max: 1000);
    final prices = _raw.map((p) => p.price).toList()..sort();
    return (min: prices.first, max: prices.last);
  }

  List<String> get availableBrands {
    final brands = _raw.map((p) => p.brand.trim()).where((b) => b.isNotEmpty).toSet();
    return brands.toList()..sort();
  }

  ProductListingState _rank(ProductListingState next) {
    final ranked = ref.read(searchRankingServiceProvider).apply(
          _raw,
          filters: next.filters,
          sort: next.sort,
          query: arg.query ?? '',
        );
    return next.copyWith(products: ranked);
  }
}

final productListingProvider = NotifierProvider.family<ProductListingController,
    ProductListingState, ProductListingArgs>(ProductListingController.new);
