import 'package:flutter/material.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;

class CameraMessageOverlay extends StatelessWidget {
  const CameraMessageOverlay({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      tooltip: message,
      excludeSemantics: true,
      child: IgnorePointer(
        ignoring: true,
        child: FractionallySizedBox(
          widthFactor: 0.85,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(20.0),
              ),
              border: Border.all(
                color: const Color(0x33FFFFFF),
                width: 1.0,
              ),
              color: const Color(0x33FFFFFF),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  const Expanded(
                    flex: 15,
                    child: Center(
                      child: icons.Info(
                        size: 28.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    color: Color(0x33FFFFFF),
                    width: 1.0,
                  ),
                  Expanded(
                    flex: 75,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 20.0,
                        ),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10.0,
                                ),
                              ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
