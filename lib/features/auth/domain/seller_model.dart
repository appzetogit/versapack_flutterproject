/// The signed-in seller (a `RESTAURANT` in the backend's vocabulary).
///
/// Parsing is totally defensive: every field has a fallback so a payload that
/// drifts can never throw inside a controller. Plain Dart — no Flutter,
/// Riverpod, or Dio imports.
class SellerModel {
  const SellerModel({
    required this.id,
    required this.name,
    required this.storeName,
    required this.phone,
    required this.email,
    required this.status,
    required this.imageUrl,
    required this.isAcceptingOrders,
    required this.rating,
    required this.totalRatings,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v is num ? v : num.tryParse((v ?? '').toString());

    return SellerModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      // The backend exposes the store under `restaurantName` and falls back to
      // `name` for older records.
      storeName: (json['restaurantName'] ?? json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      imageUrl: (json['profileImage'] ?? json['image'] ?? '').toString(),
      // Absent means the store is not taking orders — the safer default.
      isAcceptingOrders: json['isAcceptingOrders'] == true,
      rating: asNum(json['rating'])?.toDouble() ?? 0,
      totalRatings: asNum(json['totalRatings'])?.toInt() ?? 0,
    );
  }

  final String id;
  final String name;
  final String storeName;
  final String phone;
  final String email;

  /// One of `pending`, `approved`, `rejected` per the backend's enum.
  final String status;
  final String imageUrl;
  final bool isAcceptingOrders;
  final double rating;
  final int totalRatings;

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  /// What to show as the store's title, never empty.
  String get displayName =>
      storeName.isNotEmpty ? storeName : (name.isNotEmpty ? name : 'My store');
}
