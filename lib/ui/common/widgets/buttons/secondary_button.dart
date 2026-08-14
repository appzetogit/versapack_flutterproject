import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Tonal/outlined secondary action.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
    this.tonal = true,
    this.destructive = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool tonal;
  final bool destructive;
  final bool isLoading;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final accent =
        widget.destructive ? context.semantic.danger : context.colors.primary;

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled
            ? () {
                widget.destructive ? AppHaptics.heavy() : AppHaptics.light();
                widget.onPressed!.call();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: AppDurations.instant,
          child: AnimatedOpacity(
            opacity: enabled ? 1 : 0.45,
            duration: AppDurations.fast,
            child: Container(
              width: widget.expand ? double.infinity : null,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: widget.tonal ? accent.withValues(alpha: 0.10) : null,
                borderRadius: AppRadii.rMd,
                border: Border.all(
                  color: widget.tonal
                      ? Colors.transparent
                      : accent.withValues(alpha: 0.5),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: accent),
                    )
                  : Row(
                      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 17, color: accent),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelLarge!.copyWith(color: accent),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
