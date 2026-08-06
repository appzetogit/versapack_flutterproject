import 'package:flutter/material.dart';
import 'package:quick_commerce_seller/config/theme/app_colors.dart';

/// All pull-to-refresh goes through here so the colour and behaviour stay
/// identical across screens. Never use a bare `RefreshIndicator`.
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: Theme.of(context).cardTheme.color,
      child: child,
    );
  }
}
