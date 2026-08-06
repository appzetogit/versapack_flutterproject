import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_commerce_seller/config/theme/app_colors.dart';
import 'package:quick_commerce_seller/config/theme/app_text_styles.dart';
import 'package:quick_commerce_seller/core/widgets/async_state_view.dart';
import 'package:quick_commerce_seller/core/widgets/app_toast.dart';
import 'package:quick_commerce_seller/features/explore/domain/store_settings_model.dart';
import 'package:quick_commerce_seller/features/explore/presentation/controllers/explore_controller.dart';
import 'package:quick_commerce_seller/config/theme/app_palette.dart';

class OutletTimingsScreen extends ConsumerStatefulWidget {
  const OutletTimingsScreen({super.key});

  @override
  ConsumerState<OutletTimingsScreen> createState() =>
      _OutletTimingsScreenState();
}

class _OutletTimingsScreenState extends ConsumerState<OutletTimingsScreen> {
  List<DayTimingModel>? _localTimings;

  @override
  Widget build(BuildContext context) {
    final timingsAsync = ref.watch(outletTimingsProvider);

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
          'Operating Schedule',
          style: AppTextStyles.h3.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        // body is a Column, not a scrollable
        child: AsyncStateView<List<DayTimingModel>>(
          value: timingsAsync,
          onRetry: () => ref.invalidate(outletTimingsProvider),
          enableRefresh: false,
          builder: (serverTimings) {
            _localTimings ??= List.from(serverTimings);
            final timings = _localTimings!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: timings.length,
                    itemBuilder: (context, index) {
                      final day = timings[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                day.dayName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                day.isOpen
                                    ? '${day.openTime} - ${day.closeTime}'
                                    : 'Closed',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption.copyWith(
                                  color: day.isOpen
                                      ? AppColors.textSecondaryLight
                                      : const Color(0xFFEF4444),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch(
                              value: day.isOpen,
                              activeTrackColor: const Color(0xFF22C55E),
                              activeThumbColor: Colors.white,
                              onChanged: (val) {
                                setState(() {
                                  _localTimings![index] = day.copyWith(
                                    isOpen: val,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(outletTimingsProvider.notifier)
                            .updateTimings(_localTimings!);
                        AppToast.show(
                          context,
                          'Outlet timings saved successfully!',
                        );
                        context.pop();
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
                        'Save Timings Schedule',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
