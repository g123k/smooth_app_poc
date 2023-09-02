import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/settings/settings_page.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/widgets/circled_icon.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar.dart';

import 'homepage.dart';

class HomePageSettingsIcon extends StatelessWidget {
  const HomePageSettingsIcon({
    required this.type,
    super.key,
  });

  final SettingsIconType type;

  @override
  Widget build(BuildContext context) {
    return Positioned.directional(
      textDirection: Directionality.of(context),
      top: HomePage.TOP_ICON_PADDING,
      end: ExpandableSearchAppBar.MIN_CONTENT_PADDING.start,
      child: Offstage(
        offstage: type == SettingsIconType.invisible,
        child: AnimatedOpacity(
          opacity: type == SettingsIconType.invisible ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SafeArea(
            child: CircledIcon(
              icon: icons.Settings(
                size: 21.0,
                shadow: type == SettingsIconType.floating
                    ? Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      )
                    : null,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
              tooltip: 'Settings',
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
