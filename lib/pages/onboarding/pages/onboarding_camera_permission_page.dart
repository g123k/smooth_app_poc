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
            _createRoute(),
          );
        }
      },
      child: Image.asset(
        'assets/onboarding/onboarding4.webp',
        fit: BoxFit.contain,
      ),
    );
  }

  Route _createRoute() {
    /// Right -> left animation
    return PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          const OnboardingAnalyticsPage(),
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        const Offset begin = Offset(1.0, 0.0);
        const Offset end = Offset.zero;
        const Cubic curve = Curves.ease;

        final Animatable<Offset> tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
}
