import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';
import 'package:smoothapp_poc/utils/widgets/offline_size_widget.dart';

class PageViewSizeAware extends StatefulWidget {
  const PageViewSizeAware({
    required this.itemBuilder,
    required this.itemCount,
    required this.controller,
    required this.minHeight,
    super.key,
  });

  final PageController controller;
  final int itemCount;
  final double minHeight;
  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  State<PageViewSizeAware> createState() => _PageViewSizeAwareState();
}

class _PageViewSizeAwareState extends State<PageViewSizeAware> {
  final Map<int, double> _sizes = {};

  ScrollController? _scrollController;
  ProductHeaderConfiguration? _headerConfig;
  late int currentPage;
  late double _currentPageHeight;

  ScrollStartNotification? _scrollStartNotification;
  UserScrollNotification? _userScrollNotification;
  double _horizontalTranslation = 0.0;

  @override
  void initState() {
    super.initState();
    currentPage = widget.controller.initialPage;
    _currentPageHeight = widget.minHeight;
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
          widget.minHeight,
          _currentPageHeight,
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
                },
                child: widget.itemBuilder(context, position),
              );
            },
          ),
        ),
      ),
    );
  }

  int? _computePage(double? page) {
    try {
      if (_userScrollNotification!.direction == ScrollDirection.forward) {
        return page?.ceil();
      } else {
        return page?.floor();
      }
    } catch (_) {
      return null;
    }
  }

  double diff = 0;

  bool onScrollEvent(ScrollNotification notif) {
    if (notif is UserScrollNotification) {
      _userScrollNotification = notif;
    } else if (notif is ScrollStartNotification) {
      if (_scrollStartNotification == null ||
          notif.metrics.extentBefore % notif.metrics.extentInside == 0) {
        _scrollStartNotification = notif;

        final int currentPage = _computePage(widget.controller.page) ?? 0;
        final double pageHeight = math.max(
            math.max(
                _sizes[currentPage - 1] ?? 0.0, _sizes[currentPage] ?? 0.0),
            _sizes[currentPage + 1] ?? 0.0);

        if (_currentPageHeight != pageHeight) {
          diff = pageHeight - _currentPageHeight;
          setState(() => _currentPageHeight = pageHeight);
        }
      }
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
      bool resetStartNotification = false;

      if (notif.metrics.extentBefore % notif.metrics.extentInside == 0) {
        resetStartNotification = true;
        if (_scrollController!.position.userScrollDirection ==
            ScrollDirection.idle) {
          _horizontalTranslation = 0.0;

          if (_computePage(_scrollStartNotification!.metrics.page) ==
              _computePage(notif.metrics.page)) {
            if (resetStartNotification) {
              _scrollStartNotification = null;
            }
            return false;
          }
        }
      }

      if (resetStartNotification) {
        _scrollStartNotification = null;
      }

      final int currentPage = notif.metrics.page.toInt();
      _currentPageHeight = _sizes[currentPage]!;

      if (!notif.metrics.hasScrolled &&
          _scrollController!.offset > _headerConfig!.minThreshold) {
        _scrollController!.jumpTo(_headerConfig!.minThreshold);
      }

      setState(() {});
    }

    return true;
  }
}
