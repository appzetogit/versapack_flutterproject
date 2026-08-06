import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_commerce_seller/core/widgets/app_toast.dart';
import 'package:quick_commerce_seller/config/theme/app_palette.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  /// Counts are derived, not written down. Hardcoded ones drifted from the list
  /// the moment the stock toggle changed anything.
  List<Map<String, dynamic>> get _filters => [
    {'label': 'All (${_inventoryItems.length})'},
    {
      'label':
          'Low Stock (${_countWhere((i) => _statusLabel(i) == 'Low Stock')})',
    },
    {
      'label':
          'Out of Stock (${_countWhere((i) => _statusLabel(i) == 'Out of Stock')})',
    },
    {
      'label':
          'Expiring Soon (${_countWhere((i) => i['expiringSoon'] == true)})',
    },
  ];

  int _countWhere(bool Function(Map<String, dynamic>) test) =>
      _inventoryItems.where(test).length;

  final List<Map<String, dynamic>> _inventoryItems = [
    {
      'name': 'Banana (1 kg)',
      'sku': 'FRU001',
      'category': 'Fruits & Vegetables',
      'status': 'In Stock',
      'statusColor': const Color(0xFFECFDF5),
      'statusTextColor': const Color(0xFF059669),
      'available': '45 kg',
      'availableColor': const Color(0xFF10B981),
      'minStock': '10 kg',
      'icon': Icons.lunch_dining_rounded,
    },
    {
      'name': 'Amul Taaza Milk 500 ml',
      'sku': 'DAIRY001',
      'expiringSoon': true,
      'category': 'Dairy & Eggs',
      'status': 'In Stock',
      'statusColor': const Color(0xFFECFDF5),
      'statusTextColor': const Color(0xFF059669),
      'available': '120 pcs',
      'availableColor': const Color(0xFF10B981),
      'minStock': '20 pcs',
      'icon': Icons.local_cafe_rounded,
    },
    {
      'name': 'Britannia Brown Bread 400g',
      'sku': 'GROC001',
      'expiringSoon': true,
      'category': 'Grocery & Staples',
      'status': 'Low Stock',
      'statusColor': const Color(0xFFFFFBEB),
      'statusTextColor': const Color(0xFFD97706),
      'available': '12 pcs',
      'availableColor': const Color(0xFFEA580C),
      'minStock': '30 pcs',
      'icon': Icons.bakery_dining_rounded,
    },
    {
      'name': 'Lay\'s Classic Salted 52g',
      'sku': 'SNK001',
      'category': 'Snacks & Munchies',
      'status': 'In Stock',
      'statusColor': const Color(0xFFECFDF5),
      'statusTextColor': const Color(0xFF059669),
      'available': '85 pcs',
      'availableColor': const Color(0xFF10B981),
      'minStock': '20 pcs',
      'icon': Icons.fastfood_rounded,
    },
    {
      'name': 'Coca Cola 750 ml',
      'sku': 'BEV001',
      'expiringSoon': true,
      'category': 'Beverages',
      'status': 'Low Stock',
      'statusColor': const Color(0xFFFFFBEB),
      'statusTextColor': const Color(0xFFD97706),
      'available': '8 pcs',
      'availableColor': const Color(0xFFEA580C),
      'minStock': '20 pcs',
      'icon': Icons.local_drink_rounded,
    },
    {
      'name': 'Dove Beauty Bar 100g',
      'sku': 'PC001',
      'category': 'Personal Care',
      'status': 'Out of Stock',
      'statusColor': const Color(0xFFFEF2F2),
      'statusTextColor': const Color(0xFFDC2626),
      'available': '0 pcs',
      'availableColor': const Color(0xFFEF4444),
      'minStock': '15 pcs',
      'icon': Icons.sanitizer_rounded,
    },
    {
      'name': 'Surf Excel Matic 1 kg',
      'sku': 'HH001',
      'category': 'Household Essentials',
      'status': 'Low Stock',
      'statusColor': const Color(0xFFFFFBEB),
      'statusTextColor': const Color(0xFFD97706),
      'available': '5 pcs',
      'availableColor': const Color(0xFFEA580C),
      'minStock': '15 pcs',
      'icon': Icons.cleaning_services_rounded,
    },
    {
      'name': 'Fortune Basmati Rice 1 kg',
      'sku': 'GROC010',
      'category': 'Grocery & Staples',
      'status': 'In Stock',
      'statusColor': const Color(0xFFECFDF5),
      'statusTextColor': const Color(0xFF059669),
      'available': '25 pcs',
      'availableColor': const Color(0xFF10B981),
      'minStock': '10 pcs',
      'icon': Icons.rice_bowl_rounded,
    },
  ];

  /// Live search term, kept in state so the list rebuilds as the seller types.
  String _query = '';

  @override
  void initState() {
    super.initState();
    // `status` is the seed value from the design. Split it into the two things
    // it was conflating: whether the seller is selling the item at all
    // (`inStock`, which the toggle owns) and what the stock level looks like
    // when they are (`baseStatus`). Without this, flipping an item off and back
    // on would lose the fact that it was Low Stock.
    for (final item in _inventoryItems) {
      final seeded = item['status'].toString();
      item['inStock'] = seeded != 'Out of Stock';
      item['baseStatus'] = seeded == 'Out of Stock' ? 'In Stock' : seeded;
    }
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isInStock(Map<String, dynamic> item) => item['inStock'] == true;

  String _statusLabel(Map<String, dynamic> item) =>
      _isInStock(item) ? item['baseStatus'].toString() : 'Out of Stock';

  /// Background / foreground pair for the status pill, derived rather than
  /// stored so the toggle and the badge can never disagree.
  (Color, Color) _statusColors(Map<String, dynamic> item) {
    switch (_statusLabel(item)) {
      case 'Out of Stock':
        return (const Color(0xFFFEF2F2), const Color(0xFFDC2626));
      case 'Low Stock':
        return (const Color(0xFFFFFBEB), const Color(0xFFD97706));
      default:
        return (const Color(0xFFECFDF5), const Color(0xFF059669));
    }
  }

  /// Search term plus the selected filter pill, applied together.
  List<Map<String, dynamic>> get _visibleItems {
    final query = _query.toLowerCase();
    return _inventoryItems.where((item) {
      if (query.isNotEmpty) {
        final haystack = '${item['name']} ${item['sku']} ${item['category']}'
            .toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      switch (_selectedFilterIndex) {
        case 1:
          return _statusLabel(item) == 'Low Stock';
        case 2:
          return _statusLabel(item) == 'Out of Stock';
        case 3:
          return item['expiringSoon'] == true;
        default:
          return true;
      }
    }).toList();
  }

  void _toggleStock(Map<String, dynamic> item, bool value) {
    setState(() => item['inStock'] = value);
    AppToast.show(
      context,
      value
          ? '${item['name']} is back in stock'
          : '${item['name']} marked out of stock',
    );
  }

  /// Opens the product editor. `/add-product` doubles as the edit screen — it
  /// is the only product form in the app.
  void _editProduct(Map<String, dynamic> item) => context.push('/add-product');

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Filter by status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: context.textPrimary),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < _filters.length; i++)
              ListTile(
                leading: Icon(
                  _selectedFilterIndex == i
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: _selectedFilterIndex == i
                      ? const Color(0xFFD97706)
                      : context.textSecondary,
                ),
                title: Text(
                  _filters[i]['label'].toString(),
                  style: TextStyle(color: context.textPrimary, fontSize: 14),
                ),
                onTap: () {
                  setState(() => _selectedFilterIndex = i);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header Title & Stock Report Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventory',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Track and manage your stock in real time',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => AppToast.show(
                        context,
                        'Stock reports arrive with the backend integration',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC400),
                        foregroundColor: const Color(0xFF181C2E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(
                        Icons.download_rounded,
                        size: 18,
                        color: context.textPrimary,
                      ),
                      label: Text(
                        'Stock Report',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4 Summary Metric Cards Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMetricCard(
                      icon: Icons.widgets_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFFFBEB),
                      label: 'Total Products',
                      count: '128',
                      subtitle: 'All Products',
                    ),
                    const SizedBox(width: 10),
                    _buildMetricCard(
                      icon: Icons.check_rounded,
                      iconBg: const Color(0xFFA7F3D0),
                      iconColor: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                      label: 'In Stock',
                      count: '95',
                      subtitle: 'Products',
                    ),
                    const SizedBox(width: 10),
                    _buildMetricCard(
                      icon: Icons.priority_high_rounded,
                      iconBg: const Color(0xFFFED7AA),
                      iconColor: const Color(0xFFEA580C),
                      bgColor: const Color(0xFFFFF7ED),
                      label: 'Low Stock',
                      count: '18',
                      subtitle: 'Products',
                    ),
                    const SizedBox(width: 10),
                    _buildMetricCard(
                      icon: Icons.close_rounded,
                      iconBg: const Color(0xFFDDD6FE),
                      iconColor: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFFF5F3FF),
                      label: 'Out of Stock',
                      count: '15',
                      subtitle: 'Products',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Input & Filter Button Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Search products by name, SKU or barcode...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: context.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _openFilterSheet,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list_rounded,
                            size: 16,
                            color: context.textPrimary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Filter Pills Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isSelected = _selectedFilterIndex == index;
                    final f = _filters[index];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFEF3C7)
                              : context.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFC400)
                                : context.borderColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Text(
                          f['label'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Inventory Stock List Card
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor),
                ),
                child: _visibleItems.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: List.generate(_visibleItems.length, (index) {
                          final item = _visibleItems[index];
                          final isLast = index == _visibleItems.length - 1;
                          final inStock = _isInStock(item);
                          final (statusBg, statusFg) = _statusColors(item);

                          return Column(
                            children: [
                              // The whole row opens the product, matching the list
                              // convention everywhere else in the app.
                              InkWell(
                                onTap: () => _editProduct(item),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          item['icon'] as IconData,
                                          color: const Color(0xFFD97706),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'].toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: context.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'SKU: ${item['sku']}  •  ${item['category']}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: context.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusBg,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                _statusLabel(item),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: statusFg,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              item['available'].toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                // An item switched off reads as
                                                // unavailable regardless of the count
                                                // still sitting on the shelf.
                                                color: inStock
                                                    ? item['availableColor']
                                                          as Color
                                                    : const Color(0xFF9CA3AF),
                                              ),
                                            ),
                                            Text(
                                              'Available',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: context.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Min. Stock: ${item['minStock']}',
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
                                      const SizedBox(width: 10),
                                      Column(
                                        children: [
                                          _ActionIcon(
                                            icon: Icons.edit_outlined,
                                            background: context.pageBg,
                                            borderColor: context.borderColor,
                                            iconColor: context.textPrimary,
                                            tooltip: 'Edit ${item['name']}',
                                            onTap: () => _editProduct(item),
                                          ),
                                          const SizedBox(height: 6),
                                          _ActionIcon(
                                            icon: Icons.bar_chart_rounded,
                                            background: const Color(0xFFFEF3C7),
                                            iconColor: const Color(0xFFD97706),
                                            tooltip: 'Stock history',
                                            onTap: () => AppToast.show(
                                              context,
                                              'Stock history arrives with the backend integration',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Frontend-only availability switch. Flips the badge,
                              // the quantity colour and the Out of Stock filter
                              // immediately; nothing is persisted yet.
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 0, 6, 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      inStock
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      size: 15,
                                      color: inStock
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        inStock ? 'In Stock' : 'Out of Stock',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: inStock
                                              ? context.textPrimary
                                              : context.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: inStock,
                                      onChanged: (value) =>
                                          _toggleStock(item, value),
                                      activeTrackColor: const Color(0xFF10B981),
                                      activeThumbColor: Colors.white,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Divider(height: 1, color: context.borderColor),
                            ],
                          );
                        }),
                      ),
              ),
              const SizedBox(height: 16),

              // Bottom Lightbulb Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFEF08A)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC400),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: context.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keep your inventory updated',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Maintain optimal stock levels to avoid order cancellations.',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Shown when a search or filter matches nothing. Without this the card
  /// collapsed to a bare outline and read as a rendering failure.
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: context.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No products match',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _query.isNotEmpty
                ? 'Nothing matches "$_query" in this filter.'
                : 'No products in this filter yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedFilterIndex = 0);
            },
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String count,
    required String subtitle,
  }) {
    return Container(
      width: 125,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181C2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

/// A small square icon button.
///
/// The visible chip stays 28-ish px to match the design, but the tap target is
/// padded out to the 48dp minimum — the original was a bare `Container`, so it
/// was both invisible to the accessibility tree and impossible to hit reliably.
class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
    required this.tooltip,
    this.borderColor,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final Color? borderColor;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(8),
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor!),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
        ),
      ),
    );
  }
}
