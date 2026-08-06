import 'package:quick_commerce_seller/features/offers/domain/offer_model.dart';
import 'package:quick_commerce_seller/features/offers/domain/offer_repository.dart';

class MockOfferRepository implements OfferRepository {
  final List<CouponModel> _coupons = [
    CouponModel(
      id: 'c_1',
      code: 'WELCOME50',
      title: '50% OFF on First Order',
      description: 'Get 50% discount up to ₹100 on orders above ₹199.',
      discountType: DiscountType.percentage,
      discountValue: 50.0,
      minOrderAmount: 199.0,
      maxDiscountAmount: 100.0,
      validFrom: DateTime.now().subtract(const Duration(days: 10)),
      validTill: DateTime.now().add(const Duration(days: 20)),
      usageCount: 142,
      isActive: true,
    ),
    CouponModel(
      id: 'c_2',
      code: 'FLAT50',
      title: 'Flat ₹50 OFF',
      description: 'Flat ₹50 savings on any purchase above ₹349.',
      discountType: DiscountType.fixedAmount,
      discountValue: 50.0,
      minOrderAmount: 349.0,
      validFrom: DateTime.now().subtract(const Duration(days: 5)),
      validTill: DateTime.now().add(const Duration(days: 15)),
      usageCount: 89,
      isActive: true,
    ),
    CouponModel(
      id: 'c_3',
      code: 'WEEKEND20',
      title: '20% OFF Weekend Special',
      description: 'Special 20% discount up to ₹75 on weekend orders.',
      discountType: DiscountType.percentage,
      discountValue: 20.0,
      minOrderAmount: 299.0,
      maxDiscountAmount: 75.0,
      validFrom: DateTime.now().subtract(const Duration(days: 30)),
      validTill: DateTime.now().subtract(const Duration(days: 2)),
      usageCount: 310,
      isActive: false,
    ),
  ];

  @override
  Future<List<CouponModel>> getCoupons() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_coupons);
  }

  @override
  Future<void> toggleCouponActive(String couponId, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _coupons.indexWhere((c) => c.id == couponId);
    if (index != -1) {
      _coupons[index] = _coupons[index].copyWith(isActive: isActive);
    }
  }

  @override
  Future<void> createCoupon(CouponModel coupon) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _coupons.insert(0, coupon);
  }

  @override
  Future<void> deleteCoupon(String couponId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _coupons.removeWhere((c) => c.id == couponId);
  }
}
