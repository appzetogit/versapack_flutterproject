import 'package:quick_commerce_seller/features/orders/domain/order_model.dart';
import 'package:quick_commerce_seller/features/orders/domain/order_repository.dart';

class MockOrderRepository implements OrderRepository {
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ord_1',
      orderNumber: '#AZ123456',
      customer: const CustomerModel(
        name: 'Rahul Sharma',
        phone: '+91 98765 43210',
        address: 'B-402, Green Park Apartments, Sector 62, Noida',
        instructions: 'Please do not ring bell, leave at door.',
      ),
      items: const [
        OrderItemModel(
          id: 'item_1',
          name: 'Amul Taaza Toned Milk 1L',
          quantity: 2,
          price: 54.0,
        ),
        OrderItemModel(
          id: 'item_2',
          name: 'Harvest Gold Brown Bread 400g',
          quantity: 1,
          price: 45.0,
        ),
        OrderItemModel(
          id: 'item_3',
          name: 'Farm Fresh Organic Eggs (6 Pcs)',
          quantity: 1,
          price: 65.0,
        ),
      ],
      status: OrderStatus.newOrder,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      subtotal: 218.0,
      tax: 11.0,
      deliveryFee: 25.0,
      discount: 20.0,
      totalAmount: 234.0,
      paymentMethod: 'UPI (Paid)',
    ),
    OrderModel(
      id: 'ord_2',
      orderNumber: '#AZ123455',
      customer: const CustomerModel(
        name: 'Priya Mehta',
        phone: '+91 98123 45678',
        address: 'Flat 104, Sunrise Heights, Indirapuram, Ghaziabad',
      ),
      items: const [
        OrderItemModel(
          id: 'item_4',
          name: 'Fortune Sunlite Sunflower Oil 1L',
          quantity: 1,
          price: 145.0,
        ),
        OrderItemModel(
          id: 'item_5',
          name: 'Aashirvaad Shudh Chakki Atta 5kg',
          quantity: 1,
          price: 260.0,
        ),
      ],
      status: OrderStatus.newOrder,
      createdAt: DateTime.now().subtract(const Duration(minutes: 6)),
      subtotal: 405.0,
      tax: 20.0,
      deliveryFee: 0.0,
      discount: 50.0,
      totalAmount: 375.0,
      paymentMethod: 'Credit Card (Paid)',
    ),
    OrderModel(
      id: 'ord_3',
      orderNumber: '#AZ123454',
      customer: const CustomerModel(
        name: 'Vikram Singh',
        phone: '+91 97111 22334',
        address: 'House 88, Block C, Vaishali, Ghaziabad',
      ),
      items: const [
        OrderItemModel(
          id: 'item_6',
          name: 'Coca-Cola Zero Sugar 750ml',
          quantity: 2,
          price: 40.0,
        ),
        OrderItemModel(
          id: 'item_7',
          name: 'Lay\'s India\'s Magic Masala 50g',
          quantity: 3,
          price: 20.0,
        ),
      ],
      status: OrderStatus.preparing,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      subtotal: 140.0,
      tax: 7.0,
      deliveryFee: 15.0,
      discount: 0.0,
      totalAmount: 162.0,
      paymentMethod: 'UPI (Paid)',
      deliveryRiderName: 'Ramesh Kumar (Rider)',
      deliveryRiderPhone: '+91 99887 76655',
    ),
    OrderModel(
      id: 'ord_4',
      orderNumber: '#AZ123453',
      customer: const CustomerModel(
        name: 'Ananya Roy',
        phone: '+91 98990 11223',
        address: 'Villa 12, Express Garden, Sector 78, Noida',
      ),
      items: const [
        OrderItemModel(
          id: 'item_8',
          name: 'Cadbury Silk Fruit & Nut 150g',
          quantity: 2,
          price: 175.0,
        ),
      ],
      status: OrderStatus.ready,
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      subtotal: 350.0,
      tax: 18.0,
      deliveryFee: 20.0,
      discount: 30.0,
      totalAmount: 358.0,
      paymentMethod: 'COD',
      deliveryRiderName: 'Amit Verma (Rider)',
      deliveryRiderPhone: '+91 98222 33445',
    ),
    OrderModel(
      id: 'ord_5',
      orderNumber: '#AZ123450',
      customer: const CustomerModel(
        name: 'Siddharth Jain',
        phone: '+91 98711 00998',
        address: 'Tower A - 901, Cleo County, Sector 121, Noida',
      ),
      items: const [
        OrderItemModel(
          id: 'item_9',
          name: 'Tata Tea Gold 500g',
          quantity: 1,
          price: 320.0,
        ),
      ],
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      subtotal: 320.0,
      tax: 16.0,
      deliveryFee: 0.0,
      discount: 25.0,
      totalAmount: 311.0,
      paymentMethod: 'UPI (Paid)',
    ),
  ];

  @override
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_orders);
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _orders.firstWhere(
        (o) => o.id == orderId || o.orderNumber == orderId,
      );
    } catch (_) {
      return _orders.first;
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _orders.indexWhere(
      (o) => o.id == orderId || o.orderNumber == orderId,
    );
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
    }
  }

  @override
  Future<List<OrderModel>> getOrderHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _orders
        .where(
          (o) =>
              o.status == OrderStatus.delivered ||
              o.status == OrderStatus.cancelled,
        )
        .toList();
  }
}
