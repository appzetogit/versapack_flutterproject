import 'package:flutter/material.dart';

import '../../../../domain/model/category.dart';
import '../../../common/widgets/loaders/shimmer_box.dart';
import '../../../common/widgets/misc/app_network_image.dart';
import '../../../common/widgets/misc/section_header.dart';

/// "Shop by Category" tiles, backed by the real top-level category list.
class ShopByCategoryRow extends StatelessWidget {
  const ShopByCategoryRow({
    super.key,
    this.categories = const [],
    this.isLoading = false,
    this.onCategoryTap,
    this.onSeeAll,
  });

  final List<Category> categories;
  final bool isLoading;
  final ValueChanged<String>? onCategoryTap;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Shop by Category', onSeeAll: onSeeAll),
        SizedBox(
          height: 142,
          child: categories.isEmpty
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, _) => const Column(
                    children: [
                      ShimmerBox(width: 96, height: 90),
                      SizedBox(height: 6),
                      ShimmerBox(width: 72, height: 11),
                    ],
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return GestureDetector(
                      onTap: () => onCategoryTap?.call(item.id),
                      child: SizedBox(
                        width: 96,
                        child: Column(
                          children: [
                            Container(
                              height: 90,
                              width: 96,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F7),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: AppNetworkImage(
                                url: item.imageUrl,
                                fit: BoxFit.contain,
                                fallbackIcon: Icons.category_rounded,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
