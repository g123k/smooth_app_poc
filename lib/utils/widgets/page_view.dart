import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/physics.dart';
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
  VerticalClampScrollLimiter? _scrollLimiter;
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
    _scrollLimiter = context.read<VerticalClampScrollLimiter>();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: onHorizontalScrollEvent,
      child: SizedBox(
        height: _computeHeight(),
        child: Transform.translate(
          offset: Offset(0.0, _horizontalTranslation),
          child: Provider.value(
            value: PageViewData._(
              minHeight: widget.minHeight,
              controller: widget.controller,
            ),
            child: PageView.builder(
              controller: widget.controller,
              itemCount: widget.itemCount,
              itemBuilder: (BuildContext context, int position) {
                return OfflineMeasureWidget(
                  onSizeChanged: (Size size) {
                    _horizontalTranslation = 0.0;
                    _sizes[position] = size.height;

                    if (_scrollStartNotification == null) {
                      _currentPageHeight =
                          _sizes[widget.controller.page!.round()]!;
                      setState(() {});
                    }
                  },
                  child: widget.itemBuilder(context, position),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _computeHeight() {
    return math.max(
      widget.minHeight,
      _currentPageHeight,
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

  bool onHorizontalScrollEvent(ScrollNotification notif) {
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
          _currentPageHeight = pageHeight;

          if (_scrollLimiter?.value != _currentPageHeight) {
            _scrollLimiter?.limitScroll(_computeHeight());
          }

          setState(() {});
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

extension PageControllerExtensions on PageController {
  bool isReady() {
    try {
      return hasClients && page != null;
    } catch (_) {
      return false;
    }
  }
}

class PageViewData {
  final double minHeight;
  final PageController controller;

  PageViewData._({
    required this.minHeight,
    required this.controller,
  });

  static PageViewData of(BuildContext context) {
    return context.read<PageViewData>();
  }
}
