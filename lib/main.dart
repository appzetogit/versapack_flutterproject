import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_user_application/core/router/app_router.dart';
import 'package:food_user_application/core/services/fcm_service.dart';
import 'package:food_user_application/core/services/referral_tracking_service.dart';
import 'package:food_user_application/core/theme/app_theme.dart';
import 'package:food_user_application/features/orders/application/active_trip_visibility_controller.dart';
import 'package:food_user_application/features/orders/application/incoming_order_controller.dart';
import 'package:food_user_application/features/orders/application/orders_controller.dart';
import 'package:food_user_application/features/orders/application/orders_state.dart';
import 'package:food_user_application/features/orders/presentation/screens/active_trip_screen.dart';
import 'package:food_user_application/features/orders/presentation/screens/incoming_order_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: FoodDeliveryApp()));
}

class FoodDeliveryApp extends ConsumerStatefulWidget {
  const FoodDeliveryApp({super.key});

  @override
  ConsumerState<FoodDeliveryApp> createState() => _FoodDeliveryAppState();
}

class _FoodDeliveryAppState extends ConsumerState<FoodDeliveryApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(fcmServiceProvider).initialize();
      ReferralTrackingService.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(goRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Food Delivery',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: goRouter,
          builder: (context, routedChild) {
            return Stack(
              children: [
                if (routedChild != null) routedChild,
                Consumer(
                  builder: (context, ref, _) {
                    final ordersState = ref.watch(ordersControllerProvider);
                    final hasActiveOrder = ordersState is OrdersLoaded && ordersState.currentOrder != null;
                    final showTrip = ref.watch(activeTripVisibilityControllerProvider);
                    if (!hasActiveOrder || !showTrip) return const SizedBox.shrink();
                    return const ActiveTripScreen();
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final incomingOrder = ref.watch(incomingOrderControllerProvider);
                    if (incomingOrder == null) return const SizedBox.shrink();
                    return IncomingOrderScreen(
                      key: ValueKey(incomingOrder.id),
                      order: incomingOrder,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
