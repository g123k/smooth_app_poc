import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/homepage/camera/camera_view.dart';
import 'package:smoothapp_poc/pages/homepage/camera/peak_view.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';

class ExpandableCamera extends StatelessWidget {
  const ExpandableCamera({
    required this.controller,
    required this.height,
    Key? key,
  }) : super(key: key);

  final CustomScannerController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final HomePageState screenController = HomePage.of(context);
        if (screenController.isExpanded) {
          screenController.collapseCamera();
          return false;
        }

        return true;
      },
      child: SliverPersistentHeader(
        delegate: _Delegate(controller, height),
      ),
    );
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  static const double MIN_PEAK = 0.2;

  const _Delegate(this.controller, this.height);

  final CustomScannerController controller;
  final double height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double progress = shrinkOffset / maxExtent;
    final BorderRadius borderRadius = _computeBorderRadius(progress);

    return ColoredBox(
      color: borderRadius.bottomLeft.x == 0
          ? Colors.transparent
          : const Color(0xffffc589),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black,
              ),
            ),
            Positioned.fill(
              child: CameraView(
                controller: controller,
                progress: progress,
                onClosed: () {
                  HomePage.of(context).collapseCamera();
                },
              ),
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: CameraPeakView(
                opacity: _computePeakOpacity(progress),
                onTap: () {
                  HomePage.of(context).expandCamera();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  BorderRadius _computeBorderRadius(double progress) {
    if (progress >= 1 - HomePage.CAMERA_PEAK) {
      return const BorderRadius.vertical(
          bottom: Radius.circular(HomePage.BORDER_RADIUS));
    } else if (progress <= MIN_PEAK) {
      return BorderRadius.zero;
    } else {
      double value = progress.progress(MIN_PEAK, (1 - HomePage.CAMERA_PEAK));

      return BorderRadius.vertical(
        bottom: Radius.circular(HomePage.BORDER_RADIUS * value),
      );
    }
  }

  double _computePeakOpacity(double progress) {
    if (progress >= 1 - HomePage.CAMERA_PEAK) {
      return 1.0;
    } else if (progress <= MIN_PEAK) {
      return 0.0;
    } else {
      return progress.progress(MIN_PEAK, 1 - HomePage.CAMERA_PEAK);
    }
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height * 0.2;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
