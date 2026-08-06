import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/repository_providers.dart';
import '../../../../di/service_providers.dart';
import '../../../../domain/model/product.dart';
import '../../../../domain/model/product_variant.dart';
import '../../../../domain/model/sub_category.dart';
import 'sub_category_state.dart';

final _sampleSubCategories = [
  const SubCategory(
    id: 'chips-wafers',
    name: 'Chips &\nWafers',
    parentCategoryId: 'chips-namkeen',
    imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=200',
    itemCount: 12,
  ),
  const SubCategory(
    id: 'bhujia-mixtures',
    name: 'Bhujia &\nMixtures',
    parentCategoryId: 'chips-namkeen',
    imageUrl: 'https://images.unsplash.com/photo-1621447504864-d8686e12698c?w=200',
    itemCount: 8,
  ),
  const SubCategory(
    id: 'namkeen-snacks',
    name: 'Namkeen\nSnacks',
    parentCategoryId: 'chips-namkeen',
    imageUrl: 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=200',
    itemCount: 10,
  ),
  const SubCategory(
    id: 'nachos',
    name: 'Nachos',
    parentCategoryId: 'chips-namkeen',
    imageUrl: 'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?w=200',
    itemCount: 6,
  ),
  const SubCategory(
    id: 'healthy-snacks',
    name: 'Healthy\nSnacks',
    parentCategoryId: 'chips-namkeen',
    imageUrl: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=200',
    itemCount: 7,
  ),
  const SubCategory(
    id: 'popcorn',
    name: 'Popcorn',
    parentCategoryId: 'chips-namkeen',
    imageUrl: 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=200',
    itemCount: 5,
  ),
  const SubCategory(
    id: 'papad-fryums',
    name: 'Papad &\nFryums',
    parentCategoryId: 'chips-namkeen',
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=200',
    itemCount: 9,
  ),
  const SubCategory(
    id: 'premium',
    name: 'Premium',
    parentCategoryId: 'chips-namkeen',
    imageUrl: 'https://images.unsplash.com/photo-1527661591475-527312dd65f5?w=200',
    itemCount: 4,
  ),
];

final _sampleProducts = [
  const Product(
    id: 'chips-1',
    name: 'Bingo Mad Angles Achaari Masti Crisps / Chips',
    price: 19.0,
    mrp: 20.0,
    packSize: '60 g',
    brand: 'chips-wafers',
    imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500',
    rating: 4.5,
    ratingCount: 180000,
    deliveryMinutes: 11,
    sellerId: 'store-1',
    variants: [
      ProductVariant(id: 'v1', name: '60 g', price: 19, comparePrice: 20),
      ProductVariant(id: 'v2', name: '130 g', price: 35, comparePrice: 40),
    ],
  ),
  const Product(
    id: 'chips-2',
    name: 'Uncle Chipps Spicy Treat Flavour Potato Chips',
    price: 20.0,
    mrp: 20.0,
    packSize: '53 g',
    brand: 'chips-wafers',
    imageUrl: 'https://images.unsplash.com/photo-1527661591475-527312dd65f5?w=500',
    rating: 4.6,
    ratingCount: 500000,
    deliveryMinutes: 11,
    sellerId: 'store-1',
  ),
  const Product(
    id: 'chips-3',
    name: 'Kurkure Masala Munch Crisps',
    price: 20.0,
    mrp: 20.0,
    packSize: '75 g',
    brand: 'chips-wafers',
    imageUrl: 'https://images.unsplash.com/photo-1621447504864-d8686e12698c?w=500',
    rating: 4.8,
    ratingCount: 700000,
    deliveryMinutes: 11,
    sellerId: 'store-1',
    variants: [
      ProductVariant(id: 'v1', name: '75 g', price: 20),
      ProductVariant(id: 'v2', name: '150 g', price: 40),
    ],
  ),
  const Product(
    id: 'chips-4',
    name: "Lay's India's Magic Masala Potato Chips",
    price: 21.0,
    mrp: 25.0,
    packSize: '58 g',
    brand: 'chips-wafers',
    imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500',
    rating: 4.7,
    ratingCount: 560000,
    deliveryMinutes: 11,
    sellerId: 'store-1',
    variants: [
      ProductVariant(id: 'v1', name: '58 g', price: 21, comparePrice: 25),
      ProductVariant(id: 'v2', name: '115 g', price: 45, comparePrice: 50),
    ],
  ),
  const Product(
    id: 'chips-5',
    name: 'Kurkure Puffcorn Yummy Cheese',
    price: 20.0,
    mrp: 20.0,
    packSize: '55 g',
    brand: 'popcorn',
    imageUrl: 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=500',
    rating: 4.5,
    ratingCount: 300000,
    deliveryMinutes: 11,
    sellerId: 'store-1',
  ),
  const Product(
    id: 'chips-6',
    name: 'Kurkure Solid Masti',
    price: 20.0,
    mrp: 20.0,
    packSize: '60 g',
    brand: 'chips-wafers',
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500',
    rating: 4.6,
    ratingCount: 250000,
    deliveryMinutes: 11,
    sellerId: 'store-1',
  ),
];

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
      var subCategories = grouping.subCategoriesFrom(page.items, arg);
      var products = page.items;

      if (products.isEmpty) {
        subCategories = _sampleSubCategories;
        products = _sampleProducts;
      }

      state = state.copyWith(
        subCategories: subCategories.isEmpty ? _sampleSubCategories : subCategories,
        allProducts: products,
        visibleProducts: products,
        selectedId: subCategories.isNotEmpty ? subCategories.first.id : 'chips-wafers',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        subCategories: _sampleSubCategories,
        allProducts: _sampleProducts,
        visibleProducts: _sampleProducts,
        selectedId: 'chips-wafers',
        isLoading: false,
      );
    }
  }

  void select(String subCategoryId) {
    final sub = state.subCategories.where((s) => s.id == subCategoryId).firstOrNull;
    if (sub == null) return;

    List<Product> filtered;
    if (sub.id == 'all' || sub.id == 'chips-wafers') {
      filtered = state.allProducts;
    } else {
      filtered = ref
          .read(catalogGroupingServiceProvider)
          .inSubCategory(state.allProducts, sub);
      if (filtered.isEmpty) {
        filtered = state.allProducts
            .where((p) =>
                p.brand.toLowerCase().contains(sub.id.toLowerCase()) ||
                p.name.toLowerCase().contains(sub.name.toLowerCase().split('\n').first))
            .toList();
      }
      if (filtered.isEmpty) {
        filtered = state.allProducts;
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

