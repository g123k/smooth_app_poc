import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';

class HorizontalList extends StatefulWidget {
  const HorizontalList({
    required this.itemCount,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemBuilder,
    this.startPadding = HomePage.HORIZONTAL_PADDING,
    this.endPadding = HomePage.HORIZONTAL_PADDING,
    this.lastItemBuilder,
    super.key,
  })  : assert(itemCount > 0),
        assert(itemWidth > 0),
        assert(itemHeight > 0);

  final int itemCount;
  final double itemWidth;
  final double itemHeight;
  final double startPadding;
  final double endPadding;
  final IndexedWidgetBuilder itemBuilder;
  final WidgetBuilder? lastItemBuilder;

  @override
  State<HorizontalList> createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  ScrollController? _controller;

  @override
  Widget build(BuildContext context) {
    _controller ??= ScrollController();

    final int count =
        widget.itemCount + (widget.lastItemBuilder != null ? 1 : 0);

    return SizedBox(
      height: widget.itemHeight,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: SnapScrollPhysics(
          snapSize: widget.itemWidth,
        ),
        itemBuilder: (BuildContext context, int position) {
          final Widget child;
          final double startPadding;
          final double endPadding;

          if (position == count - 1 && widget.lastItemBuilder != null) {
            startPadding = 8.0;
            endPadding = widget.endPadding;
            child = widget.lastItemBuilder!(context);
          } else {
            startPadding = position == 0 ? widget.startPadding : 8.0;
            endPadding = position == count - 1 && widget.lastItemBuilder == null
                ? widget.endPadding
                : 0.0;

            child = widget.itemBuilder(context, position - 1);
          }

          return SizedBox(
            height: widget.itemHeight,
            width: widget.itemWidth + startPadding + endPadding,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: startPadding,
                end: endPadding,
              ),
              child: child,
            ),
          );
        },
        itemCount: count,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class SnapScrollPhysics extends ScrollPhysics {
  const SnapScrollPhysics({super.parent, required this.snapSize});

  final double snapSize;

  @override
  SnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapScrollPhysics(parent: buildParent(ancestor), snapSize: snapSize);
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
