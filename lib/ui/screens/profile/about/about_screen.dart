import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/widgets/feedback/app_snackbar.dart';
import '../../splash/splash_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _socials = [
    ('Instagram', Icons.camera_alt_outlined),
    ('X', Icons.alternate_email_rounded),
    ('LinkedIn', Icons.work_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const Center(child: SuvioMark(size: 78, onPrimary: false)),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(AppStrings.appName, style: context.text.displaySmall),
            ),
            Center(
              child: Text(
                'Version 1.0.0 (1)',
                style: context.text.bodySmall,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.semantic.surfaceAlt,
                borderRadius: AppRadii.rLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Why we built this', style: context.text.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Groceries should not cost you an afternoon. Suvio Quick '
                    'stocks the essentials close to where you live, so the '
                    'thing you forgot arrives before you have finished cooking. '
                    'Honest prices, a bill with nothing hidden in it, and '
                    'delivery you can actually watch happen.',
                    style: context.text.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Follow along', style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: _socials
                  .map(
                    (social) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () => AppSnackbar.show(
                          context,
                          '${social.$1} launches with our public release',
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.08),
                            borderRadius: AppRadii.rMd,
                          ),
                          child: Icon(
                            social.$2,
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Text(
                '© ${DateTime.now().year} Suvio Quick',
                style: context.text.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
