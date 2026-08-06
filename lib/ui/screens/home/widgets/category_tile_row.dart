import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/model/category.dart';
import '../../../common/widgets/loaders/shimmer_box.dart';
import '../../../common/widgets/misc/app_network_image.dart';

/// "Shop by Category" — a horizontal run of soft-grey image tiles.
class CategoryTileRow extends StatelessWidget {
  const CategoryTileRow({
    super.key,
    required this.categories,
    required this.onTap,
    this.isLoading = false,
  });

  final List<Category> categories;
  final ValueChanged<Category> onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && categories.isEmpty) {
      return SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (_, _) => const ShimmerBox(
            width: 116,
            height: 150,
            radius: AppRadii.rLg,
          ),
        ),
      );
    }
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => onTap(category),
            child: SizedBox(
              width: 116,
              child: Column(
                children: [
                  Container(
                    height: 104,
                    width: 116,
                    decoration: BoxDecoration(
                      color: context.semantic.surfaceAlt,
                      borderRadius: AppRadii.rLg,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppNetworkImage(
                      url: category.imageUrl,
                      height: 104,
                      width: 116,
                      fallbackIcon: Icons.category_outlined,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
