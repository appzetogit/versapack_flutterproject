import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../di/repository_providers.dart';
import '../../../../di/service_providers.dart';
import 'sub_category_state.dart';

/// Two-pane category browser.
///
/// The backend's category tree is flat, so the left rail is built by
/// `CatalogGroupingService` from the brands present in the category's items.
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

      state = state.copyWith(
        subCategories: subCategories,
        allProducts: page.items,
        visibleProducts: page.items,
        selectedId: 'all',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, failure: ErrorMapper.toFailure(e));
    }
  }

  void select(String subCategoryId) {
    final sub = state.subCategories.where((s) => s.id == subCategoryId).firstOrNull;
    if (sub == null) return;

    state = state.copyWith(
      selectedId: subCategoryId,
      visibleProducts: ref
          .read(catalogGroupingServiceProvider)
          .inSubCategory(state.allProducts, sub),
    );
  }
}

final subCategoryProvider =
    NotifierProvider.family<SubCategoryController, SubCategoryState, String>(
  SubCategoryController.new,
);
