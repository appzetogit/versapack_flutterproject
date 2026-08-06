import 'package:quick_commerce_seller/features/explore/domain/explore_repository.dart';
import 'package:quick_commerce_seller/features/explore/domain/store_settings_model.dart';

class MockExploreRepository implements ExploreRepository {
  StoreProfileModel _profile = const StoreProfileModel(
    id: 'store_101',
    name: 'Fresh Mart Supermarket',
    description:
        'Your one-stop destination for daily groceries, dairy, and household essentials.',
    phone: '+91 98765 00112',
    email: 'contact@freshmart.com',
    address: 'Shop 12-14, Commercial Market, Sector 62, Noida, UP - 201301',
    fssaiLicense: '12721011000452',
    gstNumber: '09AABCF1234H1Z5',
    isOnline: true,
  );

  List<DayTimingModel> _timings = const [
    DayTimingModel(
      dayName: 'Monday',
      isOpen: true,
      openTime: '07:00 AM',
      closeTime: '11:00 PM',
    ),
    DayTimingModel(
      dayName: 'Tuesday',
      isOpen: true,
      openTime: '07:00 AM',
      closeTime: '11:00 PM',
    ),
    DayTimingModel(
      dayName: 'Wednesday',
      isOpen: true,
      openTime: '07:00 AM',
      closeTime: '11:00 PM',
    ),
    DayTimingModel(
      dayName: 'Thursday',
      isOpen: true,
      openTime: '07:00 AM',
      closeTime: '11:00 PM',
    ),
    DayTimingModel(
      dayName: 'Friday',
      isOpen: true,
      openTime: '07:00 AM',
      closeTime: '11:00 PM',
    ),
    DayTimingModel(
      dayName: 'Saturday',
      isOpen: true,
      openTime: '06:30 AM',
      closeTime: '11:30 PM',
    ),
    DayTimingModel(
      dayName: 'Sunday',
      isOpen: true,
      openTime: '06:30 AM',
      closeTime: '11:30 PM',
    ),
  ];

  DeliverySettingsModel _deliverySettings = const DeliverySettingsModel(
    deliveryRadiusKm: 5.0,
    minOrderValue: 99.0,
    packagingCharge: 15.0,
    isSelfDelivery: false,
    freeDeliveryThreshold: 499.0,
  );

  @override
  Future<StoreProfileModel> getStoreProfile() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _profile;
  }

  @override
  Future<void> updateStoreProfile(StoreProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _profile = profile;
  }

  @override
  Future<void> setStoreOnlineStatus(bool isOnline, {String reason = ''}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _profile = _profile.copyWith(isOnline: isOnline, offlineReason: reason);
  }

  @override
  Future<List<DayTimingModel>> getOutletTimings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_timings);
  }

  @override
  Future<void> updateOutletTimings(List<DayTimingModel> timings) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _timings = List.from(timings);
  }

  @override
  Future<DeliverySettingsModel> getDeliverySettings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _deliverySettings;
  }

  @override
  Future<void> updateDeliverySettings(DeliverySettingsModel settings) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _deliverySettings = settings;
  }
}
