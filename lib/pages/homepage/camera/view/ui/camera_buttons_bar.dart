import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/pages/homepage/camera/view/camera_state_manager.dart';
import 'package:smoothapp_poc/pages/homepage/camera/view/ui/camera_view.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';
import 'package:smoothapp_poc/resources/app_animations.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/widgets/circled_icon.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar.dart';
import 'package:smoothapp_poc/utils/widgets/useful_widgets.dart';

class CameraButtonBars extends StatelessWidget {
  const CameraButtonBars({
    required this.onClosed,
    super.key,
  });

  final VoidCallback onClosed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IconTheme(
        data: IconThemeData(
          color: Colors.black,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsetsDirectional.only(
            top: HomePage.TOP_ICON_PADDING,
            start: ExpandableSearchAppBar.MIN_CONTENT_PADDING.start,
            end: ExpandableSearchAppBar.MIN_CONTENT_PADDING.start,
          ),
          child: Row(
            children: <Widget>[
              CircledIcon(
                icon: const icons.Close(
                  size: 17.0,
                ),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () {
                  if (NavApp.of(context).hasSheet) {
                    NavApp.of(context).hideSheet();
                    HomePage.of(context).ignoreAllEvents(false);
                    CameraViewStateManager.of(context).reset();
                  } else {
                    onClosed.call();
                  }
                },
              ),
              const Spacer(),
              CircledIcon(
                icon: const icons.ToggleCamera(
                  size: 20.0,
                ),
                onPressed: () {
                  context.read<CustomScannerController>().toggleCamera();
                },
                tooltip: 'Changer de caméra',
              ),
              const _TorchIcon(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TorchIcon extends StatefulWidget {
  const _TorchIcon();

  @override
  State<_TorchIcon> createState() => _TorchIconState();
}

class _TorchIconState extends State<_TorchIcon> {
  @override
  Widget build(BuildContext context) {
    final CustomScannerController controller =
        context.read<CustomScannerController>();

    if (!controller.hasTorch) {
      return EMPTY_WIDGET;
    }

    final bool isTorchOn = controller.isTorchOn;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10.0),
      child: CircledIcon(
        icon: switch (isTorchOn) {
          true => const TorchAnimation.on(),
          false => const TorchAnimation.off(),
        },
        padding: const EdgeInsets.all(6.0),
        onPressed: () {
          if (isTorchOn) {
            controller.turnTorchOff();
          } else {
            controller.turnTorchOn();
          }
          HapticFeedback.selectionClick();
          setState(() {});
        },
        tooltip: _getLabel(controller.isTorchOn),
      ),
    );
  }

  String _getLabel(bool isTorchOn) {
    if (isTorchOn) {
      return 'Désactiver le Flash';
    } else {
      return 'Activer le Flash';
    }
  }
}
