import 'package:quick_commerce_seller/features/inventory/domain/product_model.dart';

abstract class InventoryRepository {
  Future<List<ProductModel>> getProducts();
  Future<List<CategoryModel>> getCategories();
  Future<void> toggleProductAvailability(String productId, bool isAvailable);
  Future<void> updateProduct(ProductModel product);
  Future<void> addProduct(ProductModel product);
  Future<void> addCategory(CategoryModel category);
  Future<void> toggleCategoryActive(String categoryId, bool isActive);
}
