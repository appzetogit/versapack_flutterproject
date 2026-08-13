import 'package:flutter_test/flutter_test.dart';
import 'package:quick_commerce_user/core/extensions/num_extensions.dart';
import 'package:quick_commerce_user/core/network/media_url.dart';
import 'package:quick_commerce_user/core/network/share_links.dart';

void main() {
  group('delivery promise formatting', () {
    test('sub-hour promises stay in minutes', () {
      expect(12.asDurationLabel, '12 mins');
      expect(59.asDurationLabel, '59 mins');
    });

    test('an hour or more reads as hours', () {
      expect(60.asDurationLabel, '1 hr');
      expect(95.asDurationLabel, '1 hr 35 mins');
    });

    // The case that started this: a drop far outside the serving area priced at
    // 3712 minutes, which rendered as "Arrives in 3712 mins".
    test('multi-day promises read as days, not thousands of minutes', () {
      expect(3712.asDurationLabel, '2 days 13 hr');
      expect(2880.asDurationLabel, '2 days');
    });
  });

  group('share links', () {
    setUp(() => MediaUrl.configure('https://quick.appzeto.com/api/v1'));

    test('product links are https to the backend OG page, not a custom scheme', () {
      final url = ShareLinks.product(productId: 'abc123', sellerId: 'seller1');
      expect(url, startsWith('https://quick.appzeto.com/food-detail?'));
      expect(url, contains('id=abc123'));
      expect(url, contains('restaurantId=seller1'));
      expect(url, isNot(contains('://product/')));
    });

    test('a product with no seller still yields a usable link', () {
      final url = ShareLinks.product(productId: 'abc123');
      expect(url, 'https://quick.appzeto.com/food-detail?id=abc123');
    });

    test('seller links point at the restaurant page', () {
      expect(
        ShareLinks.seller('s99'),
        'https://quick.appzeto.com/restaurant-detail/s99',
      );
    });
  });
}
