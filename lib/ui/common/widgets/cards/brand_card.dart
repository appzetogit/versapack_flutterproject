import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/model/brand.dart';
import '../misc/app_network_image.dart';

/// Brand tile. Brands are derived from catalog items, so the "logo" is a
/// representative product image rather than a real brand mark.
class BrandCard extends StatefulWidget {
  const BrandCard({
    super.key,
    required this.brand,
    required this.onTap,
    this.width = 108,
  });

  final Brand brand;
  final VoidCallback onTap;
  final double width;

  @override
  State<BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<BrandCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: AppDurations.instant,
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadii.rLg,
            border: Border.all(color: context.semantic.border),
            boxShadow: _pressed ? null : context.semantic.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: AppRadii.rMd,
                child: AppNetworkImage(
                  url: widget.brand.logoUrl,
                  height: 62,
                  width: double.infinity,
                  fallbackIcon: Icons.storefront_outlined,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.brand.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleSmall,
              ),
              Text(
                '${widget.brand.productCount} items',
                style: context.text.bodySmall!.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
