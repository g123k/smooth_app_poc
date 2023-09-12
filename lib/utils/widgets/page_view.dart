import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smoothapp_poc/utils/widgets/offline_size_widget.dart';

class PageViewSizeAware extends StatefulWidget {
  const PageViewSizeAware({
    required this.itemBuilder,
    required this.itemCount,
    required this.controller,
    required this.minHeight,
    this.onPageChanged,
    super.key,
  });

  final PageController controller;
  final int itemCount;
  final double minHeight;
  final NullableIndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onPageChanged;

  @override
  State<PageViewSizeAware> createState() => _PageViewSizeAwareState();
}

class _PageViewSizeAwareState extends State<PageViewSizeAware> {
  final Map<int, double> _sizes = {};
  late int currentPage;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPageScrolled);
    currentPage = widget.controller.initialPage;
  }

  void _onPageScrolled() {
    if (currentPage != widget.controller.page?.floor()) {
      currentPage = widget.controller.page!.toInt();
      widget.onPageChanged?.call(currentPage);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: math.max(
        _currentSize ?? 0.0,
        widget.minHeight,
      ),
      child: PageView.builder(
        controller: widget.controller,
        itemCount: widget.itemCount,
        itemBuilder: (BuildContext context, int position) {
          return OfflineMeasureWidget(
            onSizeChanged: (Size size) {
              double? oldSize = _sizes[position];
              _sizes[position] = size.height;
              if (widget.controller.page == position &&
                  oldSize != _sizes[position]) {
                setState(() {});
              }
            },
            child: widget.itemBuilder(context, position),
          );
        },
      ),
    );
  }

  double? get _currentSize {
    try {
      return _sizes[widget.controller.page?.toInt()];
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    widget.controller.addListener(_onPageScrolled);
    super.dispose();
  }
}
