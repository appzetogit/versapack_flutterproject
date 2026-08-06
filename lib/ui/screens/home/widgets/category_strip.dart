import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/model/category.dart';
import '../../../common/widgets/loaders/shimmer_box.dart';
import '../../../common/widgets/misc/app_network_image.dart';

/// The horizontal storefront strip under the header: an "All" chip, the live
/// categories, and a "More" affordance.
class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    required this.onMore,
    this.isLoading = false,
    this.newCategoryId,
  });

  final List<Category> categories;

  /// Empty string means "All".
  final String selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onMore;
  final bool isLoading;

  /// Category to flag with a NEW ribbon, when merchandising calls for one.
  final String? newCategoryId;

  static const _visibleCount = 5;

  @override
  Widget build(BuildContext context) {
    if (isLoading && categories.isEmpty) return const _StripSkeleton();
    if (categories.isEmpty) return const SizedBox.shrink();

    final visible = categories.take(_visibleCount).toList();

    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          _AllTile(
            selected: selectedId.isEmpty,
            onTap: () => onSelect(''),
          ),
          for (final category in visible)
            Expanded(
              child: _CategoryTile(
                category: category,
                selected: category.id == selectedId,
                isNew: category.id == newCategoryId,
                onTap: () => onSelect(category.id),
              ),
            ),
          _MoreTile(onTap: onMore),
        ],
      ),
    );
  }
}

class _AllTile extends StatelessWidget {
  const _AllTile({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TileFrame(
      label: 'All',
      selected: selected,
      onTap: onTap,
      child: Container(
        height: 58,
        width: 58,
        decoration: BoxDecoration(
          color: context.semantic.brandSurface,
          borderRadius: AppRadii.rLg,
        ),
        child: Icon(
          Icons.grid_view_rounded,
          size: 26,
          color: context.semantic.onBrandSurface,
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.isNew,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final bool isNew;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TileFrame(
      label: category.name,
      selected: selected,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 58,
            width: 58,
            child: ClipRRect(
              borderRadius: AppRadii.rMd,
              child: AppNetworkImage(
                url: category.imageUrl,
                height: 58,
                width: 58,
                fit: BoxFit.contain,
                fallbackIcon: Icons.category_outlined,
              ),
            ),
          ),
          if (isNew)
            Positioned(
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: context.semantic.danger,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'NEW',
                  style: context.text.labelSmall!
                      .copyWith(color: Colors.white, fontSize: 8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TileFrame(
      label: 'More',
      selected: false,
      onTap: onTap,
      child: Container(
        height: 58,
        width: 58,
        decoration: BoxDecoration(
          color: context.semantic.surfaceAlt,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 26,
          color: context.colors.onSurface,
        ),
      ),
    );
  }
}

/// Shared geometry so every tile in the strip lines up on the same baseline.
class _TileFrame extends StatelessWidget {
  const _TileFrame({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.text.labelMedium!.copyWith(
                color: selected
                    ? context.colors.onSurface
                    : context.semantic.textSecondary,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripSkeleton extends StatelessWidget {
  const _StripSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: List.generate(
          6,
          (_) => const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                children: [
                  ShimmerBox(height: 58, width: 58, radius: AppRadii.rMd),
                  SizedBox(height: AppSpacing.sm),
                  ShimmerBox(width: 40, height: 9),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
