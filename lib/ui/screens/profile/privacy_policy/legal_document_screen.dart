import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// One section of a long-form legal document.
class LegalSection {
  const LegalSection({required this.heading, required this.body});

  final String heading;
  final List<String> body;
}

/// Shared typesetting for Privacy Policy and Terms — same structure, different
/// content, so one screen serves both.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String lastUpdated;
  final String intro;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(title, style: context.text.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text('Last updated $lastUpdated', style: context.text.bodySmall),
            const SizedBox(height: AppSpacing.xl),
            Text(
              intro,
              style: context.text.bodyLarge!.copyWith(height: 1.6),
            ),
            for (final section in sections) ...[
              const SizedBox(height: AppSpacing.xxl),
              Text(section.heading, style: context.text.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              for (final paragraph in section.body) ...[
                Text(
                  paragraph,
                  style: context.text.bodyLarge!.copyWith(height: 1.65),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
