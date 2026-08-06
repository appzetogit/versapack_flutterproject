import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_commerce_seller/core/network/dio_client.dart';
import 'package:quick_commerce_seller/features/complaints/domain/complaint_model.dart';
import 'package:quick_commerce_seller/features/explore/data/api_explore_repository.dart';
import 'package:quick_commerce_seller/features/explore/domain/explore_repository.dart';
import 'package:quick_commerce_seller/features/feedback/domain/feedback_model.dart';
import 'package:quick_commerce_seller/features/inventory/data/api_inventory_repository.dart';
import 'package:quick_commerce_seller/features/inventory/domain/inventory_repository.dart';
import 'package:quick_commerce_seller/features/notifications/domain/notification_model.dart';
import 'package:quick_commerce_seller/features/offers/data/mock_offer_repository.dart';
import 'package:quick_commerce_seller/features/offers/domain/offer_repository.dart';
import 'package:quick_commerce_seller/features/orders/data/api_order_repository.dart';
import 'package:quick_commerce_seller/features/orders/domain/order_repository.dart';
import 'package:quick_commerce_seller/features/payouts/data/mock_payout_repository.dart';
import 'package:quick_commerce_seller/features/payouts/domain/payout_repository.dart';

/// Centralized Dependency Injection Repository Providers.
///
/// Note: To integrate with real backend API services in Phase 2,
/// replace the return statements here with production API repository implementations
/// (e.g. `HttpOrderRepository(ref.watch(dioProvider))`).

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return ApiOrderRepository(ref.watch(dioProvider));
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return ApiInventoryRepository(ref.watch(dioProvider));
});

final payoutRepositoryProvider = Provider<PayoutRepository>((ref) {
  return MockPayoutRepository();
});

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return MockOfferRepository();
});

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ApiExploreRepository(ref.watch(dioProvider));
});

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return MockComplaintRepository();
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return MockFeedbackRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepository();
});
