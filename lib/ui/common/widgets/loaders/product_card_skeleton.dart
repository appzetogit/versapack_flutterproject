import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import 'shimmer_box.dart';

/// Mirrors the real product card's layout so content does not jump on load.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key, this.width = AppDimens.productCardWidth});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadii.rLg,
        border: Border.all(color: context.semantic.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            height: AppDimens.productImageHeight,
            width: double.infinity,
            radius: AppRadii.rMd,
          ),
          const SizedBox(height: AppSpacing.md),
          const ShimmerBox(width: 52, height: 10),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(width: double.infinity, height: 11),
          const SizedBox(height: AppSpacing.xs),
          const ShimmerBox(width: 90, height: 11),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerBox(width: 46, height: 14),
              ShimmerBox(width: 60, height: 30, radius: AppRadii.rSm),
            ],
          ),
        ],
      ),
    );
  }
}

/// Horizontal strip of product skeletons, used by home sections.
class ProductRowSkeleton extends StatelessWidget {
  const ProductRowSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 258,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, _) => const ProductCardSkeleton(),
      ),
    );
  }
}

/// Grid of product skeletons, used by listing and search.
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.count = 6, this.columns = 2});

  final int count;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.60,
      ),
      itemBuilder: (_, _) => const ProductCardSkeleton(width: double.infinity),
    );
  }
}
