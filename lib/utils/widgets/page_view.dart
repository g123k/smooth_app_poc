import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';
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

  ScrollController? _scrollController;
  ProductHeaderConfiguration? _headerConfig;
  late int currentPage;
  ScrollStartNotification? _scrollStartNotification;
  UserScrollNotification? _userScrollNotification;
  double _horizontalTranslation = 0.0;

  @override
  void initState() {
    super.initState();
    currentPage = widget.controller.initialPage;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController = context.read<ScrollController>();
    _headerConfig = context.read<ProductHeaderConfiguration>();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: onScrollEvent,
      child: SizedBox(
        height: math.max(
          _currentSize ?? 0.0,
          widget.minHeight,
        ),
        child: Transform.translate(
          offset: Offset(0.0, _horizontalTranslation),
          child: PageView.builder(
            controller: widget.controller,
            itemCount: widget.itemCount,
            itemBuilder: (BuildContext context, int position) {
              return OfflineMeasureWidget(
                onSizeChanged: (Size size) {
                  _horizontalTranslation = 0.0;
                  _sizes[position] = size.height;
                  setState(() {});
                },
                child: widget.itemBuilder(context, position),
              );
            },
          ),
        ),
      ),
    );
  }

  double? get _currentSize {
    try {
      if (_userScrollNotification!.direction == ScrollDirection.forward) {
        return _sizes[widget.controller.page?.ceil()];
      } else {
        return _sizes[widget.controller.page?.floor()];
      }
    } catch (_) {
      return null;
    }
  }

  bool onScrollEvent(ScrollNotification notif) {
    print(notif);
    if (notif is UserScrollNotification) {
      _userScrollNotification = notif;
    } else if (notif is ScrollStartNotification) {
      _scrollStartNotification = notif;
    } else if (notif is ScrollUpdateNotification) {
      final startScrollHorizontalPosition =
          _scrollStartNotification?.metrics.pixels ?? 0.0;

      final double verticalTopPosition = _headerConfig!.minThreshold;
      final double scrollVerticalPosition = _scrollController!.offset;

      if (scrollVerticalPosition <= verticalTopPosition) {
        return false;
      }

      final double horizontalProgress = notif.metrics.pixels
          .progress(startScrollHorizontalPosition,
              startScrollHorizontalPosition + notif.metrics.extentInside)
          .positive()
          .clamp(0.0, 1.0);

      final double translation = scrollVerticalPosition - verticalTopPosition;

      _horizontalTranslation = translation * horizontalProgress;
      setState(() {});
    } else if (notif is ScrollEndNotification) {
      currentPage = widget.controller.page!.toInt();
      _horizontalTranslation = 0.0;
      _scrollStartNotification = null;
      setState(() {});

      if (_scrollController!.offset > _headerConfig!.minThreshold) {
        _scrollController!.jumpTo(_headerConfig!.minThreshold);
      }
    }

    return true;
  }
}
