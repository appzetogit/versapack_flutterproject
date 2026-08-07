import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
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
          width: widget.size + 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: widget.size + 6,
                width: widget.size + 14,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.semantic.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: AppNetworkImage(
                  url: widget.category.imageUrl,
                  height: widget.size,
                  width: widget.size,
                  fallbackIcon: Icons.shopping_basket_outlined,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.category.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelSmall!.copyWith(fontWeight: FontWeight.w700, color: context.colors.onSurface),
              ),
              if (widget.showCount && widget.category.itemCount > 0)
                Text(
                  '${widget.category.itemCount} items',
                  style: context.text.bodySmall!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
