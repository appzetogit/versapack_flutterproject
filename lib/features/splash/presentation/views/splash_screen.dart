import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_commerce_seller/core/logging/startup_log.dart';
import 'package:quick_commerce_seller/core/providers/core_providers.dart';
import 'package:quick_commerce_seller/core/providers/onboarding_provider.dart';
import 'package:quick_commerce_seller/features/auth/presentation/controllers/auth_controller.dart';

import 'package:quick_commerce_seller/core/providers/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const Duration _watchdogTimeout = Duration(seconds: 15);
  Timer? _watchdog;

  @override
  void initState() {
    super.initState();
    debugPrint('[SPLASH] Splash screen opened');
    startupLog('splash.initState');

    _watchdog = Timer(_watchdogTimeout, () {
      if (!mounted) return;
      startupLog('splash.WATCHDOG FIRED — startup never completed');
      ref.read(authControllerProvider.notifier).forceLoggedOut();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    debugPrint('[SPLASH] Initialization started');
    startupLog('splash.bootstrap start');
    final startTime = DateTime.now();

    try {
      final seen = await ref
          .read(tokenStorageProvider)
          .hasSeenOnboarding
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              startupLog('splash.hasSeenOnboarding TIMED OUT — assuming false');
              return false;
            },
          );
      startupLog('splash.hasSeenOnboarding', seen);
      if (!mounted) return;
      ref.read(hasSeenOnboardingProvider.notifier).set(seen);

      await ref.read(authControllerProvider.notifier).resolveSession();
      debugPrint('[SPLASH] Initialization completed');
    } catch (e, stack) {
      startupLog('splash.bootstrap FAILED', e);
      if (kDebugMode) debugPrint('$stack');
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).forceLoggedOut();
      debugPrint('[SPLASH] Initialization completed (fallback logged out)');
    } finally {
      // Enforce minimum splash screen display time of 4 seconds (4000ms)
      const minDisplayDuration = Duration(milliseconds: 4000);
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < minDisplayDuration) {
        await Future.delayed(minDisplayDuration - elapsed);
      }
      debugPrint(
        '[SPLASH] Minimum delay completed (${DateTime.now().difference(startTime).inMilliseconds}ms)',
      );

      _watchdog?.cancel();
      startupLog(
        'splash.bootstrap end',
        ref.read(authControllerProvider).runtimeType,
      );

      debugPrint('[SPLASH] Navigation started');
      if (mounted) {
        ref.read(splashCompletedProvider.notifier).markCompleted();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Brand screen: golden background with white marks and navy type in both
    // themes. Deliberately exempt from the brightness-aware palette — themed
    // surfaces here would put dark shapes and white text on gold.
    const brandYellow = Color(0xFFFFC400);

    return Scaffold(
      backgroundColor: brandYellow,
      body: Stack(
        children: [
          // Subtle background food doodles pattern
          Positioned.fill(
            child: CustomPaint(painter: _BackgroundDoodlesPainter()),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),

                // Top Logo Block (Bag icon with motion lines + appzeto Seller title)
                _buildLogoHeader(),

                const Spacer(),

                // Center 3D Storefront Graphic. Scales down instead of
                // overflowing: the fixed spacing above and below leaves less
                // than the graphic's natural height on short screens.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _buildStorefrontGraphic(),
                  ),
                ),

                const Spacer(),

                // Tagline text
                const Text(
                  'Manage your store\nand grow your business',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF181C2E),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 36),

                // Loading Spinner
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF181C2E),
                    ),
                  ),
                ),

                const SizedBox(height: 44),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        // Shopping Bag with Motion Lines
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Motion lines
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 14,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 22,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // White Bag with 'a' logo inside
            Container(
              width: 58,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Bag Handle Arch
                  Positioned(
                    top: 6,
                    child: Container(
                      width: 20,
                      height: 14,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFFC400),
                          width: 3,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  // 'a' Letter inside bag
                  const Positioned(
                    bottom: 8,
                    child: Text(
                      'a',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFC400),
                        height: 1.0,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Brand Name Text: "appzeto"
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(
                text: 'app',
                style: TextStyle(color: Color(0xFF181C2E)),
              ),
              TextSpan(
                text: 'zeto',
                style: TextStyle(color: Color(0xFF0F9D58)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),

        // "Seller" Subtitle
        const Text(
          'Seller',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF181C2E),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStorefrontGraphic() {
    return SizedBox(
      width: 290,
      height: 230,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Ground Shadow
          Positioned(
            bottom: 0,
            child: Container(
              width: 250,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD9A000).withValues(alpha: 0.6),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // Main Shop Building Base
          Positioned(
            bottom: 12,
            child: Container(
              width: 220,
              height: 155,
              decoration: BoxDecoration(
                color: const Color(0xFF263238), // Dark Charcoal Shop Body
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left Display Glass Window
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 20, 5, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF37474F).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF455A64),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Window shine reflection
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right Glass Entrance Door with OPEN sign
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(5, 20, 10, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF37474F),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF455A64),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Door Handle
                          Positioned(
                            left: 8,
                            child: Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC400),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // OPEN Hanging Sign
                          Positioned(
                            top: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC400),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'OPEN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF181C2E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Awning Roof (Yellow and White Scalloped Stripes)
          Positioned(
            top: 25,
            child: Container(
              width: 240,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: List.generate(
                    8,
                    (index) => Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? const Color(0xFFFFC400)
                              : Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Potted Plant (Left Side)
          Positioned(left: 12, bottom: 12, child: _buildPottedPlant()),

          // Potted Plant (Right Side)
          Positioned(right: 12, bottom: 12, child: _buildPottedPlant()),

          // Stacked Cardboard Delivery Boxes (Front Left)
          Positioned(
            left: 55,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Box
                Container(
                  width: 32,
                  height: 24,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5B041),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      color: const Color(0xFFD68910),
                    ),
                  ),
                ),
                // Bottom Stacked Boxes Row
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5B041),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          color: const Color(0xFFD68910),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 32,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEB984E),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 4,
                          color: const Color(0xFFCA6F1E),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPottedPlant() {
    return SizedBox(
      width: 36,
      height: 60,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Dark Pot
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(6),
                top: Radius.circular(2),
              ),
            ),
          ),
          // Green Leaves
          Positioned(
            top: 6,
            child: Column(
              children: [
                Row(
                  children: [
                    Transform.rotate(
                      angle: -0.4,
                      child: Container(
                        width: 12,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Transform.rotate(
                      angle: 0.4,
                      child: Container(
                        width: 12,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                Transform.rotate(
                  angle: 0.0,
                  child: Container(
                    width: 14,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter to draw subtle food doodle outlines in the background
class _BackgroundDoodlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD99F00).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Top-Left Burger
    _drawBurger(canvas, Offset(size.width * 0.18, size.height * 0.16), paint);

    // Top-Right Cloche Dish
    _drawCloche(canvas, Offset(size.width * 0.82, size.height * 0.16), paint);

    // Middle-Left Takeout Box
    _drawTakeoutBox(
      canvas,
      Offset(size.width * 0.12, size.height * 0.36),
      paint,
    );

    // Middle-Right Chef Hat
    _drawChefHat(canvas, Offset(size.width * 0.88, size.height * 0.32), paint);

    // Lower-Left French Fries
    _drawFries(canvas, Offset(size.width * 0.12, size.height * 0.58), paint);

    // Lower-Right Pizza Slice
    _drawPizza(canvas, Offset(size.width * 0.86, size.height * 0.46), paint);
  }

  void _drawBurger(Canvas canvas, Offset c, Paint paint) {
    final rect = Rect.fromCenter(center: c, width: 44, height: 32);
    canvas.drawArc(rect.translate(0, -6), math.pi, math.pi, false, paint);
    canvas.drawLine(
      Offset(c.dx - 22, c.dy + 8),
      Offset(c.dx + 22, c.dy + 8),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, 10), width: 44, height: 10),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  void _drawCloche(Canvas canvas, Offset c, Paint paint) {
    final rect = Rect.fromCenter(center: c, width: 48, height: 32);
    canvas.drawArc(rect, math.pi, math.pi, false, paint);
    canvas.drawLine(Offset(c.dx - 26, c.dy), Offset(c.dx + 26, c.dy), paint);
    canvas.drawCircle(Offset(c.dx, c.dy - 16), 4, paint);
  }

  void _drawTakeoutBox(Canvas canvas, Offset c, Paint paint) {
    final rect = Rect.fromCenter(center: c, width: 36, height: 38);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
    canvas.drawLine(
      Offset(c.dx - 18, c.dy - 6),
      Offset(c.dx + 18, c.dy - 6),
      paint,
    );
    canvas.drawLine(
      Offset(c.dx - 10, c.dy - 19),
      Offset(c.dx, c.dy - 6),
      paint,
    );
    canvas.drawLine(
      Offset(c.dx + 10, c.dy - 19),
      Offset(c.dx, c.dy - 6),
      paint,
    );
  }

  void _drawChefHat(Canvas canvas, Offset c, Paint paint) {
    canvas.drawCircle(Offset(c.dx - 10, c.dy - 8), 10, paint);
    canvas.drawCircle(Offset(c.dx + 10, c.dy - 8), 10, paint);
    canvas.drawCircle(Offset(c.dx, c.dy - 14), 12, paint);
    canvas.drawRect(Rect.fromLTWH(c.dx - 16, c.dy, 32, 12), paint);
  }

  void _drawFries(Canvas canvas, Offset c, Paint paint) {
    final path = Path()
      ..moveTo(c.dx - 16, c.dy - 10)
      ..lineTo(c.dx - 12, c.dy + 18)
      ..lineTo(c.dx + 12, c.dy + 18)
      ..lineTo(c.dx + 16, c.dy - 10)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(c.dx - 10, c.dy - 10),
      Offset(c.dx - 10, c.dy - 22),
      paint,
    );
    canvas.drawLine(Offset(c.dx, c.dy - 10), Offset(c.dx, c.dy - 26), paint);
    canvas.drawLine(
      Offset(c.dx + 10, c.dy - 10),
      Offset(c.dx + 10, c.dy - 22),
      paint,
    );
  }

  void _drawPizza(Canvas canvas, Offset c, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy + 18)
      ..lineTo(c.dx - 18, c.dy - 14)
      ..lineTo(c.dx + 18, c.dy - 14)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(c.dx - 4, c.dy - 2), 3, paint);
    canvas.drawCircle(Offset(c.dx + 6, c.dy + 4), 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
