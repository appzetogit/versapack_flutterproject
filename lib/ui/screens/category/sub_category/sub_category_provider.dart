import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../di/repository_providers.dart';
import '../../../../di/service_providers.dart';
import '../../../../domain/model/product.dart';
import 'sub_category_state.dart';

/// Two-pane category browser.
class SubCategoryController
    extends FamilyNotifier<SubCategoryState, String> {
  @override
  SubCategoryState build(String categoryId) {
    Future.microtask(load);
    return const SubCategoryState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final page = await ref
          .read(productRepositoryProvider)
          .list(categoryId: arg, pageSize: 50);

      final grouping = ref.read(catalogGroupingServiceProvider);
      final subCategories = grouping.subCategoriesFrom(page.items, arg);
      final products = page.items;

      state = state.copyWith(
        subCategories: subCategories,
        allProducts: products,
        visibleProducts: products,
        selectedId: subCategories.isEmpty ? '' : subCategories.first.id,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: ErrorMapper.toFailure(e),
      );
    }
  }

  void select(String subCategoryId) {
    final sub = state.subCategories.where((s) => s.id == subCategoryId).firstOrNull;
    if (sub == null) return;
    state = state.copyWith(selectedId: subCategoryId);
    _applyFilters();
  }

  void setSort(ProductSort sort) {
    state = state.copyWith(sort: sort);
    _applyFilters();
  }

  void setDiet(DietFilter diet) {
    state = state.copyWith(diet: diet);
    _applyFilters();
  }

  void setBrand(String brand) {
    state = state.copyWith(brand: brand);
    _applyFilters();
  }

  void setPriceBand(PriceBand band) {
    state = state.copyWith(priceBand: band);
    _applyFilters();
  }

  void clearFilters() {
    state = state.copyWith(
      diet: DietFilter.any,
      brand: '',
      priceBand: PriceBand.any,
    );
    _applyFilters();
  }

  /// One pipeline for every control on the screen: sub-category, then the three
  /// filters, then the sort. Recomputed from `allProducts` each time so filters
  /// can be removed as freely as they are added.
  void _applyFilters() {
    var products = _inSelectedSubCategory();

    products = products.where((p) {
      final diet = switch (state.diet) {
        DietFilter.any => true,
        DietFilter.veg => p.isVeg,
        DietFilter.nonVeg => !p.isVeg,
      };
      final brand = state.brand.isEmpty ||
          p.brand.toLowerCase() == state.brand.toLowerCase();
      return diet && brand && state.priceBand.contains(p.price);
    }).toList();

    switch (state.sort) {
      case ProductSort.relevance:
        break;
      case ProductSort.priceLowToHigh:
        products.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighToLow:
        products.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.discount:
        products.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
      case ProductSort.rating:
        products.sort((a, b) => b.rating.compareTo(a.rating));
    }

    state = state.copyWith(visibleProducts: products);
  }

  List<Product> _inSelectedSubCategory() {
    final sub =
        state.subCategories.where((s) => s.id == state.selectedId).firstOrNull;
    if (sub == null) return state.allProducts;

    List<Product> filtered;
    if (sub.id == 'all') {
      filtered = state.allProducts;
    } else {
      filtered = ref
          .read(catalogGroupingServiceProvider)
          .inSubCategory(state.allProducts, sub);
      if (filtered.isEmpty) {
        // The grouping key is derived; fall back to a name/brand match before
        // conceding the sub-category is empty.
        filtered = state.allProducts
            .where((p) =>
                p.brand.toLowerCase().contains(sub.id.toLowerCase()) ||
                p.name.toLowerCase().contains(sub.name.toLowerCase().split('\n').first))
            .toList();
      }
    }

    return filtered;
  }
}

final subCategoryProvider =
    NotifierProvider.family<SubCategoryController, SubCategoryState, String>(
  SubCategoryController.new,
);

