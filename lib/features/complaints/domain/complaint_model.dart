enum ComplaintStatus { open, resolved, rejected }

class ComplaintModel {
  final String id;
  final String orderId;
  final String customerName;
  final String issueType;
  final String description;
  final DateTime createdAt;
  final ComplaintStatus status;
  final double refundAmountRequested;
  final String? sellerResponse;

  const ComplaintModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.issueType,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.refundAmountRequested,
    this.sellerResponse,
  });

  ComplaintModel copyWith({ComplaintStatus? status, String? sellerResponse}) {
    return ComplaintModel(
      id: id,
      orderId: orderId,
      customerName: customerName,
      issueType: issueType,
      description: description,
      createdAt: createdAt,
      status: status ?? this.status,
      refundAmountRequested: refundAmountRequested,
      sellerResponse: sellerResponse ?? this.sellerResponse,
    );
  }
}

abstract class ComplaintRepository {
  Future<List<ComplaintModel>> getComplaints();
  Future<void> resolveComplaint(String complaintId, String responseText);
  Future<void> rejectComplaint(String complaintId, String reason);
}

class MockComplaintRepository implements ComplaintRepository {
  final List<ComplaintModel> _complaints = [
    ComplaintModel(
      id: 'cmp_1',
      orderId: '#AZ123440',
      customerName: 'Karan Mehra',
      issueType: 'Missing / Damaged Item',
      description: 'One milk packet was leaked during transit.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      status: ComplaintStatus.open,
      refundAmountRequested: 54.0,
    ),
    ComplaintModel(
      id: 'cmp_2',
      orderId: '#AZ123438',
      customerName: 'Shalini Verma',
      issueType: 'Delayed Delivery',
      description: 'Order arrived 25 minutes past promised delivery time.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: ComplaintStatus.resolved,
      refundAmountRequested: 0.0,
      sellerResponse:
          'Apologized for delay and issued ₹50 wallet cashback voucher.',
    ),
  ];

  @override
  Future<List<ComplaintModel>> getComplaints() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_complaints);
  }

  @override
  Future<void> resolveComplaint(String complaintId, String responseText) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index != -1) {
      _complaints[index] = _complaints[index].copyWith(
        status: ComplaintStatus.resolved,
        sellerResponse: responseText,
      );
    }
  }

  @override
  Future<void> rejectComplaint(String complaintId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index != -1) {
      _complaints[index] = _complaints[index].copyWith(
        status: ComplaintStatus.rejected,
        sellerResponse: reason,
      );
    }
  }
}
