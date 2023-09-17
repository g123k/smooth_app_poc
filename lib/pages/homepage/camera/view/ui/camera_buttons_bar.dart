import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/pages/homepage/camera/view/camera_state_manager.dart';
import 'package:smoothapp_poc/pages/homepage/camera/view/ui/camera_view.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';
import 'package:smoothapp_poc/resources/app_animations.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/widgets/circled_icon.dart';
import 'package:smoothapp_poc/utils/widgets/modal_sheet.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar.dart';
import 'package:smoothapp_poc/utils/widgets/useful_widgets.dart';

class CameraButtonBars extends StatefulWidget {
  const CameraButtonBars({
    required this.onClosed,
    super.key,
  });

  final VoidCallback onClosed;

  @override
  State<CameraButtonBars> createState() => _CameraButtonBarsState();
}

class _CameraButtonBarsState extends State<CameraButtonBars> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final DraggableScrollableLockAtTopController? sheetController =
        context.watch<DraggableScrollableLockAtTopController?>();
    final double progress;

    if (sheetController?.isAttached != true) {
      progress = 0.0;
    } else {
      progress = sheetController!.size.progressAndClamp(0.5, 0.8, 1.0);
    }

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
              Transform.translate(
                offset: Offset(progress * -200, 0.0),
                child: CircledTextIcon(
                  text: const Text('Revenir à l\'accueil'),
                  icon: const icons.Arrow.down(
                    size: 17.0,
                  ),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () {
                    if (NavApp.of(context).hasSheet) {
                      NavApp.of(context).hideSheet();
                      HomePage.of(context).ignoreAllEvents(false);
                    }

                    CameraViewStateManager.of(context).reset();
                    widget.onClosed.call();
                  },
                ),
              ),
              const Spacer(),
              Transform.translate(
                offset: Offset(progress * 120, 0.0),
                child: CircledIcon(
                  icon: const icons.ToggleCamera(
                    size: 20.0,
                  ),
                  onPressed: () {
                    context.read<CustomScannerController>().toggleCamera();
                  },
                  tooltip: 'Changer de caméra',
                ),
              ),
              Transform.translate(
                offset: Offset(progress * 60, 0.0),
                child: const _TorchIcon(),
              ),
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
        context.watch<CustomScannerController>();

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
