import 'package:quick_commerce_seller/features/inventory/domain/inventory_repository.dart';
import 'package:quick_commerce_seller/features/inventory/domain/product_model.dart';

class MockInventoryRepository implements InventoryRepository {
  final List<CategoryModel> _categories = [
    const CategoryModel(id: 'cat_1', name: 'Dairy & Bread', itemCount: 12),
    const CategoryModel(id: 'cat_2', name: 'Snacks & Beverages', itemCount: 24),
    const CategoryModel(id: 'cat_3', name: 'Atta, Rice & Oil', itemCount: 18),
    const CategoryModel(id: 'cat_4', name: 'Personal Care', itemCount: 15),
    const CategoryModel(
      id: 'cat_5',
      name: 'Cleaning & Household',
      itemCount: 9,
    ),
  ];

  final List<ProductModel> _products = [
    const ProductModel(
      id: 'p_1',
      name: 'Amul Taaza Toned Milk',
      categoryId: 'cat_1',
      categoryName: 'Dairy & Bread',
      price: 54.0,
      unit: '1 Litre',
      isAvailable: true,
      stockQuantity: 45,
      description: 'Pasteurised toned milk with 3% fat and 8.5% SNF.',
    ),
    const ProductModel(
      id: 'p_2',
      name: 'Harvest Gold Brown Bread',
      categoryId: 'cat_1',
      categoryName: 'Dairy & Bread',
      price: 45.0,
      originalPrice: 50.0,
      unit: '400 grams',
      isAvailable: true,
      stockQuantity: 20,
      description: 'High fibre brown bread baked with whole wheat flour.',
    ),
    const ProductModel(
      id: 'p_3',
      name: 'Coca-Cola Zero Sugar',
      categoryId: 'cat_2',
      categoryName: 'Snacks & Beverages',
      price: 40.0,
      unit: '750 ml',
      isAvailable: false,
      stockQuantity: 0,
      description: 'Refreshing zero calorie carbonated soft drink.',
    ),
    const ProductModel(
      id: 'p_4',
      name: 'Aashirvaad Shudh Chakki Atta',
      categoryId: 'cat_3',
      categoryName: 'Atta, Rice & Oil',
      price: 260.0,
      originalPrice: 285.0,
      unit: '5 kg',
      isAvailable: true,
      stockQuantity: 30,
      description: '100% pure chaki atta with high natural fibre.',
    ),
    const ProductModel(
      id: 'p_5',
      name: 'Fortune Sunlite Sunflower Oil',
      categoryId: 'cat_3',
      categoryName: 'Atta, Rice & Oil',
      price: 145.0,
      unit: '1 Litre Pouch',
      isAvailable: true,
      stockQuantity: 18,
      description: 'Refined sunflower oil rich in Vitamin E.',
    ),
    const ProductModel(
      id: 'p_6',
      name: 'Lay\'s India\'s Magic Masala',
      categoryId: 'cat_2',
      categoryName: 'Snacks & Beverages',
      price: 20.0,
      unit: '50 grams',
      isAvailable: true,
      stockQuantity: 60,
      description:
          'Crispy potato chips flavoured with authentic Indian spices.',
    ),
  ];

  @override
  Future<List<ProductModel>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_products);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_categories);
  }

  @override
  Future<void> toggleProductAvailability(
    String productId,
    bool isAvailable,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(isAvailable: isAvailable);
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _products.insert(0, product);
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _categories.add(category);
  }

  @override
  Future<void> toggleCategoryActive(String categoryId, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(isActive: isActive);
    }
  }
}
