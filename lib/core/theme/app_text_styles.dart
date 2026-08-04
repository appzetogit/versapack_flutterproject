import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Named type scale. Nothing in the app sets `fontSize:` inline.
abstract final class AppTextStyles {
  static TextTheme textTheme(Color primary, Color secondary) {
    final base = GoogleFonts.manropeTextTheme();
    TextStyle s(
      double size,
      FontWeight weight, {
      double? height,
      double? spacing,
      Color? color,
    }) =>
        base.bodyMedium!.copyWith(
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: spacing,
          color: color ?? primary,
        );

    return TextTheme(
      displayLarge: s(40, FontWeight.w800, height: 1.1, spacing: -1),
      displayMedium: s(34, FontWeight.w800, height: 1.12, spacing: -0.8),
      displaySmall: s(28, FontWeight.w700, height: 1.15, spacing: -0.6),
      headlineLarge: s(24, FontWeight.w700, height: 1.2, spacing: -0.4),
      headlineMedium: s(21, FontWeight.w700, height: 1.22, spacing: -0.3),
      headlineSmall: s(18, FontWeight.w700, height: 1.25, spacing: -0.2),
      titleLarge: s(17, FontWeight.w700, height: 1.3),
      titleMedium: s(15, FontWeight.w600, height: 1.3),
      titleSmall: s(13.5, FontWeight.w600, height: 1.3),
      bodyLarge: s(15, FontWeight.w500, height: 1.45),
      bodyMedium: s(13.5, FontWeight.w500, height: 1.45, color: secondary),
      bodySmall: s(12, FontWeight.w500, height: 1.4, color: secondary),
      labelLarge: s(14, FontWeight.w700, height: 1.2, spacing: 0.2),
      labelMedium: s(12, FontWeight.w700, height: 1.2, spacing: 0.3),
      labelSmall: s(10.5, FontWeight.w800, height: 1.1, spacing: 0.6),
    );
  }
}

/// Use-case styles that are not part of the Material scale.
extension AppTextStyleContext on TextTheme {
  /// Bold, tabular figures so prices in a column line up.
  TextStyle get price => titleMedium!.copyWith(
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  TextStyle get priceLarge => headlineSmall!.copyWith(
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  TextStyle get mrp => bodySmall!.copyWith(
        decoration: TextDecoration.lineThrough,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  TextStyle get badgeLabel => labelSmall!.copyWith(fontWeight: FontWeight.w800);

  TextStyle get sectionHeader => titleLarge!.copyWith(letterSpacing: -0.3);
}
