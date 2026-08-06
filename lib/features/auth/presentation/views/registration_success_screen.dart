import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_commerce_seller/config/theme/app_text_styles.dart';
import 'package:quick_commerce_seller/features/auth/presentation/controllers/auth_controller.dart';
import 'package:quick_commerce_seller/config/theme/app_palette.dart';

class RegistrationSuccessScreen extends ConsumerWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Top 3D Success Illustration
                    _buildSuccessIllustration(context),

                    const SizedBox(height: 28),

                    // Title
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                          fontFamily: 'Inter',
                        ),
                        children: [
                          TextSpan(
                            text: 'Registration\n',
                            style: TextStyle(color: context.textPrimary),
                          ),
                          TextSpan(
                            text: 'Submitted!',
                            style: TextStyle(color: Color(0xFFF59E0B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Your application has been\nsubmitted successfully.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF4B5563),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // What Happens Next Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFEF08A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDE68A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active_outlined,
                              color: Color(0xFFD97706),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What happens next?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'We will review your details and get back to you soon.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Go to Home Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).loginMock(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC400),
                    foregroundColor: const Color(0xFF181C2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 20,
                        color: context.textPrimary,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Go to Home',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIllustration(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 240,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Background soft yellow glow circle
          Positioned(
            top: 20,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Green Big Check Circle
          Positioned(
            top: 10,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3310B981),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),

          // Storefront Base
          Positioned(
            bottom: 10,
            left: 50,
            child: Container(
              width: 140,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC400),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  // Appzeto Seller Roof Title
                  Text(
                    'appzeto',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    'Seller',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Awning stripes
                  Container(
                    height: 24,
                    color: Colors.white,
                    child: Row(
                      children: List.generate(
                        6,
                        (i) => Expanded(
                          child: Container(
                            color: i % 2 == 0
                                ? const Color(0xFFFFC400)
                                : context.surface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Glass Doors
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF263238),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Potted Plant (Left)
          Positioned(
            left: 20,
            bottom: 10,
            child: Icon(
              Icons.park_rounded,
              size: 40,
              color: const Color(0xFF10B981),
            ),
          ),

          // Clipboard Card with Green Check (Right)
          Positioned(
            right: 25,
            bottom: 10,
            child: Container(
              width: 75,
              height: 100,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFC400), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(width: 45, height: 4, color: context.borderColor),
                  const SizedBox(height: 4),
                  Container(width: 35, height: 4, color: context.borderColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
