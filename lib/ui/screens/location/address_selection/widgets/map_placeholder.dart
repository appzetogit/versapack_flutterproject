import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../common/widgets/buttons/secondary_button.dart';

/// Stands in for a live map.
///
/// No maps SDK is in scope, so this draws a branded street grid with a centred
/// pin. It reads as "map goes here" deliberately, rather than as a broken tile.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    this.latitude,
    this.longitude,
    this.onUseCurrentLocation,
    this.isLocating = false,
    this.height = 190,
    this.showPinControls = true,
  });

  final double? latitude;
  final double? longitude;
  final VoidCallback? onUseCurrentLocation;
  final bool isLocating;
  final double height;
  final bool showPinControls;

  bool get _hasPin => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.rLg,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.semantic.surfaceAlt,
          border: Border.all(color: context.semantic.border),
          borderRadius: AppRadii.rLg,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _StreetGridPainter(
                  lineColor: context.semantic.border,
                  parkColor: context.colors.primary.withValues(alpha: 0.09),
                  waterColor: context.semantic.accent.withValues(alpha: 0.13),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 42,
                    color: _hasPin
                        ? context.colors.primary
                        : context.semantic.textSecondary,
                  ),
                  Container(
                    height: 5,
                    width: 22,
                    decoration: BoxDecoration(
                      color: context.colors.onSurface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              top: AppSpacing.md,
              child: _Pill(
                text: _hasPin
                    ? '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}'
                    : 'Pin your exact spot',
                icon: _hasPin ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              ),
            ),
            if (showPinControls && onUseCurrentLocation != null)
              Positioned(
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: SecondaryButton(
                  label: 'Use current location',
                  icon: Icons.my_location_rounded,
                  isLoading: isLocating,
                  tonal: false,
                  onPressed: onUseCurrentLocation,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadii.rPill,
        boxShadow: context.semantic.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: context.colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: context.text.labelMedium),
        ],
      ),
    );
  }
}

/// Deterministic street grid — no randomness, so it does not shimmer between
/// rebuilds.
class _StreetGridPainter extends CustomPainter {
  const _StreetGridPainter({
    required this.lineColor,
    required this.parkColor,
    required this.waterColor,
  });

  final Color lineColor;
  final Color parkColor;
  final Color waterColor;

  @override
  void paint(Canvas canvas, Size size) {
    final blocks = Paint()..color = parkColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.06, size.height * 0.10, 74, 46),
        const Radius.circular(8),
      ),
      blocks,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, size.height * 0.58, 92, 54),
        const Radius.circular(8),
      ),
      blocks,
    );

    final river = Paint()
      ..color = waterColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.62,
        size.width * 0.62,
        size.height * 0.9,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 1.02,
        size.width,
        size.height * 0.74,
      );
    canvas.drawPath(path, river);

    final road = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2;
    for (var i = 1; i < 5; i++) {
      final dx = size.width * i / 5;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), road);
    }
    for (var i = 1; i < 4; i++) {
      final dy = size.height * i / 4;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), road);
    }

    // A diagonal arterial road stops the grid reading as graph paper.
    canvas.drawLine(
      Offset(0, size.height * 0.24),
      Offset(size.width, size.height * 0.06),
      road..strokeWidth = 3.2,
    );
  }

  @override
  bool shouldRepaint(_StreetGridPainter old) =>
      old.lineColor != lineColor ||
      old.parkColor != parkColor ||
      old.waterColor != waterColor;
}

/// Route illustration used by order tracking: two pins joined by a curve.
class RouteMapPlaceholder extends StatelessWidget {
  const RouteMapPlaceholder({
    super.key,
    required this.originLabel,
    required this.destinationLabel,
    this.progress = 0.4,
    this.height = 180,
  });

  final String originLabel;
  final String destinationLabel;

  /// 0 = at the store, 1 = at the door.
  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.rLg,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.semantic.surfaceAlt,
          border: Border.all(color: context.semantic.border),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _StreetGridPainter(
                  lineColor: context.semantic.border,
                  parkColor: context.colors.primary.withValues(alpha: 0.08),
                  waterColor: context.semantic.accent.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _RoutePainter(
                  color: context.colors.primary,
                  progress: progress.clamp(0.0, 1.0),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              bottom: AppSpacing.md,
              child: _Pill(text: originLabel, icon: Icons.storefront_rounded),
            ),
            Positioned(
              right: AppSpacing.md,
              top: AppSpacing.md,
              child: _Pill(text: destinationLabel, icon: Icons.home_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.16, size.height * 0.76);
    final end = Offset(size.width * 0.84, size.height * 0.26);
    final control = Offset(size.width * 0.5, size.height * 0.16);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Travelled portion, drawn on top.
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    final rider = metric.getTangentForOffset(metric.length * progress)?.position;
    if (rider != null) {
      canvas.drawCircle(rider, 9, Paint()..color = color);
      canvas.drawCircle(
        rider,
        14,
        Paint()..color = color.withValues(alpha: 0.22),
      );
    }

    for (final (point, angle) in [(start, 0.0), (end, math.pi)]) {
      canvas.drawCircle(point, 7, Paint()..color = color);
      canvas.drawCircle(
        point,
        7,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
      // `angle` is unused visually but keeps the pair shape readable.
      assert(angle >= 0);
    }
  }

  @override
  bool shouldRepaint(_RoutePainter old) =>
      old.progress != progress || old.color != color;
}
