import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_commerce_seller/config/theme/app_colors.dart';
import 'package:quick_commerce_seller/config/theme/app_text_styles.dart';
import 'package:quick_commerce_seller/core/widgets/app_toast.dart';
import 'package:quick_commerce_seller/features/offers/domain/offer_model.dart';
import 'package:quick_commerce_seller/features/offers/presentation/controllers/offers_controller.dart';
import 'package:quick_commerce_seller/config/theme/app_palette.dart';

class CreateCouponScreen extends ConsumerStatefulWidget {
  const CreateCouponScreen({super.key});

  @override
  ConsumerState<CreateCouponScreen> createState() => _CreateCouponScreenState();
}

class _CreateCouponScreenState extends ConsumerState<CreateCouponScreen> {
  final TextEditingController _code = TextEditingController(text: 'SUPER50');
  final TextEditingController _title = TextEditingController(
    text: 'Flat 50 OFF',
  );
  final TextEditingController _val = TextEditingController(text: '50');
  final TextEditingController _minOrder = TextEditingController(text: '299');
  DiscountType _discountType = DiscountType.fixedAmount;

  @override
  void dispose() {
    _code.dispose();
    _title.dispose();
    _val.dispose();
    _minOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.textPrimary,
            size: 18,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Coupon Code',
          style: AppTextStyles.h3.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                    Text(
                      'Coupon Code',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _code,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'e.g. SAVE50',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Coupon Title',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _title,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'e.g. 50% OFF on Dairy',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Discount Type',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Flat Amount (₹)'),
                            selected: _discountType == DiscountType.fixedAmount,
                            onSelected: (_) {
                              setState(
                                () => _discountType = DiscountType.fixedAmount,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Percentage (%)'),
                            selected: _discountType == DiscountType.percentage,
                            onSelected: (_) {
                              setState(
                                () => _discountType = DiscountType.percentage,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Discount Value',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _val,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Minimum Order Value (₹)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _minOrder,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_code.text.isNotEmpty && _val.text.isNotEmpty) {
                      final newCoupon = CouponModel(
                        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                        code: _code.text.toUpperCase(),
                        title: _title.text.isEmpty ? _code.text : _title.text,
                        description: 'Valid on orders above ₹${_minOrder.text}',
                        discountType: _discountType,
                        discountValue: double.tryParse(_val.text) ?? 50.0,
                        minOrderAmount:
                            double.tryParse(_minOrder.text) ?? 199.0,
                        validFrom: DateTime.now(),
                        validTill: DateTime.now().add(const Duration(days: 30)),
                        isActive: true,
                      );
                      ref
                          .read(offersControllerProvider.notifier)
                          .createCoupon(newCoupon);
                      AppToast.show(context, 'Coupon created successfully!');
                      context.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF181C2E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save & Publish Coupon',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
