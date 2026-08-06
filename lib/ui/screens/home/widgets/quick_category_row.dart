import 'package:flutter/material.dart';

class QuickCategoryRow extends StatelessWidget {
  const QuickCategoryRow({super.key, this.onCategoryTap});

  final ValueChanged<String>? onCategoryTap;

  static const _categories = [
    (
      id: 'all',
      name: 'All',
      icon: Icons.grid_view_rounded,
      assetPath: null,
      isAll: true,
      badge: null,
    ),
    (
      id: 'rakhi',
      name: 'Rakhi',
      icon: Icons.card_giftcard_rounded,
      assetPath: 'assets/images/icon_rakhi.png',
      isAll: false,
      badge: 'NEW',
    ),
    (
      id: 'electronics',
      name: 'Electronics',
      icon: Icons.headphones_rounded,
      assetPath: 'assets/images/icon_electronics.png',
      isAll: false,
      badge: null,
    ),
    (
      id: 'beauty',
      name: 'Beauty',
      icon: Icons.sanitizer_rounded,
      assetPath: 'assets/images/icon_beauty.png',
      isAll: false,
      badge: null,
    ),
    (
      id: 'home',
      name: 'Home',
      icon: Icons.local_florist_rounded,
      assetPath: 'assets/images/icon_home.png',
      isAll: false,
      badge: null,
    ),
    (
      id: 'toys',
      name: 'Toys',
      icon: Icons.smart_toy_rounded,
      assetPath: 'assets/images/icon_toys.png',
      isAll: false,
      badge: null,
    ),
    (
      id: 'more',
      name: 'More',
      icon: Icons.keyboard_arrow_down_rounded,
      assetPath: null,
      isAll: false,
      badge: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return GestureDetector(
            onTap: () => onCategoryTap?.call(cat.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      padding: cat.assetPath != null ? const EdgeInsets.all(3) : EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: cat.isAll
                            ? const Color(0xFFFFD400)
                            : const Color(0xFFF3F4F6),
                        borderRadius: cat.id == 'more'
                            ? BorderRadius.circular(28)
                            : BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: cat.assetPath != null
                          ? Image.asset(
                              cat.assetPath!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              cat.icon,
                              size: 26,
                              color: cat.isAll ? Colors.black : const Color(0xFF333333),
                            ),
                    ),
                    if (cat.badge != null)
                      Positioned(
                        top: -5,
                        left: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cat.badge!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  cat.name,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
