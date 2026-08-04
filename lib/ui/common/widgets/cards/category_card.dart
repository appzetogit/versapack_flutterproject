import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/model/category.dart';
import '../misc/app_network_image.dart';

/// Category tile: image plate + name. Used in the home strip and the full grid.
class CategoryCard extends StatefulWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.size = 68,
    this.showCount = false,
  });

  final Category category;
  final VoidCallback onTap;
  final double size;
  final bool showCount;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: AppDurations.instant,
        child: SizedBox(
          width: widget.size + 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: widget.size,
                width: widget.size,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.07),
                  borderRadius: AppRadii.rLg,
                ),
                clipBehavior: Clip.antiAlias,
                child: AppNetworkImage(
                  url: widget.category.imageUrl,
                  height: widget.size,
                  width: widget.size,
                  fallbackIcon: Icons.category_outlined,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.category.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelMedium,
              ),
              if (widget.showCount && widget.category.itemCount > 0)
                Text(
                  '${widget.category.itemCount} items',
                  style: context.text.bodySmall!.copyWith(fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
