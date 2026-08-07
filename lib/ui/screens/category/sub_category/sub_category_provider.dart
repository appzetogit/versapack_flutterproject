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

    state = state.copyWith(
      selectedId: subCategoryId,
      visibleProducts: filtered,
    );
  }
}

final subCategoryProvider =
    NotifierProvider.family<SubCategoryController, SubCategoryState, String>(
  SubCategoryController.new,
);

