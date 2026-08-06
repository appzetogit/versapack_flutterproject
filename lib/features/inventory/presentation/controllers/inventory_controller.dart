import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_commerce_seller/core/providers/repository_providers.dart';
import 'package:quick_commerce_seller/features/inventory/domain/inventory_repository.dart';
import 'package:quick_commerce_seller/features/inventory/domain/product_model.dart';

final inventoryControllerProvider =
    AsyncNotifierProvider<InventoryController, List<ProductModel>>(
      InventoryController.new,
    );

class InventoryController extends AsyncNotifier<List<ProductModel>> {
  late final InventoryRepository _repository;

  @override
  Future<List<ProductModel>> build() async {
    _repository = ref.watch(inventoryRepositoryProvider);
    return _repository.getProducts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getProducts());
  }

  Future<void> toggleStock(String productId, bool isAvailable) async {
    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList
          .map(
            (p) => p.id == productId ? p.copyWith(isAvailable: isAvailable) : p,
          )
          .toList(),
    );
    await _repository.toggleProductAvailability(productId, isAvailable);
  }

  Future<void> addProduct(ProductModel product) async {
    await _repository.addProduct(product);
    await refresh();
  }

  Future<void> updateProduct(ProductModel product) async {
    await _repository.updateProduct(product);
    await refresh();
  }
}

final categoriesControllerProvider =
    AsyncNotifierProvider<CategoriesController, List<CategoryModel>>(
      CategoriesController.new,
    );

class CategoriesController extends AsyncNotifier<List<CategoryModel>> {
  late final InventoryRepository _repository;

  @override
  Future<List<CategoryModel>> build() async {
    _repository = ref.watch(inventoryRepositoryProvider);
    return _repository.getCategories();
  }

  Future<void> addCategory(String name) async {
    final newCat = CategoryModel(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      itemCount: 0,
    );
    await _repository.addCategory(newCat);
    state = await AsyncValue.guard(() => _repository.getCategories());
  }

  Future<void> toggleActive(String categoryId, bool isActive) async {
    await _repository.toggleCategoryActive(categoryId, isActive);
    state = await AsyncValue.guard(() => _repository.getCategories());
  }
}
