import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_commerce_seller/config/theme/app_palette.dart';
import 'package:quick_commerce_seller/features/analytics/data/api_analytics_repository.dart';
import 'package:quick_commerce_seller/features/analytics/domain/analytics_model.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final String _selectedDate = 'Today, 4 May';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: context.textPrimary,
              size: 26,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Inter',
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: 'app',
                    style: TextStyle(color: context.textPrimary),
                  ),
                  TextSpan(
                    text: 'zeto',
                    style: TextStyle(color: Color(0xFF0F9D58)),
                  ),
                ],
              ),
            ),
            Text(
              'Seller',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: context.textPrimary,
                  size: 26,
                ),
                onPressed: () => context.push('/notifications'),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header Title & Date Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Track your store performance',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFFC400),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: context.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedDate,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: context.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6 Performance Metric Cards (2 Grid columns)
              _buildMetricsGrid(
                ref
                    .watch(analyticsSummaryProvider)
                    .maybeWhen(
                      data: (s) => s,
                      orElse: () => const AnalyticsSummary.empty(),
                    ),
                isLoading: ref.watch(analyticsSummaryProvider).isLoading,
              ),
              const SizedBox(height: 16),

              // Sales Overview Chart Card
              _buildSalesOverviewCard(),
              const SizedBox(height: 16),

              // Top Selling Categories & Orders Overview Breakdown Cards
              _buildBreakdownCardsRow(),
              const SizedBox(height: 16),

              // Recent Orders List Card
              _buildRecentOrdersCard(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Renders an em dash while the figures are still loading, so the tiles never
  /// show a number that was not measured.
  String _money(double v, {required bool isLoading}) =>
      isLoading ? '—' : '₹${v.toStringAsFixed(2)}';

  String _count(int v, {required bool isLoading}) => isLoading ? '—' : '$v';

  /// Null means there was no previous period to compare with, which is not the
  /// same as no change.
  String _trend(double? percent, {required bool isLoading}) {
    if (isLoading) return ' ';
    if (percent == null) return 'No earlier period';
    final up = percent >= 0;
    return '${up ? '↑' : '↓'} ${percent.abs().toStringAsFixed(1)}% vs previous';
  }

  Widget _buildMetricsGrid(AnalyticsSummary s, {required bool isLoading}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                icon: Icons.shopping_bag_outlined,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                title: 'Total Sales',
                value: _money(s.totalSales, isLoading: isLoading),
                trend: _trend(s.salesTrendPercent, isLoading: isLoading),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.shopping_basket_outlined,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF059669),
                title: 'Total Orders',
                value: _count(s.totalOrders, isLoading: isLoading),
                trend: _trend(s.ordersTrendPercent, isLoading: isLoading),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.trending_up_rounded,
                iconBg: const Color(0xFFF5F3FF),
                iconColor: const Color(0xFF7C3AED),
                title: 'Average Order Value',
                value: _money(s.averageOrderValue, isLoading: isLoading),
                trend: _trend(null, isLoading: isLoading),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                icon: Icons.shopping_cart_outlined,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                title: 'Items Sold',
                value: _count(s.itemsSold, isLoading: isLoading),
                trend: _trend(null, isLoading: isLoading),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.person_add_alt_1_outlined,
                iconBg: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFEA580C),
                title: 'New Customers',
                value: _count(s.newCustomers, isLoading: isLoading),
                trend: _trend(null, isLoading: isLoading),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.people_outline_rounded,
                iconBg: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0284C7),
                title: 'Returning Customers',
                value: _count(s.returningCustomers, isLoading: isLoading),
                trend: _trend(null, isLoading: isLoading),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181C2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Sales Overview',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  children: [
                    Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: context.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total Sales',
            style: TextStyle(fontSize: 10, color: context.textSecondary),
          ),
          const SizedBox(height: 2),
          Wrap(
            spacing: 8,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '₹58,420.00',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: context.textPrimary,
                ),
              ),
              Icon(
                Icons.arrow_upward_rounded,
                size: 14,
                color: Color(0xFF10B981),
              ),
              Text(
                '16.3% vs Last Week',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Painted Line Chart Area with Y-Axis and Grid
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Row(
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹20K',
                      style: TextStyle(
                        fontSize: 9,
                        color: context.textSecondary,
                      ),
                    ),
                    Text(
                      '₹15K',
                      style: TextStyle(
                        fontSize: 9,
                        color: context.textSecondary,
                      ),
                    ),
                    Text(
                      '₹10K',
                      style: TextStyle(
                        fontSize: 9,
                        color: context.textSecondary,
                      ),
                    ),
                    Text(
                      '₹5K',
                      style: TextStyle(
                        fontSize: 9,
                        color: context.textSecondary,
                      ),
                    ),
                    Text(
                      '₹0',
                      style: TextStyle(
                        fontSize: 9,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _SalesLineChartPainter(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Mon',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Tue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Wed',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Thu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Fri',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Sat',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Sun',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCardsRow() {
    final categories = [
      {
        'name': 'Fruits & Vegetables',
        'amount': '₹18,450',
        'pct': '31.6%',
        'val': 0.316,
        'icon': Icons.lunch_dining_rounded,
      },
      {
        'name': 'Dairy & Eggs',
        'amount': '₹12,230',
        'pct': '20.9%',
        'val': 0.209,
        'icon': Icons.local_cafe_rounded,
      },
      {
        'name': 'Grocery & Staples',
        'amount': '₹10,850',
        'pct': '18.6%',
        'val': 0.186,
        'icon': Icons.shopping_bag_outlined,
      },
      {
        'name': 'Snacks & Munchies',
        'amount': '₹7,890',
        'pct': '13.5%',
        'val': 0.135,
        'icon': Icons.fastfood_rounded,
      },
      {
        'name': 'Beverages',
        'amount': '₹5,000',
        'pct': '8.6%',
        'val': 0.086,
        'icon': Icons.local_drink_rounded,
      },
      {
        'name': 'Personal Care',
        'amount': '₹4,000',
        'pct': '6.8%',
        'val': 0.068,
        'icon': Icons.sanitizer_rounded,
      },
    ];

    return Column(
      children: [
        // Top Selling Categories Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Top Selling Categories',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'This Week',
                          style: TextStyle(
                            fontSize: 10,
                            color: context.textPrimary,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 12,
                          color: context.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 16,
                              color: const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                cat['name'].toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              cat['amount'].toString(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['pct'].toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: cat['val'] as double,
                            backgroundColor: const Color(0xFFF3F4F6),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFC400),
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Orders Overview Card with Donut Chart
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Orders Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Donut Chart Area
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(140, 140),
                        painter: _OrdersDonutChartPainter(),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '48',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            'Total Orders',
                            style: TextStyle(
                              fontSize: 10,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Breakdown Legends List
              _buildDonutLegend(
                const Color(0xFF10B981),
                'Completed',
                '20 (41.7%)',
              ),
              const SizedBox(height: 6),
              _buildDonutLegend(
                const Color(0xFFFFC400),
                'Preparing',
                '12 (25.0%)',
              ),
              const SizedBox(height: 6),
              _buildDonutLegend(const Color(0xFF2563EB), 'Ready', '8 (16.7%)'),
              const SizedBox(height: 6),
              _buildDonutLegend(
                const Color(0xFF8B5CF6),
                'Cancelled',
                '4 (8.3%)',
              ),
              const SizedBox(height: 6),
              _buildDonutLegend(const Color(0xFF9CA3AF), 'Others', '4 (8.3%)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonutLegend(Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Expanded, so the inner Row has a bounded width for its Flexible
        // label. Without it the label sits under unbounded constraints and
        // flex is illegal.
        Expanded(
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersCard(BuildContext context) {
    final recent = [
      {
        'id': '#AZ12678',
        'customer': 'Rohit Sharma',
        'status': 'New',
        'statusBg': const Color(0xFFFEF3C7),
        'statusColor': const Color(0xFFD97706),
        'amount': '₹685.00',
        'items': '12 items',
        'stateText': 'Preparing',
        'stateColor': const Color(0xFFD97706),
        'time': '10:30 AM',
        'iconBg': const Color(0xFFFEF3C7),
        'iconColor': const Color(0xFFD97706),
      },
      {
        'id': '#AZ12677',
        'customer': 'Neha Verma',
        'status': 'Accepted',
        'statusBg': const Color(0xFFECFDF5),
        'statusColor': const Color(0xFF059669),
        'amount': '₹452.50',
        'items': '8 items',
        'stateText': 'Ready',
        'stateColor': const Color(0xFF2563EB),
        'time': '10:22 AM',
        'iconBg': const Color(0xFFECFDF5),
        'iconColor': const Color(0xFF059669),
      },
      {
        'id': '#AZ12676',
        'customer': 'Amit Patel',
        'status': 'Completed',
        'statusBg': const Color(0xFFECFDF5),
        'statusColor': const Color(0xFF059669),
        'amount': '₹299.00',
        'items': '6 items',
        'stateText': 'Completed',
        'stateColor': const Color(0xFF10B981),
        'time': '09:45 AM',
        'iconBg': const Color(0xFFECFDF5),
        'iconColor': const Color(0xFF10B981),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recent Orders',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/orders'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: recent.map((o) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.pageBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: o['iconBg'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.widgets_outlined,
                        color: o['iconColor'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                o['id'].toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: o['statusBg'] as Color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  o['status'].toString(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: o['statusColor'] as Color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            o['customer'].toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            o['amount'].toString(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            '${o['items']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            o['stateText'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: o['stateColor'] as Color,
                            ),
                          ),
                          Text(
                            o['time'].toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFFFC400)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Fresh Mart Superstore',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181C2E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Online • Quick Commerce Seller',
                  style: TextStyle(fontSize: 12, color: Color(0xFF181C2E)),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Color(0xFF181C2E)),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF181C2E),
            ),
            title: const Text('Orders'),
            onTap: () {
              Navigator.pop(context);
              context.go('/orders');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.bar_chart_rounded,
              color: Color(0xFFF59E0B),
            ),
            title: const Text(
              'Analytics',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFF59E0B),
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF181C2E),
            ),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              context.go('/products');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.widgets_outlined,
              color: Color(0xFF181C2E),
            ),
            title: const Text('Inventory'),
            onTap: () {
              Navigator.pop(context);
              context.go('/inventory');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF181C2E),
            ),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }
}

class _SalesLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.16, size.height * 0.65),
      Offset(size.width * 0.33, size.height * 0.45),
      Offset(size.width * 0.5, size.height * 0.55),
      Offset(size.width * 0.66, size.height * 0.38),
      Offset(size.width * 0.83, size.height * 0.12),
      Offset(size.width, size.height * 0.6),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFC400).withValues(alpha: 0.35),
          const Color(0xFFFFC400).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFFFFC400)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = const Color(0xFFFFC400);
    final innerDotPaint = Paint()..color = Colors.white;

    for (final pt in points) {
      canvas.drawCircle(pt, 4.5, dotPaint);
      canvas.drawCircle(pt, 2, innerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrdersDonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    double startAngle = -math.pi / 2;

    final slices = [
      {'sweep': 2 * math.pi * 0.417, 'color': const Color(0xFF10B981)},
      {'sweep': 2 * math.pi * 0.250, 'color': const Color(0xFFFFC400)},
      {'sweep': 2 * math.pi * 0.167, 'color': const Color(0xFF2563EB)},
      {'sweep': 2 * math.pi * 0.083, 'color': const Color(0xFF8B5CF6)},
      {'sweep': 2 * math.pi * 0.083, 'color': const Color(0xFF9CA3AF)},
    ];

    for (final slice in slices) {
      paint.color = slice['color'] as Color;
      final sweepAngle = slice['sweep'] as double;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.04,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
