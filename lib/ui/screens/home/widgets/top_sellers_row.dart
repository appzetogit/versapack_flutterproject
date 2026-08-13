import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/model/seller.dart';
import '../../../common/cart_actions.dart';
import '../../../common/widgets/loaders/shimmer_box.dart';
import '../../../common/widgets/misc/app_network_image.dart';

/// Compact "Top Sellers" section with short vertical cards (~175px height).
///
/// Features:
/// - Short compact portrait cards (142px wide x 175px tall).
/// - 1-second auto-cycling backend product images.
/// - Static seller cards that do not move or slide automatically.
/// - 100% dynamic backend data (name, images, ratings, item counts).
class TopSellersRow extends StatefulWidget {
  const TopSellersRow({
    super.key,
    required this.sellers,
    required this.onSellerTap,
    this.onSeeAll,
    this.isLoading = false,
  });

  final List<Seller> sellers;
  final ValueChanged<Seller> onSellerTap;
  final VoidCallback? onSeeAll;
  final bool isLoading;

  @override
  State<TopSellersRow> createState() => _TopSellersRowState();
}

class _TopSellersRowState extends State<TopSellersRow> {
  int _activeHeaderDot = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.sellers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Header with Yellow Star Badge, Title, Subtitle & See All
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.sellers.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _activeHeaderDot == 0 ? 14 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _activeHeaderDot == 0
                            ? const Color(0xFFFFC107)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _activeHeaderDot == 1 ? 14 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _activeHeaderDot == 1
                            ? const Color(0xFFFFC107)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _activeHeaderDot == 2 ? 14 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _activeHeaderDot == 2
                            ? const Color(0xFFFFC107)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC107),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Sellers',
                          style: context.text.titleMedium!.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 16.5,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Verified stores delivering near you',
                          style: context.text.bodySmall!.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onSeeAll != null)
                    GestureDetector(
                      onTap: widget.onSeeAll,
                      child: Row(
                        children: [
                          Text(
                            'See all',
                            style: context.text.labelSmall!.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Color(0xFF16A34A),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),

        // 2. Short Compact Horizontal Cards List (Height 175px)
        if (widget.isLoading)
          SizedBox(
            height: 175,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, _) => ShimmerBox(
                width: 142,
                height: 175,
                radius: BorderRadius.circular(16),
              ),
            ),
          )
        else
          SizedBox(
            height: 175,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification &&
                    notification.metrics.maxScrollExtent > 0) {
                  final progress = notification.metrics.pixels /
                      notification.metrics.maxScrollExtent;
                  final dot = (progress * 2).clamp(0, 2).round();
                  if (dot != _activeHeaderDot) {
                    setState(() => _activeHeaderDot = dot);
                  }
                }
                return false;
              },
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: widget.sellers.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final seller = widget.sellers[index];
                  return _SellerCard(
                    seller: seller,
                    onTap: () => widget.onSellerTap(seller),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Compact short seller card (142px wide x 175px tall).
class _SellerCard extends ConsumerStatefulWidget {
  const _SellerCard({
    required this.seller,
    required this.onTap,
  });

  final Seller seller;
  final VoidCallback onTap;

  @override
  ConsumerState<_SellerCard> createState() => _SellerCardState();
}

class _SellerCardState extends ConsumerState<_SellerCard> {
  Timer? _timer;
  int _imageIndex = 0;
  bool _isWishlisted = false;

  List<String> get _images => widget.seller.productImages;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _imageIndex = (_imageIndex + 1) % _images.length;
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant _SellerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seller.id != widget.seller.id ||
        oldWidget.seller.productImages.length != widget.seller.productImages.length) {
      _imageIndex = 0;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seller = widget.seller;
    final images = _images;
    final currentImage = images.isNotEmpty ? images[_imageIndex % images.length] : '';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 142,
        height: 175,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF3F4F6),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Half: Product Image Box Stack (Height 95px)
            SizedBox(
              height: 95,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Product Image (Auto-cycles every 1 second)
                  Container(
                    width: double.infinity,
                    height: 95,
                    color: const Color(0xFFF9FAFB),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.96, end: 1.0)
                              .animate(animation),
                          child: child,
                        ),
                      ),
                      child: currentImage.isNotEmpty
                          ? AppNetworkImage(
                              key: ValueKey<String>(currentImage),
                              url: currentImage,
                              width: double.infinity,
                              height: 95,
                              fit: BoxFit.contain,
                              fallbackIcon: Icons.shopping_bag_outlined,
                            )
                          : Container(
                              key: const ValueKey<String>('empty'),
                              alignment: Alignment.center,
                              color: const Color(0xFFF9FAFB),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 28,
                                color: Color(0xFFD1D5DB),
                              ),
                            ),
                    ),
                  ),

                  // Top-Left Badge: Green "Top Seller" Pill
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.5,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Top Seller',
                        style: context.text.labelSmall!.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Top-Right Icon: Wishlist Heart
                  Positioned(
                    right: 6,
                    top: 6,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isWishlisted = !_isWishlisted);
                        if (seller.products.isNotEmpty) {
                          CartActions.toggleWishlist(
                            context,
                            ref,
                            seller.products.first,
                          );
                        }
                      },
                      child: Icon(
                        _isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: _isWishlisted
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ),

                  // Bottom-Left Overlapping Circular Seller Logo Avatar (34x34)
                  Positioned(
                    left: 6,
                    bottom: -13,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: seller.imageUrl.trim().isNotEmpty
                          ? AppNetworkImage(
                              url: seller.imageUrl,
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                              fallbackIcon: Icons.storefront_outlined,
                            )
                          : Container(
                              alignment: Alignment.center,
                              color: Colors.white,
                              padding: const EdgeInsets.all(2),
                              child: Text(
                                seller.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 7.5,
                                  color: Color(0xFF1F2937),
                                  height: 1.0,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Half: Seller Info & Stats (Height ~80px)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 15, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Name (From Backend)
                    Text(
                      seller.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall!.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Rating & Delivery Mins Row (From Backend)
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 11,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 1.5),
                        Text(
                          seller.rating.toStringAsFixed(1),
                          style: context.text.titleSmall!.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 10.5,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${seller.deliveryMinutes ?? 25}m',
                          style: context.text.bodySmall!.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Item Count & Free Delivery Line (From Backend)
                    Row(
                      children: [
                        Text(
                          '${seller.productCount} ${seller.productCount == 1 ? 'item' : 'items'}',
                          style: context.text.bodySmall!.copyWith(
                            fontSize: 9.5,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Free delivery',
                          style: context.text.labelSmall!.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
