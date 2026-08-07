import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_commerce_seller/config/theme/app_text_styles.dart';
import 'package:quick_commerce_seller/config/theme/app_palette.dart';
import 'package:quick_commerce_seller/core/widgets/app_toast.dart';
import 'package:quick_commerce_seller/features/auth/presentation/controllers/auth_state.dart';
import 'package:quick_commerce_seller/features/auth/presentation/controllers/registration_draft.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const int _stepCount = 4;

  /// Zero-based. The header, the progress pills and the button behaviour all
  /// read from this — previously the screen hardcoded "Step 1 of 4" and had
  /// nowhere to go.
  int _currentStep = 0;

  final _formKeys = List.generate(_stepCount, (_) => GlobalKey<FormState>());

  // Step 1 — business
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  // The register endpoint requires both, and neither was collected anywhere in
  // the wizard, so an application could never have been accepted.
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedStoreCategory;
  String? _selectedBusinessType;

  // Step 2 — address
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // Step 3 — payout
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();

  // Step 4 — documents. Frontend-only: tapping a tile marks it attached so the
  // flow can be walked end to end before the upload endpoint is wired.
  final Map<String, bool> _documents = {
    'PAN Card': false,
    'GSTIN Certificate': false,
    'FSSAI Licence': false,
    'Store Photo': false,
  };

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
    _ownerController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Back moves through the steps before it leaves the screen, so a seller four
  /// screens deep does not lose everything to one tap.
  void _back() {
    if (_currentStep == 0) {
      context.pop();
      return;
    }
    setState(() => _currentStep--);
  }

  /// Validates the current step, then advances or finishes.
  ///
  /// Nothing here talks to the backend: registration is submitted in one
  /// multipart call once the upload contract is wired, so the steps only
  /// collect and validate until then.
  void _continue({bool saveDraft = false}) {
    if (_formKeys[_currentStep].currentState?.validate() != true) return;

    // The dropdowns are not form fields, so step 1 needs an explicit check.
    if (_currentStep == 0 &&
        (_selectedStoreCategory == null || _selectedBusinessType == null)) {
      AppToast.showError(
        context,
        'Choose a store category and business type to continue',
      );
      return;
    }

    if (_currentStep == _stepCount - 1) {
      final missing = _documents.entries
          .where((e) => !e.value)
          .map((e) => e.key)
          .toList();
      if (missing.isNotEmpty) {
        AppToast.showError(context, 'Still needed: ${missing.join(', ')}');
        return;
      }
      context.go('/registration-success');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _currentStep++);
    if (saveDraft) AppToast.showSuccess(context, 'Draft saved');
  }

  String? _required(String? value, String field) =>
      (value ?? '').trim().isEmpty ? 'Enter your $field' : null;

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
          onPressed: _back,
        ),
        title: Text(
          'Step ${_currentStep + 1} of $_stepCount',
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
                  _stepCount,
                  (index) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        // Every step up to the current one stays filled, so the
                        // bar reads as progress rather than a position marker.
                        color: index <= _currentStep
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

                    // Owner's name
                    _buildLabel('Owner Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ownerController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _buildInputDecoration(
                        hintText: 'Enter the owner\'s full name',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Owner's email
                    _buildLabel('Email Address'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icons.mail_outline_rounded,
                      ),
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
                                const SizedBox(height: 4),
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
                  ],
                ),
              ),
            ),        ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC400),
                        foregroundColor: const Color(0xFF181C2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep == _stepCount - 1
                            ? 'Submit application'
                            : 'Continue',
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
                      onPressed: _continue,
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

  /// Holds what was typed so the documents step can submit it, and refuses to
  /// advance without the three fields the backend will not register a store
  /// without.
  void _continue() {
    final storeName = _nameController.text.trim();
    final ownerName = _ownerController.text.trim();
    final email = _emailController.text.trim();

    if (storeName.isEmpty) {
      AppToast.showError(context, 'Please enter your store name');
      return;
    }
    if (ownerName.isEmpty) {
      AppToast.showError(context, 'Please enter the owner name');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      AppToast.showError(context, 'Please enter a valid email address');
      return;
    }

    // The phone is the one the OTP was sent to; it is not asked for twice.
    final authState = ref.read(authControllerProvider);
    final phone = authState is AuthNeedsRegistration ? authState.phone : '';

    ref.read(registrationDraftProvider.notifier).update(
          (d) => d.copyWith(
            storeName: storeName,
            ownerName: ownerName,
            ownerEmail: email,
            phone: phone,
            storeCategory: _selectedStoreCategory,
            businessType: _selectedBusinessType,
            licenseNumber: _licenseController.text.trim(),
          ),
        );

    context.push('/registration-documents');
  }
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

/// A document slot. Frontend-only until the upload contract is wired: tapping
/// toggles the attached state so the flow can be walked end to end.
class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.label,
    required this.attached,
    required this.onTap,
  });

  final String label;
  final bool attached;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, ${attached ? 'attached' : 'not attached'}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: attached ? const Color(0xFFFFFBEB) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: attached ? const Color(0xFFFFC400) : context.borderColor,
              width: attached ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                attached
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                color: attached
                    ? const Color(0xFFD97706)
                    : context.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ),
              Text(
                attached ? 'Attached' : 'Upload',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: attached
                      ? const Color(0xFFD97706)
                      : context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
