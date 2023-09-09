import 'package:flutter/material.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'OpenSans',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orangeLight),
        useMaterial3: true,
        dividerColor: AppColors.grey,
        dividerTheme: const DividerThemeData(
          space: 1.0,
          color: AppColors.grey,
        ),
        tabBarTheme: const TabBarTheme(
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      home: const NavApp(),
    );
  }
}
