import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_user_application/features/feed/presentation/screens/feed_screen.dart';
import 'package:food_user_application/features/history/presentation/screens/history_screen.dart';
import 'package:food_user_application/features/pocket/presentation/screens/pocket_screen.dart';
import 'package:food_user_application/features/profile/presentation/screens/profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final mainTabIndexProvider = NotifierProvider<MainTabIndexNotifier, int>(
  MainTabIndexNotifier.new,
);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const _screens = [
    FeedScreen(),
    PocketScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainTabIndexProvider);
    return Scaffold(
      // We use a Stack so the bottom nav bar floats over the map (FeedScreen)
      body: Stack(
        children: [
          // IndexedStack preserves the state of the screens (like map position)
          IndexedStack(index: currentIndex, children: _screens),

          // Floating Custom Navigation Bar
          Positioned(
            bottom: 30, // Distance from the bottom
            left: 20,
            right: 20,
            child: CustomBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) => ref.read(mainTabIndexProvider.notifier).setIndex(index),
            ),
          ),
        ],
      ),
    );
  }
}
