import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/model/banner.dart';
import '../../../common/widgets/loaders/shimmer_box.dart';
import '../../../common/widgets/misc/app_network_image.dart';

/// The headline promo card: pitch on the left, merchandising artwork on the
/// right, discount starburst top-right, and animated pagination beneath.
///
/// The artwork and the deep link come from the backend's landing banners; the
/// copy and layout are ours, because the banner endpoint returns an image and a
/// CTA link only.
class HeroPromoCard extends StatefulWidget {
  const HeroPromoCard({
    super.key,
    required this.banners,
    required this.onTap,
    this.isLoading = false,
    this.headline = 'Groceries in',
    this.highlight = '10 minutes',
    this.subtitle = 'Fresh essentials,\ndelivered to your doorstep',
    this.discountLabel,
  });

  final List<PromoBanner> banners;
  final ValueChanged<PromoBanner> onTap;
  final bool isLoading;
  final String headline;
  final String highlight;
  final String subtitle;

  /// e.g. "UPTO\n25%\nOFF" — hidden when there is nothing to shout about.
  final String? discountLabel;

  @override
  State<HeroPromoCard> createState() => _HeroPromoCardState();
}

class _HeroPromoCardState extends State<HeroPromoCard> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(HeroPromoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (widget.banners.length < 2) return;
    _timer = Timer.periodic(AppDurations.bannerAutoScroll, (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_index + 1) % widget.banners.length,
        duration: AppDurations.slow,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The card holds a fixed stack of text, so its height has to follow the
    // user's font scale — a hardcoded one clips the CTA at larger sizes.
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final height = (232 * scale).clamp(232.0, 320.0);

    if (widget.isLoading && widget.banners.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ShimmerBox(height: height, radius: AppRadii.rXl),
      );
    }

    final pages = widget.banners.isEmpty
        ? <PromoBanner?>[null]
        : widget.banners.cast<PromoBanner?>();

    return Column(
      children: [
        SizedBox(
          height: height,
          child: RepaintBoundary(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _HeroFace(
                  banner: pages[index],
                  headline: widget.headline,
                  highlight: widget.highlight,
                  subtitle: widget.subtitle,
                  discountLabel: widget.discountLabel,
                  onTap: () {
                    final banner = pages[index];
                    if (banner != null) widget.onTap(banner);
                  },
                ),
              ),
            ),
          ),
        ),
        if (pages.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (i) => AnimatedContainer(
                duration: AppDurations.medium,
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 7,
                width: i == _index ? 20 : 7,
                decoration: BoxDecoration(
                  color: i == _index
                      ? context.semantic.brandSurface
                      : context.semantic.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroFace extends StatelessWidget {
  const _HeroFace({
    required this.banner,
    required this.headline,
    required this.highlight,
    required this.subtitle,
    required this.discountLabel,
    required this.onTap,
  });

  final PromoBanner? banner;
  final String headline;
  final String highlight;
  final String subtitle;
  final String? discountLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.semantic.brandSurfaceSoft,
          borderRadius: AppRadii.rXl,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.sizeOf(context).width * 0.46,
              child: AppNetworkImage(
                url: banner?.imageUrl ?? '',
                fit: BoxFit.cover,
                fallbackIcon: Icons.shopping_basket_rounded,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _SpeedPill(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    headline,
                    style: context.text.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.semantic.onBrandSurface,
                    ),
                  ),
                  Text(
                    highlight,
                    style: context.text.displaySmall!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    style: context.text.bodyMedium!.copyWith(
                      color: context.semantic.onBrandSurface
                          .withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _ShopNowButton(),
                ],
              ),
            ),
            if (discountLabel != null)
              Positioned(
                right: AppSpacing.lg,
                top: AppSpacing.md,
                child: _Starburst(label: discountLabel!),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpeedPill extends StatelessWidget {
  const _SpeedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.semantic.brandSurface,
        borderRadius: AppRadii.rPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded,
            size: 13,
            color: context.semantic.onBrandSurface,
          ),
          const SizedBox(width: 3),
          Text(
            'FAST & ON TIME',
            style: context.text.badgeLabel
                .copyWith(color: context.semantic.onBrandSurface),
          ),
        ],
      ),
    );
  }
}

class _ShopNowButton extends StatelessWidget {
  const _ShopNowButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: AppRadii.rPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Shop Now',
            style: context.text.labelLarge!.copyWith(color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.arrow_forward_rounded, size: 17, color: Colors.white),
        ],
      ),
    );
  }
}

/// The scalloped discount badge. Drawn rather than shipped as an asset so it
/// recolours with the theme and stays sharp at any density.
class _Starburst extends StatelessWidget {
  const _Starburst({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      width: 74,
      child: CustomPaint(
        painter: _StarburstPainter(color: AppColors.brandOrange),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.text.labelMedium!.copyWith(
              color: Colors.white,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _StarburstPainter extends CustomPainter {
  const _StarburstPainter({required this.color});

  final Color color;

  static const _points = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2;
    final inner = outer * 0.86;
    final path = Path();

    for (var i = 0; i < _points * 2; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = (math.pi / _points) * i - math.pi / 2;
      final point = Offset(
        centre.dx + radius * math.cos(angle),
        centre.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StarburstPainter old) => old.color != color;
}
