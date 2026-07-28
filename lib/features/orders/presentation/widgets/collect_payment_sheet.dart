import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_user_application/core/constants/app_constants.dart';
import 'package:food_user_application/core/error/result.dart';
import 'package:food_user_application/features/orders/data/models/delivery_order.dart';
import 'package:food_user_application/features/orders/data/orders_repository.dart';

class CollectPaymentSheet extends ConsumerStatefulWidget {
  const CollectPaymentSheet({super.key, required this.order});

  final DeliveryOrder order;

  @override
  ConsumerState<CollectPaymentSheet> createState() => _CollectPaymentSheetState();
}

class _CollectPaymentSheetState extends ConsumerState<CollectPaymentSheet> {
  bool _loadingQr = false;
  bool _collectingCash = false;
  bool _paid = false;
  String? _error;
  Map<String, dynamic>? _qr;
  Timer? _pollTimer;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateQr() async {
    setState(() {
      _loadingQr = true;
      _error = null;
    });
    final order = widget.order;
    final result = await ref.read(ordersRepositoryProvider).collectQr(
          order.id,
          name: order.customerName.isNotEmpty ? order.customerName : null,
          phone: order.customerPhone.isNotEmpty ? order.customerPhone : null,
        );
    if (!mounted) return;
    result.when(
      success: (data) {
        setState(() {
          _qr = data;
          _loadingQr = false;
        });
        _startPolling();
      },
      failure: (error) => setState(() {
        _error = error.message;
        _loadingQr = false;
      }),
    );
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    final result = await ref.read(ordersRepositoryProvider).paymentStatus(widget.order.id);
    if (!mounted) return;
    result.when(
      success: (data) {
        final payment = data['payment'] as Map<String, dynamic>?;
        final status = payment?['status'] as String?;
        if (status == 'paid' || status == 'captured') {
          _pollTimer?.cancel();
          setState(() => _paid = true);
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) Navigator.of(context).pop(true);
          });
        }
      },
      failure: (_) {},
    );
  }

  Future<void> _collectCash() async {
    setState(() {
      _collectingCash = true;
      _error = null;
    });
    final result = await ref.read(ordersRepositoryProvider).collectCash(widget.order.id);
    if (!mounted) return;
    result.when(
      success: (_) => Navigator.of(context).pop(true),
      failure: (error) => setState(() {
        _error = error.message;
        _collectingCash = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E1E1E);
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final order = widget.order;

    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(12.w),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collect Payment',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: textColor),
                ),
                Text(
                  '₹${order.total.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: theme.primaryColor),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (_paid)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48.sp),
                    SizedBox(height: 12.h),
                    Text(
                      'Payment received',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp, color: textColor),
                    ),
                  ],
                ),
              )
            else if (_qr != null) ...[
              if (_qr!['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    AppConstants.resolveMediaUrl(_qr!['imageUrl'] as String),
                    width: 200.w,
                    height: 200.w,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50.sp, color: Colors.grey),
                  ),
                ),
              SizedBox(height: 12.h),
              Text(
                'Ask the customer to scan this QR to pay',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: subTextColor),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
                  ),
                  SizedBox(width: 8.w),
                  Text('Waiting for payment…', style: TextStyle(fontSize: 12.sp, color: subTextColor)),
                ],
              ),
            ] else
              ElevatedButton.icon(
                onPressed: _loadingQr ? null : _generateQr,
                icon: _loadingQr
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.qr_code_rounded),
                label: const Text('Show QR to Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              ),
            if (_error != null) ...[
              SizedBox(height: 8.h),
              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ],
            if (!_paid) ...[
              SizedBox(height: 12.h),
              OutlinedButton.icon(
                onPressed: _collectingCash ? null : _collectCash,
                icon: _collectingCash
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
                      )
                    : const Icon(Icons.money_rounded),
                label: const Text('Collect Cash Instead'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
