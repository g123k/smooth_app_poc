import 'dart:math' as math;

import 'package:flutter/widgets.dart';

extension BoxConstraintsExtension on BoxConstraints {
  double get minSide => math.min(maxWidth, maxHeight);
}

extension StatelessWidgetExtension on StatelessWidget {
  void onNextFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
}

extension StateExtension on State {
  void onNextFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
}

extension ScrollMetricsExtension on ScrollMetrics {
  double get page => extentBefore / extentInside;

  bool get hasScrolled => extentBefore % extentInside != 0;
}

extension ScrollControllerExtension on ScrollController {
  void jumpBy(double offset) => jumpTo(position.pixels + offset);

  void animateBy(
    double offset, {
    required Duration duration,
    required Curve curve,
  }) =>
      animateTo(
        position.pixels + offset,
        duration: duration,
        curve: curve,
      );
}
