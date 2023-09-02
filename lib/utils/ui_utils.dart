import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum HorizontalDirection {
  start,
  end,
}

extension BoxConstraintsExtension on BoxConstraints {
  double get minSide => math.min(maxWidth, maxHeight);
}
