import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_commerce_seller/config/theme/app_text_styles.dart';
import 'package:quick_commerce_seller/features/auth/presentation/controllers/auth_controller.dart';
import 'package:quick_commerce_seller/config/theme/app_palette.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  String? _selectedStoreCategory;
  String? _selectedBusinessType;

  final List<String> _storeCategories = [
    'Grocery & Staples',
    'Fruits & Vegetables',
    'Dairy, Bread & Eggs',
    'Snacks & Munchies',
    'Beverages & Juices',
    'Personal Care & Beauty',
    'Home & Cleaning',
    'Electronics & Accessories',
  ];

  final List<String> _businessTypes = [
    'Supermarket / Kirana Store',
    'Specialty Retailer',
    'Wholesaler & Distributor',
    'Cloud Store / Dark Store',
    'Brand / Manufacturer',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: context.textPrimary,
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Step 1 of 4',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 4 Step Progress Pills Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index == 0
                            ? const Color(0xFFFFC400)
                            : context.borderColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header with Yellow Store Icon Circle
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFC400),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Color(0xFFD97706),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Business Information',
                                style: AppTextStyles.h2.copyWith(
                                  color: const Color(0xFF181C2E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tell us about your store & business',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Store Name
                    _buildLabel('Store Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration(
                        hintText: 'Enter store name',
                        prefixIcon: Icons.storefront_outlined,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Store Category Dropdown
                    _buildLabel('Store Category'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedStoreCategory,
                      hint: Text(
                        'Select store category',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.textPrimary,
                      ),
                      decoration: _buildInputDecoration(
                        prefixIcon: Icons.grid_view_outlined,
                      ),
                      items: _storeCategories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedStoreCategory = val),
                    ),
                    const SizedBox(height: 20),

                    // Business Type Dropdown
                    _buildLabel('Business Type'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedBusinessType,
                      hint: Text(
                        'Select business type',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.textPrimary,
                      ),
                      decoration: _buildInputDecoration(
                        prefixIcon: Icons.store_mall_directory_outlined,
                      ),
                      items: _businessTypes
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedBusinessType = val),
                    ),
                    const SizedBox(height: 20),

                    // FSSAI / GSTIN License Number
                    _buildLabel('FSSAI / GSTIN License Number'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _licenseController,
                      keyboardType: TextInputType.text,
                      decoration: _buildInputDecoration(
                        hintText: 'Enter FSSAI or GSTIN number',
                        prefixIcon: Icons.verified_user_outlined,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Why Do We Need This Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFEF08A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDE68A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Why do we need this?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'FSSAI / GSTIN number helps us verify your store and ensure safety & legal standards.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textSecondary,
                                    height: 1.35,
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

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => context.push('/registration-documents'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC400),
                        foregroundColor: const Color(0xFF181C2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).refreshSession(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFFFC400),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save & Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
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

  Widget _buildLabel(String labelText) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: context.textPrimary,
        ),
        children: [
          TextSpan(text: labelText),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    String? hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: const Color(0xFF9CA3AF),
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(prefixIcon, color: const Color(0xFFF59E0B), size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFC400), width: 1.5),
      ),
    );
  }
}
