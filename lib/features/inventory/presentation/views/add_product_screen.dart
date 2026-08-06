import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubCategory;
  int _selectedProductTypeIndex = 0;

  final List<String> _categories = [
    'Grocery & Staples',
    'Dairy & Eggs',
    'Beverages',
    'Snacks & Munchies',
    'Personal Care',
    'Main Course',
  ];

  final List<String> _subCategories = [
    'Rice & Atta',
    'Milk & Curd',
    'Soft Drinks',
    'Chips & Biscuits',
  ];

  final List<Map<String, dynamic>> _productTypes = [
    {
      'title': 'Regular Product',
      'desc': 'Physical product that you sell',
      'icon': Icons.inventory_2_rounded,
      'bgColor': const Color(0xFFFEF3C7),
      'iconColor': const Color(0xFFD97706),
    },
    {
      'title': 'Fast Moving',
      'desc': 'High demand everyday item',
      'icon': Icons.bolt_rounded,
      'bgColor': const Color(0xFFFEF3C7),
      'iconColor': const Color(0xFFD97706),
    },
    {
      'title': 'Offer Product',
      'desc': 'Discounted or promo item',
      'icon': Icons.percent_rounded,
      'bgColor': const Color(0xFFF5F3FF),
      'iconColor': const Color(0xFF7C3AED),
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xFF181C2E),
              size: 26,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Inter',
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: 'app',
                    style: TextStyle(color: Color(0xFF181C2E)),
                  ),
                  TextSpan(
                    text: 'zeto',
                    style: TextStyle(color: Color(0xFF0F9D58)),
                  ),
                ],
              ),
            ),
            const Text(
              'Seller',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C2E),
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
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF181C2E),
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Header with Back Arrow
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF181C2E),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Add New Product',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF181C2E),
                                ),
                              ),
                              Text(
                                'Add a new product to your store',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 4 Step Progress Indicator
                    _buildStepProgressIndicator(),
                    const SizedBox(height: 24),

                    // Basic Information Card Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 3.5,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC400),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Basic Information',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF181C2E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Product Name & Category
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Product Name'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: _buildInputDecoration(
                                        hintText: 'Enter product name',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Category'),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _selectedCategory,
                                      hint: const Text(
                                        'Select category',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF181C2E),
                                      ),
                                      decoration: _buildInputDecoration(),
                                      items: _categories
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(
                                                c,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setState(
                                        () => _selectedCategory = val,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Sub Category & Brand
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(
                                      'Sub Category',
                                      isRequired: false,
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _selectedSubCategory,
                                      hint: const Text(
                                        'Select sub category',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF181C2E),
                                      ),
                                      decoration: _buildInputDecoration(),
                                      items: _subCategories
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(
                                                c,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setState(
                                        () => _selectedSubCategory = val,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(
                                      'Brand (Optional)',
                                      isRequired: false,
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _brandController,
                                      decoration: _buildInputDecoration(
                                        hintText: 'Enter brand name',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Product Description Textarea
                          _buildLabel('Product Description'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _descController,
                            maxLines: 4,
                            maxLength: 300,
                            decoration: _buildInputDecoration(
                              hintText: 'Describe your product...',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product Type Section Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Type',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF181C2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Select the type of product',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3 Product Type Cards Row
                          Row(
                            children: List.generate(_productTypes.length, (
                              index,
                            ) {
                              final isSelected =
                                  _selectedProductTypeIndex == index;
                              final type = _productTypes[index];

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedProductTypeIndex = index,
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right: index == 2 ? 0 : 8,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFFFDF0)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFFFC400)
                                            : const Color(0xFFE5E7EB),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFFFFC400)
                                                      : const Color(0xFFD1D5DB),
                                                  width: 2,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? Center(
                                                      child: Container(
                                                        width: 9,
                                                        height: 9,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Color(
                                                                0xFFFFC400,
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: type['bgColor'] as Color,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            type['icon'] as IconData,
                                            color: type['iconColor'] as Color,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          type['title'].toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF181C2E),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          type['desc'].toString(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF6B7280),
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product Media Section Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Expanded(
                                child: Text(
                                  'Product Media',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF181C2E),
                                  ),
                                ),
                              ),
                              Text(
                                'Max 20 files',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Add images, videos or GIFs to showcase your product',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Media Thumbnails Horizontal Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Thumbnail 1: Banana Image
                                _buildMediaThumbnail(
                                  icon: Icons.lunch_dining_rounded,
                                  color: const Color(0xFFFEF3C7),
                                  iconColor: const Color(0xFFD97706),
                                ),
                                const SizedBox(width: 10),

                                // Thumbnail 2: Milk Pouch Image
                                _buildMediaThumbnail(
                                  icon: Icons.local_cafe_rounded,
                                  color: const Color(0xFFECFDF5),
                                  iconColor: const Color(0xFF059669),
                                ),
                                const SizedBox(width: 10),

                                // Thumbnail 3: Video with Play Overlay & Duration
                                _buildMediaThumbnail(
                                  icon: Icons.play_circle_fill_rounded,
                                  color: const Color(0xFFEFF6FF),
                                  iconColor: const Color(0xFF2563EB),
                                  badgeText: '00:15',
                                  isVideo: true,
                                ),
                                const SizedBox(width: 10),

                                // Thumbnail 4: GIF Thumbnail with GIF Tag
                                _buildMediaThumbnail(
                                  icon: Icons.gif_box_rounded,
                                  color: const Color(0xFFFFFBEB),
                                  iconColor: const Color(0xFFD97706),
                                  badgeText: 'GIF',
                                  isGif: true,
                                ),
                                const SizedBox(width: 10),

                                // Add More Container (Dashed border button)
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAFAFA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFD1D5DB),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFC400),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add_rounded,
                                              color: Color(0xFF181C2E),
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Add More',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF181C2E),
                                            ),
                                          ),
                                          const Text(
                                            'Images / Videos / GIFs',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 7,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // File Formats Hint
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                              children: [
                                TextSpan(text: 'You can add: '),
                                TextSpan(
                                  text:
                                      'JPG, PNG, WEBP (Images)  •  MP4, MOV (Videos)  •  GIF',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Lightbulb Alert Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFEF08A),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFC400),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: Color(0xFF181C2E),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Good images and videos help customers understand your product better',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF181C2E),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Use clear, well-lit photos from multiple angles.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF4B5563),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Action Buttons Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save as Draft',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181C2E),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Product Created Successfully!'),
                            ),
                          );
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC400),
                          foregroundColor: const Color(0xFF181C2E),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF181C2E),
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Color(0xFF181C2E),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaThumbnail({
    required IconData icon,
    required Color color,
    required Color iconColor,
    String? badgeText,
    bool isVideo = false,
    bool isGif = false,
  }) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 32),
              if (badgeText != null && isVideo) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // GIF Tag on Top Left
        if (isGif && badgeText != null)
          Positioned(
            left: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Delete 'x' Badge on Top Right
        Positioned(
          right: 4,
          top: 4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFFFFC400),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 12,
              color: Color(0xFF181C2E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepProgressIndicator() {
    final steps = [
      {'step': '1', 'title': 'Product Details', 'isActive': true},
      {'step': '2', 'title': 'Pricing & Stock', 'isActive': false},
      {'step': '3', 'title': 'Images & Media', 'isActive': false},
      {'step': '4', 'title': 'Review', 'isActive': false},
    ];

    return Row(
      children: List.generate(steps.length, (index) {
        final st = steps[index];
        final isActive = st['isActive'] as bool;
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 0
                          ? Colors.transparent
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFFFC400)
                          : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        st['step'].toString(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? const Color(0xFF181C2E)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isLast
                          ? Colors.transparent
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  st['title'].toString(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFFD97706)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 2),
                Container(width: 24, height: 2, color: const Color(0xFFFFC400)),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String labelText, {bool isRequired = true}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF181C2E),
        ),
        children: [
          TextSpan(text: labelText),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFFC400), width: 1.5),
      ),
    );
  }
}
