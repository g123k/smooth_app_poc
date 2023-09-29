import 'package:flutter/material.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';

bool onBoardingVisited = false;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (onBoardingVisited) {
      onNextFrame(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const NavApp(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_currentPage == 4) {
            onBoardingVisited = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const NavApp(),
              ),
            );
          } else {
            setState(
              () => _currentPage++,
            );
          }
        },
        child: SizedBox.expand(
          child: _ImageOnboarding(position: _currentPage),
        ),
      ),
    );
  }
}

class _ImageOnboarding extends StatelessWidget {
  const _ImageOnboarding({required this.position});

  final int position;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE3F3FE),
      child: Image.asset(
        'assets/onboarding/onboarding${position + 1}.webp',
        fit: BoxFit.contain,
      ),
    );
  }
}
