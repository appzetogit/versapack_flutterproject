import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// The search field. On Home it is a tappable, non-editable facade that routes
/// to the search screen; on Search it is a live field.
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    this.controller,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.autofocus = false,
    this.hintRotation = const ['Search for milk', 'Search for bread', 'Search for eggs'],
  });

  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final bool autofocus;

  /// Rotating placeholder, only used in the read-only Home variant.
  final List<String> hintRotation;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  int _hintIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.readOnly && widget.hintRotation.length > 1) _scheduleHintRotation();
  }

  void _scheduleHintRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _hintIndex = (_hintIndex + 1) % widget.hintRotation.length);
      _scheduleHintRotation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: context.colors.surface,
      borderRadius: AppRadii.rMd,
      border: Border.all(color: context.semantic.border),
      boxShadow: context.semantic.cardShadow,
    );

    if (widget.readOnly) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48,
          decoration: decoration,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 20,
                color: context.semantic.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppDurations.medium,
                  child: Text(
                    widget.hintRotation[_hintIndex],
                    key: ValueKey(_hintIndex),
                    style: context.text.bodyLarge!
                        .copyWith(color: context.semantic.textSecondary),
                  ),
                ),
              ),
              Container(width: 1, height: 20, color: context.semantic.border),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.mic_none_rounded, size: 19, color: context.colors.primary),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 48,
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: context.semantic.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: widget.controller,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: context.text.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search for products, brands…',
                border: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: context.text.bodyLarge!
                    .copyWith(color: context.semantic.textSecondary),
              ),
            ),
          ),
          if ((widget.controller?.text ?? '').isNotEmpty)
            IconButton(
              onPressed: () {
                widget.controller?.clear();
                widget.onChanged?.call('');
              },
              icon: const Icon(Icons.close_rounded, size: 18),
              tooltip: 'Clear',
            ),
        ],
      ),
    );
  }
}
