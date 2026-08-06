import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_commerce_seller/core/providers/repository_providers.dart';
import 'package:quick_commerce_seller/features/orders/domain/order_model.dart';
import 'package:quick_commerce_seller/features/orders/domain/order_repository.dart';

final ordersControllerProvider =
    AsyncNotifierProvider<OrdersController, List<OrderModel>>(
      OrdersController.new,
    );

class OrdersController extends AsyncNotifier<List<OrderModel>> {
  late final OrderRepository _repository;

  @override
  Future<List<OrderModel>> build() async {
    _repository = ref.watch(orderRepositoryProvider);
    return _repository.getOrders();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getOrders());
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final previousState = state;
    state = await AsyncValue.guard(() async {
      await _repository.updateOrderStatus(orderId, status);
      return _repository.getOrders();
    });
    if (state.hasError) {
      state = previousState;
    }
  }
}

final newOrdersCountProvider = Provider<int>((ref) {
  final orders = ref.watch(ordersControllerProvider).value ?? [];
  return orders.where((o) => o.status == OrderStatus.newOrder).length;
});

final preparingOrdersCountProvider = Provider<int>((ref) {
  final orders = ref.watch(ordersControllerProvider).value ?? [];
  return orders.where((o) => o.status == OrderStatus.preparing).length;
});

final readyOrdersCountProvider = Provider<int>((ref) {
  final orders = ref.watch(ordersControllerProvider).value ?? [];
  return orders.where((o) => o.status == OrderStatus.ready).length;
});
