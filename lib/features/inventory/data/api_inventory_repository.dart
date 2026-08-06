import 'package:dio/dio.dart';
import 'package:quick_commerce_seller/features/inventory/domain/inventory_repository.dart';
import 'package:quick_commerce_seller/features/inventory/domain/product_model.dart';

/// The seller's catalogue and stock.
///
/// Products come back from `/food/restaurant/menu` grouped into sections, which
/// is the shape the customer app renders. A seller manages a flat list, so the
/// sections are flattened here rather than in a controller — the grouping is a
/// presentation detail of a different app.
class ApiInventoryRepository implements InventoryRepository {
  const ApiInventoryRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _dio.get<dynamic>('/food/restaurant/menu');
    final menu = _asMap(_asMap(response.data)['menu']);

    final products = <ProductModel>[];
    for (final section in _asList(menu['sections'])) {
      // Subsections exist once a category has children; their items would be
      // missed entirely by reading `items` alone.
      for (final item in _asList(section['items'])) {
        products.add(_toProduct(item));
      }
      for (final sub in _asList(section['subsections'])) {
        for (final item in _asList(sub['items'])) {
          products.add(_toProduct(item));
        }
      }
    }

    // The same product cannot appear twice, but a product filed under a
    // category *and* its parent would. Keyed by id so it is listed once.
    final byId = {for (final p in products) p.id: p};
    return byId.values.toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get<dynamic>('/food/restaurant/categories');
    final data = response.data;
    final list = data is List ? data : _asList(_asMap(data)['categories']);

    return list
        .map(
          (c) => CategoryModel(
            id: (c['_id'] ?? c['id'] ?? '').toString(),
            name: (c['name'] ?? '').toString(),
            itemCount: _asNum(c['itemCount'])?.toInt() ?? 0,
            isActive: c['isActive'] != false,
            iconName: _nullIfEmpty(c['image']),
          ),
        )
        .toList();
  }

  @override
  Future<void> toggleProductAvailability(String productId, bool isAvailable) =>
      _dio.patch<dynamic>(
        '/food/restaurant/foods/$productId',
        data: {'isAvailable': isAvailable},
      );

  @override
  Future<void> updateProduct(ProductModel product) => _dio.patch<dynamic>(
    '/food/restaurant/foods/${product.id}',
    data: _toWire(product),
  );

  @override
  Future<void> addProduct(ProductModel product) =>
      _dio.post<dynamic>('/food/restaurant/foods', data: _toWire(product));

  @override
  Future<void> addCategory(CategoryModel category) => _dio.post<dynamic>(
    '/food/restaurant/categories',
    data: {'name': category.name, 'isActive': category.isActive},
  );

  @override
  Future<void> toggleCategoryActive(String categoryId, bool isActive) =>
      _dio.patch<dynamic>(
        '/food/restaurant/categories/$categoryId',
        data: {'isActive': isActive},
      );

  ProductModel _toProduct(Map<String, dynamic> json) => ProductModel(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    categoryId: (json['categoryId'] ?? '').toString(),
    categoryName: (json['categoryName'] ?? json['category'] ?? '').toString(),
    price: _asNum(json['price'])?.toDouble() ?? 0,
    // The struck-through price is the printed MRP. `otherPrice` is a
    // compare-against-other-platforms figure and is not what a shopper is
    // shown, so it is only a fallback for products predating MRP.
    originalPrice: _asNum(json['mrp'])?.toDouble() ??
        _positiveOrNull(_asNum(json['otherPrice'])?.toDouble()),
    // A grocery line's "unit" is its pack size.
    unit: (json['packSize'] ?? '').toString(),
    isAvailable: json['isAvailable'] != false,
    // null means the product is not stock-tracked at all, which is different
    // from none in stock. The screen has no way to draw that distinction, so
    // untracked reads as 0 and the seller sets a real count to begin tracking.
    stockQuantity: _asNum(json['stockQty'])?.toInt() ?? 0,
    imageUrl: _nullIfEmpty(json['image']),
    description: (json['description'] ?? '').toString(),
  );

  Map<String, dynamic> _toWire(ProductModel p) => {
    'name': p.name,
    if (p.categoryId.isNotEmpty) 'categoryId': p.categoryId,
    'price': p.price,
    if (p.originalPrice != null && p.originalPrice! > 0) 'mrp': p.originalPrice,
    'packSize': p.unit,
    'isAvailable': p.isAvailable,
    'stockQty': p.stockQuantity,
    'description': p.description,
    if (p.imageUrl != null && p.imageUrl!.isNotEmpty) 'image': p.imageUrl,
  };

  static double? _positiveOrNull(double? v) =>
      (v == null || v <= 0) ? null : v;

  static Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  static List<Map<String, dynamic>> _asList(dynamic v) => v is List
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : const [];

  static num? _asNum(dynamic v) =>
      v is num ? v : num.tryParse((v ?? '').toString());

  static String? _nullIfEmpty(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }
}
