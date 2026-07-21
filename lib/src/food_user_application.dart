import 'package:flutter/material.dart';
import 'package:food_user_application/src/ui/branding/app_theme.dart';

class FoodUserApplication extends StatelessWidget {
  const FoodUserApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}
