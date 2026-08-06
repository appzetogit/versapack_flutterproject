import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/route_paths.dart';
import '../../../common/widgets/misc/section_header.dart';

class ShopByCategoryRow extends StatelessWidget {
  const ShopByCategoryRow({super.key});

  static const _categories = [
    (
      id: 'fruits-veg',
      title: 'Fruits &\nVegetables',
      assetPath: 'assets/images/cat_fruits_veg.png',
      icon: Icons.eco_rounded,
    ),
    (
      id: 'dairy-bread-eggs',
      title: 'Dairy, Bread\n& Eggs',
      assetPath: 'assets/images/cat_dairy_bread_eggs.png',
      icon: Icons.egg_alt_rounded,
    ),
    (
      id: 'atta-rice-dal',
      title: 'Atta, Rice\n& Dal',
      assetPath: 'assets/images/cat_atta_rice_dal.png',
      icon: Icons.rice_bowl_rounded,
    ),
    (
      id: 'snacks-munchies',
      title: 'Snacks &\nMunchies',
      assetPath: 'assets/images/cat_snacks_munchies.png',
      icon: Icons.fastfood_rounded,
    ),
    (
      id: 'cold-drinks-juices',
      title: 'Cold Drinks &\nJuices',
      assetPath: 'assets/images/cat_cold_drinks_juices.png',
      icon: Icons.local_drink_rounded,
    ),
    (
      id: 'masala-essentials',
      title: 'Masala &\nCooking Essentials',
      assetPath: 'assets/images/cat_masala_essentials.png',
      icon: Icons.soup_kitchen_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Shop by Category',
          onSeeAll: () => context.push(RoutePaths.categories),
        ),
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = _categories[index];
              return GestureDetector(
                onTap: () => context.push(RoutePaths.subCategoryOf(item.id)),
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
                        child: Image.asset(
                          item.assetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
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
