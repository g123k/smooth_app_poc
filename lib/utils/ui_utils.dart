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
