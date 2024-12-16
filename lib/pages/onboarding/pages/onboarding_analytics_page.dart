import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_animations.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_buttons.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_info.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_text.dart';
import 'package:smoothapp_poc/utils/system_ui.dart';

class OnboardingAnalyticsPage extends StatelessWidget {
  const OnboardingAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUIStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F3FE),
        body: SafeArea(
          bottom: false,
          child: SizedBox.expand(
            child: Column(
              children: [
                const Expanded(
                  flex: 25,
                  child: FractionallySizedBox(
                    widthFactor: 0.55,
                    child: Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: OnboardingConsentAnimation(),
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
                            'Un dernier instant, acceptez-vous de *partager* des données d’utilisation ?',
                        margin:
                            EdgeInsetsDirectional.only(top: 5.5, bottom: 0.0),
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
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const NavApp(),
                              ),
                            );
                          },
                        ),
                        OnboardingNegativeButton(
                          label: 'Refuser',
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const NavApp(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  flex: 10,
                  child: OnboardingInfo(
                    message:
                        'Si vous changez d’avis, cette option peut-être activée / désactivée depuis les Paramètres.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
