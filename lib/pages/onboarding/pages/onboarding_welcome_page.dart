import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/onboarding/onboarding.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_animations.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_bottom_hills.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_text.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double fontMultiplier = OnboardingConfig.of(context).fontMultiplier;

    final double hillsHeight = OnboardingBottomHills.height(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: hillsHeight * 0.5 + MediaQuery.viewPaddingOf(context).top,
        bottom: hillsHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 15,
            child: Text(
              'Bienvenue !',
              style: TextStyle(
                fontSize: 45 * fontMultiplier,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            flex: 37,
            child: OnboardingSunAndCloudAnimation(),
          ),
          const Expanded(
            flex: 45,
            child: FractionallySizedBox(
              widthFactor: 0.65,
              child: Align(
                alignment: Alignment(0, -0.2),
                child: OnboardingText(
                  text:
                      'L’application qui vous aide à choisir des aliments bons pour *vous* et pour la *planète* !',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
