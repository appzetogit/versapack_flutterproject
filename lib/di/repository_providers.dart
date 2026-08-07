import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/local_storage/local_storage.dart';
import '../core/network/api_client.dart';
import '../core/network/dio_api_client.dart';
import '../data/repository_impl/api_address_repository.dart';
import '../data/repository_impl/api_auth_repository.dart';
import '../data/repository_impl/api_cart_repository.dart';
import '../data/repository_impl/api_catalog_content_repository.dart';
import '../data/repository_impl/api_category_repository.dart';
import '../data/repository_impl/api_coupon_repository.dart';
import '../data/repository_impl/api_notification_repository.dart';
import '../data/repository_impl/api_order_repository.dart';
import '../data/repository_impl/api_product_repository.dart';
import '../data/repository_impl/api_review_repository.dart';
import '../data/repository_impl/api_wishlist_repository.dart';
import '../data/repository_impl/google_place_repository.dart';
import '../domain/repository/address_repository.dart';
import '../domain/repository/auth_repository.dart';
import '../domain/repository/cart_repository.dart';
import '../domain/repository/catalog_content_repository.dart';
import '../domain/repository/category_repository.dart';
import '../domain/repository/coupon_repository.dart';
import '../domain/repository/notification_repository.dart';
import '../domain/repository/order_repository.dart';
import '../domain/repository/place_repository.dart';
import '../domain/repository/product_repository.dart';
import '../domain/repository/review_repository.dart';
import '../domain/repository/wishlist_repository.dart';
import '../platform/location/location_service.dart';
import '../platform/notification/notification_service.dart';
import '../platform/payment/razorpay_checkout.dart';
import '../platform/permission/permission_service.dart';

/// Overridden in `main()` once SharedPreferences has loaded.
final localStorageProvider = Provider<LocalStorage>(
  (ref) => throw UnimplementedError('localStorageProvider must be overridden'),
);

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

final authTokenStoreProvider = Provider<LocalAuthTokenStore>(
  (ref) => LocalAuthTokenStore(ref.watch(localStorageProvider)),
);

/// The single transport every repository shares.
final apiClientProvider = Provider<ApiClient>(
  (ref) => DioApiClient(
    config: ref.watch(appConfigProvider),
    tokenStore: ref.watch(authTokenStoreProvider),
  ),
);

// ── Platform ────────────────────────────────────────────────────────────────

final permissionServiceProvider =
    Provider<PermissionService>((ref) => const GeolocatorPermissionService());

/// Google Places + Geocoding. Concrete type is exposed as well so the address
/// screen can open and close an autocomplete billing session.
final googlePlaceRepositoryProvider = Provider<GooglePlaceRepository>(
  (ref) => GooglePlaceRepository(ref.watch(appConfigProvider)),
);

final placeRepositoryProvider = Provider<PlaceRepository>(
  (ref) => ref.watch(googlePlaceRepositoryProvider),
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => GeolocatorLocationService(
    ref.watch(permissionServiceProvider),
    ref.watch(placeRepositoryProvider),
  ),
);

/// Razorpay checkout. Disposed with the container so a half-open sheet cannot
/// outlive the app session.
final paymentGatewayProvider = Provider<PaymentGateway>((ref) {
  final gateway = RazorpayCheckout();
  ref.onDispose(gateway.dispose);
  return gateway;
});

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => FcmNotificationService(
    ref.watch(apiClientProvider),
    ref.watch(localStorageProvider),
  ),
);

// ── Repositories (interface → API implementation) ───────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(localStorageProvider),
    ref.watch(authTokenStoreProvider),
    ref.watch(notificationServiceProvider),
  ),
);

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ApiProductRepository(ref.watch(apiClientProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => ApiCategoryRepository(
    ref.watch(apiClientProvider),
    productRepository: ref.watch(productRepositoryProvider),
  ),
);

final catalogContentRepositoryProvider = Provider<CatalogContentRepository>(
  (ref) => ApiCatalogContentRepository(ref.watch(apiClientProvider)),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => ApiCartRepository(
    ref.watch(apiClientProvider),
    ref.watch(localStorageProvider),
  ),
);

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => ApiOrderRepository(ref.watch(apiClientProvider)),
);

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => ApiAddressRepository(ref.watch(apiClientProvider)),
);

final couponRepositoryProvider = Provider<CouponRepository>(
  (ref) => ApiCouponRepository(ref.watch(apiClientProvider)),
);

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => ApiWishlistRepository(ref.watch(apiClientProvider)),
);

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ApiReviewRepository(ref.watch(apiClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => ApiNotificationRepository(ref.watch(apiClientProvider)),
);
