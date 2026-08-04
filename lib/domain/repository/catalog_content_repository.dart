import '../model/banner.dart';

/// Home-screen merchandising content (banners, promo strips) from the
/// backend's landing module.
abstract interface class CatalogContentRepository {
  Future<List<PromoBanner>> heroBanners();

  Future<List<PromoBanner>> topBanners();

  Future<List<PromoBanner>> promotionBanners();

  /// Free-delivery threshold and fee configuration, used for the cart's
  /// "add ₹X more for free delivery" nudge.
  Future<({double freeDeliveryThreshold, double baseDeliveryFee})> feeSettings();
}
