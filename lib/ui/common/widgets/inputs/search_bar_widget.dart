import 'package:flutter/material.dart';

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
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade300, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    if (widget.readOnly) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          decoration: decoration,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                size: 24,
                color: Color(0xFF616161),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search for "milk, eggs, bread"',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const Icon(
                Icons.qr_code_scanner_rounded,
                size: 24,
                color: Color(0xFFE6A100),
              ),
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
