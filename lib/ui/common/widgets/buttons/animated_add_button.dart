import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_theme.dart';
import '../misc/quantity_stepper.dart';

/// "ADD" that morphs into a quantity stepper once the item is in the cart.
///
/// The morph is a size+fade transition on a spring curve rather than two
/// swapped widgets, so the control feels like one object changing shape.
class AnimatedAddButton extends StatelessWidget {
  const AnimatedAddButton({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.enabled = true,
    this.hasVariants = false,
    this.canIncrement = true,
    this.height = 32,
    this.width = 78,
    this.compact = true,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool enabled;

  /// Variant products open a sheet instead of adding directly; the button says
  /// so with a small chevron.
  final bool hasVariants;
  final bool canIncrement;
  final double height;
  final double width;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppDurations.medium,
      curve: Curves.easeOutBack,
      alignment: Alignment.centerRight,
      child: AnimatedSwitcher(
        duration: AppDurations.medium,
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: quantity > 0
            ? SizedBox(
                key: const ValueKey('stepper'),
                height: height,
                child: QuantityStepper(
                  quantity: quantity,
                  height: height,
                  compact: compact,
                  canIncrement: canIncrement,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              )
            : _AddPill(
                key: const ValueKey('add'),
                onTap: enabled ? onAdd : null,
                hasVariants: hasVariants,
                height: height,
                width: width,
              ),
      ),
    );
  }
}

class _AddPill extends StatefulWidget {
  const _AddPill({
    super.key,
    required this.onTap,
    required this.hasVariants,
    required this.height,
    required this.width,
  });

  final VoidCallback? onTap;
  final bool hasVariants;
  final double height;
  final double width;

  @override
  State<_AddPill> createState() => _AddPillState();
}

class _AddPillState extends State<_AddPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final primary = context.colors.primary;

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Add to cart',
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1,
          duration: AppDurations.instant,
          child: Container(
            height: widget.height,
            width: widget.width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: enabled
                  ? primary.withValues(alpha: 0.10)
                  : context.semantic.surfaceAlt,
              borderRadius: AppRadii.rSm,
              border: Border.all(
                color: enabled
                    ? primary.withValues(alpha: 0.45)
                    : context.semantic.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ADD',
                  style: context.text.labelMedium!.copyWith(
                    color: enabled ? primary : context.semantic.textSecondary,
                  ),
                ),
                if (widget.hasVariants)
                  Icon(Icons.expand_more_rounded, size: 14, color: primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
