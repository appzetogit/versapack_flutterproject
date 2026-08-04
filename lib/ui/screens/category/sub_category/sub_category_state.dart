import '../../../../core/errors/failure.dart';
import '../../../../domain/model/product.dart';
import '../../../../domain/model/sub_category.dart';

class SubCategoryState {
  const SubCategoryState({
    this.subCategories = const [],
    this.allProducts = const [],
    this.visibleProducts = const [],
    this.selectedId = 'all',
    this.isLoading = true,
    this.failure,
  });

  final List<SubCategory> subCategories;
  final List<Product> allProducts;
  final List<Product> visibleProducts;
  final String selectedId;
  final bool isLoading;
  final Failure? failure;

  bool get isEmpty => !isLoading && allProducts.isEmpty && failure == null;

  SubCategoryState copyWith({
    List<SubCategory>? subCategories,
    List<Product>? allProducts,
    List<Product>? visibleProducts,
    String? selectedId,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      SubCategoryState(
        subCategories: subCategories ?? this.subCategories,
        allProducts: allProducts ?? this.allProducts,
        visibleProducts: visibleProducts ?? this.visibleProducts,
        selectedId: selectedId ?? this.selectedId,
        isLoading: isLoading ?? this.isLoading,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}
