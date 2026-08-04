import '../../core/network/api_client.dart';
import '../../domain/model/banner.dart';
import '../../domain/repository/catalog_content_repository.dart';
import '../dto/banner_dto.dart';
import '../dto/json_reader.dart';
import '../mapper/banner_mapper.dart';
import 'api_paths.dart';

class ApiCatalogContentRepository implements CatalogContentRepository {
  ApiCatalogContentRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<PromoBanner>> heroBanners() => _banners(ApiPaths.heroBanners);

  @override
  Future<List<PromoBanner>> topBanners() => _banners(ApiPaths.topBanners);

  @override
  Future<List<PromoBanner>> promotionBanners() =>
      _banners(ApiPaths.promotionBanners);

  Future<List<PromoBanner>> _banners(String path) async {
    final json = await _client.get(path);
    if (json is! Map<String, dynamic>) return const [];
    return BannerMapper.toDomainList(
      json.objects('banners').map(BannerDto.fromJson).toList(),
    );
  }

  @override
  Future<({double freeDeliveryThreshold, double baseDeliveryFee})>
      feeSettings() async {
    final json = await _client.get(ApiPaths.feeSettings);
    final settings =
        json is Map<String, dynamic> ? json.mapOrNull('feeSettings') : null;
    if (settings == null) {
      return (freeDeliveryThreshold: 199.0, baseDeliveryFee: 0.0);
    }

    // The fee table is distance-banded, not order-value-banded, so there is no
    // literal free-delivery threshold upstream. A zero-fee band, when one
    // exists, is the closest real signal; otherwise we fall back to the
    // configured default. Flagged in README → Backend Gaps.
    final ranges = settings.objects('deliveryFeeRanges');
    final freeBand = ranges.where((r) => r.dbl('fee') <= 0);

    return (
      freeDeliveryThreshold: freeBand.isEmpty ? 199.0 : freeBand.first.dbl('max', 199),
      baseDeliveryFee: settings.dbl('deliveryFee'),
    );
  }
}
