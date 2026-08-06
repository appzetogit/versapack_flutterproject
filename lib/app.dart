import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_commerce_seller/config/router/app_router.dart';
import 'package:quick_commerce_seller/config/theme/app_theme.dart';
import 'package:quick_commerce_seller/config/theme/theme_mode_provider.dart';
import 'package:quick_commerce_seller/core/widgets/no_network_overlay.dart';
import 'package:quick_commerce_seller/features/auth/presentation/controllers/auth_controller.dart';
import 'package:quick_commerce_seller/features/auth/presentation/controllers/auth_state.dart';
import 'package:quick_commerce_seller/features/home/presentation/controllers/store_summary_controller.dart';

class SellerApp extends ConsumerStatefulWidget {
  const SellerApp({super.key});

  @override
  ConsumerState<SellerApp> createState() => _SellerAppState();
}

class _SellerAppState extends ConsumerState<SellerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    // The server is the source of truth. Anything that changed while the app
    // was backgrounded — including a session evicted by a sign-in elsewhere —
    // surfaces on this refresh rather than on the seller's next tap.
    if (ref.read(authControllerProvider) is AuthAuthenticated) {
      ref.read(storeSummaryControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Seller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) =>
          NoNetworkOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
