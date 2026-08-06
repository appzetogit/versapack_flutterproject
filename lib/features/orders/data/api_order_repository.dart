import 'package:dio/dio.dart';
import 'package:quick_commerce_seller/features/orders/domain/order_model.dart';
import 'package:quick_commerce_seller/features/orders/domain/order_repository.dart';

/// Orders for the signed-in seller, from `/food/restaurant/orders`.
///
/// The backend's lifecycle is longer than the five states this app shows, so
/// the mapping below is deliberately lossy: everything after the food leaves
/// the counter is one `delivered`-facing bucket as far as a seller is
/// concerned, because none of it is theirs to act on.
class ApiOrderRepository implements OrderRepository {
  const ApiOrderRepository(this._dio);

  final Dio _dio;

  /// Statuses the seller still has something to do about.
  static const _activeStatuses = 'created,confirmed,preparing,ready_for_pickup';

  /// Statuses that are finished from the seller's point of view.
  static const _historyStatuses =
      'reached_pickup,picked_up,reached_drop,delivered,'
      'cancelled_by_user,cancelled_by_restaurant,cancelled_by_admin';

  @override
  Future<List<OrderModel>> getOrders() => _list(status: _activeStatuses);

  @override
  Future<List<OrderModel>> getOrderHistory() => _list(status: _historyStatuses);

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final response = await _dio.get<dynamic>('/food/restaurant/orders/$orderId');
    final data = response.data;
    if (data is! Map) return null;
    // The single-order route wraps its payload one level deeper than the list.
    final raw = data['order'] is Map ? data['order'] : data;
    return _toOrder(Map<String, dynamic>.from(raw as Map));
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _dio.patch<dynamic>(
      '/food/restaurant/orders/$orderId/status',
      // The field is `orderStatus`; a plain `status` is rejected by the schema.
      data: {'orderStatus': _toWireStatus(status)},
    );
  }

  Future<List<OrderModel>> _list({required String status}) async {
    final response = await _dio.get<dynamic>(
      '/food/restaurant/orders',
      queryParameters: {'status': status, 'limit': 50},
    );

    final data = response.data;
    if (data is! Map) return const [];

    // This endpoint returns the same list under both `orders` and `data`.
    // Reading whichever is present keeps the app working if one is retired.
    final list = data['orders'] ?? data['data'];
    if (list is! List) return const [];

    return list
        .whereType<Map>()
        .map((e) => _toOrder(Map<String, dynamic>.from(e)))
        .toList();
  }

  OrderModel _toOrder(Map<String, dynamic> json) {
    final pricing = _asMap(json['pricing']);
    final address = _asMap(json['deliveryAddress']);
    final payment = _asMap(json['payment']);
    final dispatch = _asMap(json['dispatch']);
    final partner = _asMap(dispatch['deliveryPartnerId']);

    return OrderModel(
      id: (json['_id'] ?? json['orderMongoId'] ?? '').toString(),
      // The human-facing reference, not the Mongo id.
      orderNumber: (json['order_id'] ?? json['orderId'] ?? '').toString(),
      customer: CustomerModel(
        name: _firstNonEmpty([
          json['customerName'],
          address['fullName'],
          address['name'],
        ], fallback: 'Customer'),
        phone: _firstNonEmpty([json['customerPhone'], address['phone']]),
        address: _formatAddress(address),
        instructions: _nullIfEmpty(json['deliveryInstructions']),
      ),
      items: _asList(json['items'])
          .map(
            (e) => OrderItemModel(
              id: (e['itemId'] ?? '').toString(),
              name: (e['name'] ?? '').toString(),
              quantity: _asNum(e['quantity'])?.toInt() ?? 1,
              price: _asNum(e['price'])?.toDouble() ?? 0,
              // Pack size reads as the variant on a grocery line; a genuine
              // variant name wins when the product has one.
              variant: _nullIfEmpty(e['variantName']) ?? _nullIfEmpty(e['packSize']),
              addons: _asList(e['addons'])
                  .map((a) => (a['name'] ?? '').toString())
                  .where((s) => s.isNotEmpty)
                  .toList(),
            ),
          )
          .toList(),
      status: _fromWireStatus((json['orderStatus'] ?? json['status'] ?? '').toString()),
      createdAt: _asDate(json['createdAt']),
      subtotal: _asNum(pricing['subtotal'])?.toDouble() ?? 0,
      // Both tax lines are the seller's tax; showing only one under-reports it.
      tax: (_asNum(pricing['tax'])?.toDouble() ?? 0) +
          (_asNum(pricing['deliveryFeeGst'])?.toDouble() ?? 0),
      deliveryFee: _asNum(pricing['deliveryFee'])?.toDouble() ?? 0,
      discount: _asNum(pricing['discount'])?.toDouble() ?? 0,
      totalAmount: _asNum(pricing['total'])?.toDouble() ?? 0,
      paymentMethod: (payment['method'] ?? 'cash').toString(),
      deliveryRiderName: _nullIfEmpty(partner['name'] ?? partner['fullName']),
      deliveryRiderPhone: _nullIfEmpty(partner['phone']),
    );
  }

  /// Backend lifecycle → the five states this app draws.
  ///
  /// `created` is an order the seller has not answered yet, which is what the
  /// New tab is for. Everything from pickup onward is out of their hands, so it
  /// collapses into `delivered` rather than inventing screens for states a
  /// seller cannot influence.
  static OrderStatus _fromWireStatus(String wire) {
    switch (wire) {
      case 'created':
      case 'pending_payment':
        return OrderStatus.newOrder;
      case 'confirmed':
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready_for_pickup':
      case 'ready':
        return OrderStatus.ready;
      case 'cancelled_by_user':
      case 'cancelled_by_restaurant':
      case 'cancelled_by_admin':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.delivered;
    }
  }

  /// Only the transitions a seller is allowed to make have a wire value.
  static String _toWireStatus(OrderStatus status) {
    switch (status) {
      // Moving an order *to* newOrder is the act of accepting it.
      case OrderStatus.newOrder:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.ready:
        return 'ready_for_pickup';
      case OrderStatus.cancelled:
        return 'cancelled_by_restaurant';
      case OrderStatus.delivered:
        return 'delivered';
    }
  }

  static String _formatAddress(Map<String, dynamic> a) => [
    a['street'],
    a['additionalDetails'],
    a['city'],
    a['state'],
    a['zipCode'],
  ].map((e) => (e ?? '').toString().trim()).where((s) => s.isNotEmpty).join(', ');

  static Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  static List<Map<String, dynamic>> _asList(dynamic v) => v is List
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : const [];

  static num? _asNum(dynamic v) =>
      v is num ? v : num.tryParse((v ?? '').toString());

  static DateTime _asDate(dynamic v) =>
      DateTime.tryParse((v ?? '').toString())?.toLocal() ?? DateTime.now();

  static String? _nullIfEmpty(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }

  static String _firstNonEmpty(List<dynamic> values, {String fallback = ''}) {
    for (final v in values) {
      final s = (v ?? '').toString().trim();
      if (s.isNotEmpty) return s;
    }
    return fallback;
  }
}
