import 'package:flutter/material.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';

class OnboardingAnalyticsPage extends StatelessWidget {
  const OnboardingAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        if (details.localPosition.dy >
            MediaQuery.sizeOf(context).height * 0.65) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const NavApp(),
            ),
          );
        }
      },
      child: Image.asset(
        'assets/onboarding/onboarding5.webp',
        fit: BoxFit.contain,
      ),
    );
  }
}
