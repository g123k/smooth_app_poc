import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A custom [ScrollPhysics] that snaps to specific [steps].
/// ignore: must_be_immutable
class VerticalSnapScrollPhysics extends ClampingScrollPhysics {
  VerticalSnapScrollPhysics({
    required List<double> steps,
    super.parent,
  })  : steps = steps.toList()..sort(),
        ignoreNextScroll = false;

  final List<double> steps;
  bool ignoreNextScroll;

  @override
  ClampingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return VerticalSnapScrollPhysics(
        parent: buildParent(ancestor), steps: steps);
  }

  double? _lastPixels;

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent) {
      ignoreNextScroll = false;
      return null;
    }
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent) {
      ignoreNextScroll = false;
      return null;
    }

    Simulation? simulation =
        super.createBallisticSimulation(position, velocity);
    double? proposedPixels = simulation?.x(double.infinity);

    if (simulation == null || proposedPixels == null) {
      var (double? min, _) = _getRange(position.pixels);

      if (min != null && min != steps.last && ignoreNextScroll) {
        return ScrollSpringSimulation(
          spring,
          position.pixels,
          min,
          velocity,
        );
      } else {
        ignoreNextScroll = false;
        return null;
      }
    }

    var (double? min, double? max) = _getRange(position.pixels);
    if (min != null && max == null) {
      if (proposedPixels < min) {
        proposedPixels = min;
      }
    } else if (min != null && max != null) {
      if (position.pixels - proposedPixels > 0) {
        proposedPixels = min;
      } else {
        proposedPixels = max;
      }
    }

    if (_lastPixels == null) {
      _lastPixels = proposedPixels;
    } else {
      _lastPixels = _fixInconsistency(proposedPixels);
    }

    ignoreNextScroll = false;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      _lastPixels!,
      velocity,
    );
  }

  (double?, double?) _getRange(double position) {
    for (int i = steps.length - 1; i >= 0; i--) {
      final double step = steps[i];

      if (i == steps.length - 1 && position > step) {
        return (step, null);
      } else if (position > step && position < steps[i + 1]) {
        return (step, steps[i + 1]);
      }
    }

    return (null, null);
  }

  // In some cases, the proposed pixels have a giant space and finding the range
  // is incorrect. In that case, we ensure to have a contiguous range.
  double _fixInconsistency(double proposedPixels) {
    return fixInconsistency(steps, proposedPixels, _lastPixels!);
  }

  static double fixInconsistency(
    List<double> steps,
    double proposedPixels,
    double initialPixelPosition,
  ) {
    int newPosition = _getStepPosition(steps, proposedPixels);
    int oldPosition = _getStepPosition(steps, initialPixelPosition);

    if (newPosition - oldPosition >= 2) {
      return steps[math.min(newPosition - 1, 0)];
    } else if (newPosition - oldPosition <= -2) {
      return steps[math.min(newPosition + 1, steps.length - 1)];
    }

    return proposedPixels;
  }

  static int _getStepPosition(List<double> steps, double pixels) {
    for (int i = steps.length - 1; i >= 0; i--) {
      final double step = steps.elementAt(i);

      if (pixels >= step) {
        return i;
      }
    }

    return 0;
  }
}

class HorizontalSnapScrollPhysics extends ScrollPhysics {
  const HorizontalSnapScrollPhysics({super.parent, required this.snapSize});

  final double snapSize;

  @override
  HorizontalSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return HorizontalSnapScrollPhysics(
        parent: buildParent(ancestor), snapSize: snapSize);
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / snapSize;
  }

  double _getPixels(ScrollMetrics position, double page) {
    return page * snapSize;
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
