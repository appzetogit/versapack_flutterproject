enum NotificationType { order, payout, system, offer }

class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String? targetRoute;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.targetRoute,
  });

  AppNotificationModel copyWith({bool? isRead}) {
    return AppNotificationModel(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
      targetRoute: targetRoute,
    );
  }
}

abstract class NotificationRepository {
  Future<List<AppNotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class MockNotificationRepository implements NotificationRepository {
  final List<AppNotificationModel> _notifications = [
    AppNotificationModel(
      id: 'notif_1',
      title: 'New Order Received! ⚡',
      body: 'Order #AZ123456 worth ₹234 received from Rahul Sharma.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: false,
      type: NotificationType.order,
      targetRoute: '/orders',
    ),
    AppNotificationModel(
      id: 'notif_2',
      title: 'Payout Processed Successfully 💰',
      body: '₹18,600.00 has been transferred to your HDFC bank account.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      type: NotificationType.payout,
      targetRoute: '/payouts',
    ),
    AppNotificationModel(
      id: 'notif_3',
      title: 'Stock Warning ⚠️',
      body: 'Coca-Cola Zero Sugar 750ml is out of stock.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      type: NotificationType.system,
      targetRoute: '/inventory',
    ),
    AppNotificationModel(
      id: 'notif_4',
      title: 'Weekly Performance Report 📊',
      body:
          'You fulfilled 184 orders with a 4.8 star customer rating this week!',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: NotificationType.system,
    ),
  ];

  @override
  Future<List<AppNotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_notifications);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 150));
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}
