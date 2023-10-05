import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smoothapp_poc/pages/onboarding/onboarding.dart';
import 'package:smoothapp_poc/resources/app_animations.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';

void main() {
  runApp(const MyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnimationLoader(
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'OpenSans',
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryLight),
          scaffoldBackgroundColor: AppColors.white,
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
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const OnboardingPage(),
      ),
    );
  }
}
