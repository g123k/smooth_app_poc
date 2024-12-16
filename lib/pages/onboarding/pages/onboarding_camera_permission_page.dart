import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_buttons.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_text.dart';

class OnboardingCameraPermissionPage extends StatelessWidget {
  const OnboardingCameraPermissionPage({
    super.key,
    required this.onPermissionValidated,
  });

  final VoidCallback onPermissionValidated;

  @override
  Widget build(BuildContext context) {
    final double imageMultiplier =
        (MediaQuery.sizeOf(context).width * 0.6) / 122;
    final double imageHeight = 192 * imageMultiplier;

    return Column(
      children: [
        Transform.translate(
          offset: Offset(0.0, -imageHeight * 0.30),
          child: FractionallySizedBox(
            widthFactor: 0.60,
            child: SvgPicture.asset(
              'assets/onboarding/bottle_barcode.svg',
              width: 122 * imageMultiplier,
              height: imageHeight,
              alignment: AlignmentDirectional.bottomCenter,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: Offset(0.0, -imageHeight * 0.15),
            child: const FractionallySizedBox(
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
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.viewPaddingOf(context).bottom + 30.0,
          ),
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OnboardingPositiveButton(
                  label: 'Continuer',
                  onTap: () async {
                    await Permission.camera.request();
                    onPermissionValidated.call();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
