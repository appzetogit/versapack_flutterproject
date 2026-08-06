class FeedbackModel {
  final String id;
  final String customerName;
  final double rating;
  final String reviewText;
  final DateTime createdAt;
  final String? sellerReply;
  final String orderId;

  const FeedbackModel({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
    this.sellerReply,
    required this.orderId,
  });

  FeedbackModel copyWith({String? sellerReply}) {
    return FeedbackModel(
      id: id,
      customerName: customerName,
      rating: rating,
      reviewText: reviewText,
      createdAt: createdAt,
      sellerReply: sellerReply ?? this.sellerReply,
      orderId: orderId,
    );
  }
}

abstract class FeedbackRepository {
  Future<List<FeedbackModel>> getFeedbackList();
  Future<void> replyToFeedback(String feedbackId, String reply);
}

class MockFeedbackRepository implements FeedbackRepository {
  final List<FeedbackModel> _feedbackList = [
    FeedbackModel(
      id: 'fb_1',
      customerName: 'Sunita Rao',
      rating: 5.0,
      reviewText: 'Super fast delivery! All dairy items were cold and fresh.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      orderId: '#AZ123448',
    ),
    FeedbackModel(
      id: 'fb_2',
      customerName: 'Deepak Patel',
      rating: 4.0,
      reviewText: 'Good quality items. Packaging was very neat.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      sellerReply: 'Thank you for your valuable feedback, Deepak!',
      orderId: '#AZ123422',
    ),
    FeedbackModel(
      id: 'fb_3',
      customerName: 'Neha Gupta',
      rating: 2.0,
      reviewText:
          'Bread was close to expiry date. Please check dates before packing.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      orderId: '#AZ123410',
    ),
  ];

  @override
  Future<List<FeedbackModel>> getFeedbackList() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_feedbackList);
  }

  @override
  Future<void> replyToFeedback(String feedbackId, String reply) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _feedbackList.indexWhere((f) => f.id == feedbackId);
    if (index != -1) {
      _feedbackList[index] = _feedbackList[index].copyWith(sellerReply: reply);
    }
  }
}
