import 'package:flutter/material.dart';

class OnboardingExplanationPage extends StatelessWidget {
  const OnboardingExplanationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/onboarding/onboarding3.webp',
      fit: BoxFit.contain,
    );
  }
}
