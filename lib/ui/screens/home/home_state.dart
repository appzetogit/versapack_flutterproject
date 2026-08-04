import '../../../core/errors/failure.dart';
import '../../../domain/model/banner.dart';
import '../../../domain/model/brand.dart';
import '../../../domain/model/category.dart';
import '../../../domain/model/product.dart';

/// A horizontally-scrolling product row on the home screen.
class HomeSection {
  const HomeSection({
    required this.id,
    required this.title,
    required this.products,
    this.subtitle = '',
    this.categoryId,
    this.showRanks = false,
    this.countdownEndsAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<Product> products;

  /// Set when "See all" should open a category-filtered listing.
  final String? categoryId;

  /// Best-sellers show #1/#2 badges.
  final bool showRanks;

  /// Flash sale shows a live countdown in its header.
  final DateTime? countdownEndsAt;

  bool get isEmpty => products.isEmpty;
}

/// Home is composed of independently-loading pieces, so each part carries its
/// own loading flag rather than blocking the whole page on the slowest call.
class HomeState {
  const HomeState({
    this.banners = const [],
    this.promoBanners = const [],
    this.categories = const [],
    this.brands = const [],
    this.sections = const [],
    this.isLoadingBanners = true,
    this.isLoadingCategories = true,
    this.isLoadingSections = true,
    this.isRefreshing = false,
    this.failure,
    this.etaMinutes = 8,
  });

  final List<PromoBanner> banners;
  final List<PromoBanner> promoBanners;
  final List<Category> categories;
  final List<Brand> brands;
  final List<HomeSection> sections;
  final bool isLoadingBanners;
  final bool isLoadingCategories;
  final bool isLoadingSections;
  final bool isRefreshing;
  final Failure? failure;

  /// Delivery promise shown in the header; refined by the pricing call once a
  /// cart exists.
  final int etaMinutes;

  bool get isInitialLoad =>
      isLoadingSections && sections.isEmpty && categories.isEmpty;

  bool get isEmpty =>
      !isLoadingSections && sections.isEmpty && categories.isEmpty;

  HomeState copyWith({
    List<PromoBanner>? banners,
    List<PromoBanner>? promoBanners,
    List<Category>? categories,
    List<Brand>? brands,
    List<HomeSection>? sections,
    bool? isLoadingBanners,
    bool? isLoadingCategories,
    bool? isLoadingSections,
    bool? isRefreshing,
    Failure? failure,
    int? etaMinutes,
    bool clearFailure = false,
  }) =>
      HomeState(
        banners: banners ?? this.banners,
        promoBanners: promoBanners ?? this.promoBanners,
        categories: categories ?? this.categories,
        brands: brands ?? this.brands,
        sections: sections ?? this.sections,
        isLoadingBanners: isLoadingBanners ?? this.isLoadingBanners,
        isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
        isLoadingSections: isLoadingSections ?? this.isLoadingSections,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        failure: clearFailure ? null : (failure ?? this.failure),
        etaMinutes: etaMinutes ?? this.etaMinutes,
      );
}
