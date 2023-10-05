import 'package:flutter/material.dart';
import 'package:smoothapp_poc/resources/app_icons.dart';

class OnboardingInfo extends StatelessWidget {
  const OnboardingInfo({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 15,
          child: SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFEEF8FF),
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 17.0,
                  vertical: 15.0,
                ),
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Info(),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 75,
          child: SizedBox.expand(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  top: 15.0,
                  start: 15.0,
                  end: 25.0,
                  bottom: MediaQuery.viewPaddingOf(context).bottom,
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    height: 1.53,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
