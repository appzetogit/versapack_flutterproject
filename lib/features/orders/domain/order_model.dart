enum OrderStatus { newOrder, preparing, ready, delivered, cancelled }

class OrderItemModel {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String? variant;
  final List<String> addons;

  const OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.variant,
    this.addons = const [],
  });

  double get totalPrice => price * quantity;
}

class CustomerModel {
  final String name;
  final String phone;
  final String address;
  final String? instructions;

  const CustomerModel({
    required this.name,
    required this.phone,
    required this.address,
    this.instructions,
  });
}

class OrderModel {
  final String id;
  final String orderNumber;
  final CustomerModel customer;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final DateTime createdAt;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final String paymentMethod;
  final String? deliveryRiderName;
  final String? deliveryRiderPhone;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customer,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.discount,
    required this.totalAmount,
    required this.paymentMethod,
    this.deliveryRiderName,
    this.deliveryRiderPhone,
  });

  OrderModel copyWith({
    OrderStatus? status,
    String? deliveryRiderName,
    String? deliveryRiderPhone,
  }) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      customer: customer,
      items: items,
      status: status ?? this.status,
      createdAt: createdAt,
      subtotal: subtotal,
      tax: tax,
      deliveryFee: deliveryFee,
      discount: discount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      deliveryRiderName: deliveryRiderName ?? this.deliveryRiderName,
      deliveryRiderPhone: deliveryRiderPhone ?? this.deliveryRiderPhone,
    );
  }
}
