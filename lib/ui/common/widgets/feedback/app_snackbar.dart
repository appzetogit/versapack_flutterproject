import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

enum SnackbarVariant { success, error, info }

/// App-wide snackbar. Always replaces the current one rather than stacking —
/// three queued toasts after three quick taps is noise, not feedback.
abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    SnackbarVariant variant = SnackbarVariant.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final (color, icon) = switch (variant) {
      SnackbarVariant.success => (context.semantic.success, Icons.check_circle_rounded),
      SnackbarVariant.error => (context.semantic.danger, Icons.error_rounded),
      SnackbarVariant.info => (context.colors.onSurface, Icons.info_rounded),
    };

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: AppDurations.snackbar,
          backgroundColor: color,
          // No explicit margin: a floating SnackBar with one is laid out off
          // screen on any Scaffold that also has a tall bottomNavigationBar
          // (the address book, product listing, checkout). Letting Flutter
          // position it keeps the floating look and fits above the bar.
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rMd),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: context.text.titleSmall!.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, variant: SnackbarVariant.success);

  static void error(BuildContext context, String message) =>
      show(context, message, variant: SnackbarVariant.error);
}
