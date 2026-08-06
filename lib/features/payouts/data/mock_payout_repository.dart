import 'package:quick_commerce_seller/features/payouts/domain/payout_model.dart';
import 'package:quick_commerce_seller/features/payouts/domain/payout_repository.dart';

class MockPayoutRepository implements PayoutRepository {
  BankDetailsModel _bankDetails = const BankDetailsModel(
    accountHolderName: 'Fresh Mart Supermarket Pvt Ltd',
    accountNumber: '98765432101234',
    ifscCode: 'HDFC0001234',
    bankName: 'HDFC Bank',
    branchName: 'Sector 18, Noida',
    upiId: 'freshmart@hdfcbank',
    isVerified: true,
  );

  PayoutSummaryModel _summary = PayoutSummaryModel(
    totalEarnings: 148250.0,
    availableBalance: 12450.0,
    pendingPayout: 3200.0,
    lastPayoutAmount: 18600.0,
    lastPayoutDate: DateTime.now().subtract(const Duration(days: 3)),
  );

  final List<PayoutTransactionModel> _transactions = [
    PayoutTransactionModel(
      id: 'tx_1',
      referenceNumber: 'PAY-8823190',
      amount: 18600.0,
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: PayoutStatus.completed,
      payoutMethod: 'Direct Bank Transfer',
    ),
    PayoutTransactionModel(
      id: 'tx_2',
      referenceNumber: 'PAY-7712304',
      amount: 22400.0,
      date: DateTime.now().subtract(const Duration(days: 10)),
      status: PayoutStatus.completed,
      payoutMethod: 'Direct Bank Transfer',
    ),
    PayoutTransactionModel(
      id: 'tx_3',
      referenceNumber: 'PAY-6651209',
      amount: 15300.0,
      date: DateTime.now().subtract(const Duration(days: 17)),
      status: PayoutStatus.completed,
      payoutMethod: 'UPI Instant Payout',
    ),
  ];

  @override
  Future<PayoutSummaryModel> getPayoutSummary() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _summary;
  }

  @override
  Future<List<PayoutTransactionModel>> getPayoutTransactions() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_transactions);
  }

  @override
  Future<BankDetailsModel> getBankDetails() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _bankDetails;
  }

  @override
  Future<void> updateBankDetails(BankDetailsModel bankDetails) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _bankDetails = bankDetails;
  }

  @override
  Future<bool> requestInstantPayout(double amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (amount <= _summary.availableBalance) {
      final newTransaction = PayoutTransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        referenceNumber:
            'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        amount: amount,
        date: DateTime.now(),
        status: PayoutStatus.processing,
        payoutMethod: 'Instant Payout',
      );
      _transactions.insert(0, newTransaction);
      _summary = PayoutSummaryModel(
        totalEarnings: _summary.totalEarnings,
        availableBalance: _summary.availableBalance - amount,
        pendingPayout: _summary.pendingPayout + amount,
        lastPayoutAmount: _summary.lastPayoutAmount,
        lastPayoutDate: _summary.lastPayoutDate,
      );
      return true;
    }
    return false;
  }
}
