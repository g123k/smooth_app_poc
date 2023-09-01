import 'package:flutter/material.dart';
import 'package:smoothapp_poc/settings/settings_page.dart';

class SettingsIcon extends StatelessWidget {
  const SettingsIcon({
    required this.type,
    super.key,
  });

  final SettingsIconType type;

  @override
  Widget build(BuildContext context) {
    return Positioned.directional(
      textDirection: Directionality.of(context),
      top: 0.0,
      end: 0.0,
      child: Offstage(
        offstage: type == SettingsIconType.invisible,
        child: AnimatedOpacity(
          opacity: type == SettingsIconType.invisible ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: kToolbarHeight - kMinInteractiveDimension,
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                tooltip: 'Settings',
                icon: Icon(
                  Icons.settings,
                  color: type == SettingsIconType.floating
                      ? Colors.white
                      : Colors.black,
                  size: 24.0,
                  shadows: type == SettingsIconType.floating
                      ? [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum SettingsIconType {
  invisible,
  floating,
  appBar;
}
