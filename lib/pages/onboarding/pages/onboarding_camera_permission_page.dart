import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_analytics_page.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_buttons.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_text.dart';

class OnboardingCameraPermissionPage extends StatelessWidget {
  const OnboardingCameraPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double imageMultiplier =
        (MediaQuery.sizeOf(context).width * 0.6) / 122;

    return Column(
      children: [
        Expanded(
          flex: 25,
          child: FractionallySizedBox(
            widthFactor: 0.60,
            heightFactor: 1.0,
            child: SvgPicture.asset(
              'assets/onboarding/bottle_barcode.svg',
              width: 122 * imageMultiplier,
              height: 192 * imageMultiplier,
              alignment: AlignmentDirectional.bottomCenter,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        const Expanded(
          flex: 37,
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Center(
              child: OnboardingText(
                text:
                    'A ce sujet, permettez-vous à l\'application d\'utiliser *la caméra* pour scanner des code-barres ?',
                margin: EdgeInsetsDirectional.only(top: 5.5, bottom: 0.0),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 28,
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OnboardingPositiveButton(
                  label: 'Autoriser',
                  onTap: () {
                    Navigator.of(context).pushReplacement(_createRoute());
                  },
                ),
                OnboardingNegativeButton(
                  label: 'Demander\nplus tard',
                  onTap: () {
                    Navigator.of(context).pushReplacement(_createRoute());
                  },
                ),
              ],
            ),
          ),
        ),
        const Spacer(flex: 10),
      ],
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
