import 'product.dart';

/// A seller/store fulfilling catalog items, derived from backend product catalog data.
class Seller {
  const Seller({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.acceptingOrders = true,
    this.deliveryMinutes,
    this.productCount = 1,
    this.rating = 4.8,
    this.ratingCount = 1200,
    this.minFreeDelivery = 199,
    this.products = const [],
  });

  final String id;
  final String name;
  final String imageUrl;
  final bool acceptingOrders;
  final int? deliveryMinutes;
  final int productCount;
  final double rating;
  final int ratingCount;
  final int minFreeDelivery;
  final List<Product> products;

  /// Images of all actual products belonging to this seller.
  List<String> get productImages {
    final list = <String>[];
    for (final p in products) {
      if (p.imageUrl.trim().isNotEmpty) {
        list.add(p.imageUrl.trim());
      }
      for (final img in p.images) {
        if (img.trim().isNotEmpty) {
          list.add(img.trim());
        }
      }
    }
    if (imageUrl.trim().isNotEmpty) {
      list.add(imageUrl.trim());
    }
    final seen = <String>{};
    return list.where(seen.add).toList();
  }

  String get formattedRatingCount {
    if (ratingCount >= 1000) {
      return '${(ratingCount / 1000).toStringAsFixed(1)}K+';
    }
    return '$ratingCount';
  }

  @override
  bool operator ==(Object other) => other is Seller && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
