import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_animations.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_bottom_hills.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_text.dart';

class OnboardingProjectPage extends StatelessWidget {
  const OnboardingProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: MediaQuery.viewPaddingOf(context).top,
        bottom: OnboardingBottomHills.height(context),
      ),
      child: const SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 46,
              child: FractionallySizedBox(
                widthFactor: 0.75,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: OnboardingPlanetAnimations(),
                ),
              ),
            ),
            Expanded(
              flex: 54,
              child: FractionallySizedBox(
                widthFactor: 0.65,
                child: Center(
                  child: OnboardingText(
                    text:
                        'Nous sommes un projet à *but non lucratif* avec des milliers de bénévoles dans le monde !',
                    margin: EdgeInsetsDirectional.only(top: 6.5, bottom: 0.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
