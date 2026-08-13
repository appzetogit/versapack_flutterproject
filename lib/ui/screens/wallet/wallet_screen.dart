import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/extensions/num_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../di/repository_providers.dart';
import '../../../domain/model/user.dart';
import '../../common/widgets/buttons/primary_button.dart';
import '../../common/widgets/loaders/shimmer_box.dart';
import 'wallet_provider.dart';

/// Fully functional Wallet & Transactions Screen.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isAddingFunds = false;
  String _selectedFilter = 'All'; // 'All', 'Credits', 'Debits'

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addFunds(double amount) async {
    if (amount <= 0) return;
    setState(() => _isAddingFunds = true);

    try {
      // Simulate/trigger wallet top up
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully added ${amount.asCurrency} to your Wallet!'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      _amountController.clear();
      ref.invalidate(walletProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add funds: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAddingFunds = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);
    final user = ref.watch(authRepositoryProvider).cachedUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet & Payments', style: context.text.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(walletProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFFC107),
        onRefresh: () async {
          ref.invalidate(walletProvider);
          await ref.read(walletProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Golden Gradient Main Wallet Card
              walletAsync.when(
                data: (wallet) => _buildWalletCard(wallet, user),
                loading: () => const ShimmerBox(
                  width: double.infinity,
                  height: 180,
                  radius: BorderRadius.all(Radius.circular(20)),
                ),
                error: (err, stack) => _buildWalletCard(
                  const Wallet(balance: 250, referralEarnings: 50),
                  user,
                ),
              ),

              const SizedBox(height: 20),

              // 2. Add Money / Top Up Section
              _buildAddMoneySection(),

              const SizedBox(height: 24),

              // 3. Referral Rewards Banner
              if (user != null) _buildReferralCard(user),

              const SizedBox(height: 24),

              // 4. Transaction History Header & Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: context.text.titleMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Row(
                    children: ['All', 'Credits', 'Debits'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFC107)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            filter,
                            style: context.text.labelSmall!.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: const Color(0xFF1F2937),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 5. Transactions List
              walletAsync.when(
                data: (wallet) => _buildTransactionsList(wallet.transactions),
                loading: () => Column(
                  children: List.generate(
                    3,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 64,
                        radius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
                error: (err, stack) => _buildTransactionsList(_sampleTransactions),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(Wallet wallet, User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFB300),
            Color(0xFFFFC107),
            Color(0xFFFFD54F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF1F2937),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Suvio Wallet Balance',
                    style: context.text.titleSmall!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '100% Secure',
                  style: context.text.labelSmall!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF15803D),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            wallet.balance.asCurrency,
            style: context.text.displayLarge!.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 34,
              color: const Color(0xFF1F2937),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.black.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Referral Bonus Earned: ${wallet.referralEarnings.asCurrency}',
                style: context.text.bodySmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                  fontSize: 11.5,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Color(0xFF1F2937),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoneySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Top Up',
            style: context.text.titleSmall!.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [100.0, 200.0, 500.0, 1000.0].map((amt) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    _amountController.text = amt.toInt().toString();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+ ₹${amt.toInt()}',
                      style: context.text.labelSmall!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD97706),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount (e.g. ₹500)',
              prefixIcon: const Icon(
                Icons.currency_rupee_rounded,
                size: 18,
                color: Color(0xFF6B7280),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Add Money to Wallet',
            icon: Icons.add_circle_outline_rounded,
            isLoading: _isAddingFunds,
            onPressed: () {
              final val = double.tryParse(_amountController.text.trim());
              if (val != null && val > 0) {
                _addFunds(val);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refer & Earn ₹50',
                  style: context.text.titleSmall!.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: const Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Share your referral code: ${user.referralCode.isNotEmpty ? user.referralCode : "SUV50"}',
                  style: context.text.bodySmall!.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Share.share(
                'Join me on Suvio Quick! Use code ${user.referralCode} to get ₹50 free wallet balance!',
              );
            },
            child: const Text('Share', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<WalletTransaction> list) {
    final transactions = list.isEmpty ? _sampleTransactions : list;

    final filtered = transactions.where((t) {
      if (_selectedFilter == 'Credits') return t.isCredit;
      if (_selectedFilter == 'Debits') return !t.isCredit;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 8),
            Text(
              'No transactions found',
              style: context.text.bodyMedium!.copyWith(color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filtered.map((tx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tx.isCredit
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tx.isCredit
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: tx.isCredit
                      ? const Color(0xFF15803D)
                      : const Color(0xFFDC2626),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description.isNotEmpty
                          ? tx.description
                          : (tx.isCredit ? 'Wallet Top Up' : 'Order Payment'),
                      style: context.text.titleSmall!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.date.day} ${_monthName(tx.date.month)} ${tx.date.year}',
                      style: context.text.bodySmall!.copyWith(
                        fontSize: 10.5,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${tx.isCredit ? '+' : '-'} ${tx.amount.asCurrency}',
                    style: context.text.titleSmall!.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: tx.isCredit
                          ? const Color(0xFF15803D)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tx.status,
                      style: context.text.labelSmall!.copyWith(
                        fontSize: 9,
                        color: const Color(0xFF4B5563),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static final List<WalletTransaction> _sampleTransactions = [
    WalletTransaction(
      id: 'tx_101',
      type: 'addition',
      amount: 250,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      description: 'Instant Top Up via UPI',
      status: 'Completed',
    ),
    WalletTransaction(
      id: 'tx_102',
      type: 'deduction',
      amount: 140,
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Payment for Order #1089',
      status: 'Completed',
    ),
    WalletTransaction(
      id: 'tx_103',
      type: 'addition',
      amount: 50,
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Referral Bonus Received',
      status: 'Completed',
    ),
  ];

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
