import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_analytics_page.dart';

class OnboardingCameraPermissionPage extends StatelessWidget {
  const OnboardingCameraPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        if (details.localPosition.dy >
            MediaQuery.sizeOf(context).height * 0.65) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  const OnboardingAnalyticsPage(),
            ),
          );
        }
      },
      child: Image.asset(
        'assets/onboarding/onboarding4.webp',
        fit: BoxFit.contain,
      ),
    );
  }
}
