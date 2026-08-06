class CategoryModel {
  final String id;
  final String name;
  final int itemCount;
  final bool isActive;
  final String? iconName;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.itemCount,
    this.isActive = true,
    this.iconName,
  });

  CategoryModel copyWith({
    String? name,
    int? itemCount,
    bool? isActive,
    String? iconName,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      itemCount: itemCount ?? this.itemCount,
      isActive: isActive ?? this.isActive,
      iconName: iconName ?? this.iconName,
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final double price;
  final double? originalPrice;
  final String unit;
  final bool isAvailable;
  final int stockQuantity;
  final String? imageUrl;
  final String description;

  const ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.originalPrice,
    required this.unit,
    this.isAvailable = true,
    required this.stockQuantity,
    this.imageUrl,
    this.description = '',
  });

  ProductModel copyWith({
    String? name,
    String? categoryId,
    String? categoryName,
    double? price,
    double? originalPrice,
    String? unit,
    bool? isAvailable,
    int? stockQuantity,
    String? imageUrl,
    String? description,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      unit: unit ?? this.unit,
      isAvailable: isAvailable ?? this.isAvailable,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }
}
