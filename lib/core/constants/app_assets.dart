/// The app ships no bundled raster assets; imagery comes from the backend.
/// These are the deterministic fallbacks used when a URL is missing/broken.
abstract final class AppAssets {
  static const fallbackProductImage =
      'https://picsum.photos/seed/suvio-product/600/600';
  static const fallbackBannerImage =
      'https://picsum.photos/seed/suvio-banner/1200/500';
  static const fallbackCategoryImage =
      'https://picsum.photos/seed/suvio-category/300/300';
  static const fallbackAvatarImage =
      'https://picsum.photos/seed/suvio-avatar/200/200';

  /// Deterministic per-entity placeholder so lists do not flicker between builds.
  static String seeded(String seed, {int w = 600, int h = 600}) =>
      'https://picsum.photos/seed/${Uri.encodeComponent(seed)}/$w/$h';
}
