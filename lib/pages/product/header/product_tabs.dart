import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/header/product_header_body.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';

class ProductHeaderTabBar extends StatefulWidget {
  //ignore: constant_identifier_names
  static const TAB_BAR_HEIGHT = 46.0;

  const ProductHeaderTabBar({
    required this.onTabChanged,
    super.key,
  });

  final Function(int)? onTabChanged;

  @override
  State<ProductHeaderTabBar> createState() => _ProductHeaderTabBarState();
}

class _ProductHeaderTabBarState extends State<ProductHeaderTabBar> {
  double _horizontalProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final TabController tabController = context.read<TabController>();
    return CustomPaint(
      painter: _ProductHeaderTabBarPainter(
        progress: _horizontalProgress,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SizedBox(
        height: ProductHeaderTabBar.TAB_BAR_HEIGHT,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notif) {
            onNextFrame(() {
              setState(() {
                _horizontalProgress =
                    notif.metrics.pixels / notif.metrics.maxScrollExtent;
              });
            });

            return false;
          },
          child: TabBar(
            controller: tabController,
            tabs: ProductHeaderBody.tabs
                .map(
                  (ProductHeaderTabs tab) => _ProductHeaderTab(
                    tab: tab,
                    selected: tabController.index ==
                        ProductHeaderBody.tabs.indexOf(tab),
                  ),
                )
                .toList(growable: false),
            isScrollable: true,
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            overlayColor: MaterialStateProperty.all(AppColors.primaryVeryLight),
            splashBorderRadius: const BorderRadius.vertical(
              top: Radius.circular(5.0),
            ),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
            indicator: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary,
                  width: 3.0,
                ),
                top: BorderSide(
                  color: AppColors.primary,
                  width: 0.0,
                ),
                left: BorderSide(
                  color: AppColors.primary,
                  width: 0.0,
                ),
                right: BorderSide(
                  color: AppColors.primary,
                  width: 0.0,
                ),
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(5.0)),
              color: AppColors.primaryVeryLight,
            ),
            onTap: (int position) => widget.onTabChanged?.call(position),
          ),
        ),
      ),
    );
  }
}

class _ProductHeaderTab extends StatelessWidget {
  const _ProductHeaderTab({
    required this.tab,
    required this.selected,
  });

  final ProductHeaderTabs tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Center(
        child: Text(_label(context)),
      ),
    );
  }

  String _label(BuildContext context) {
    return switch (tab) {
      ProductHeaderTabs.forMe => 'Pour moi',
      ProductHeaderTabs.health => 'Santé',
      ProductHeaderTabs.environment => 'Environnement',
      ProductHeaderTabs.photos => 'Photos',
      ProductHeaderTabs.contribute => 'Contribuer',
      ProductHeaderTabs.info => 'Infos. supplémentaires',
    };
  }
}

class _ProductHeaderTabBarPainter extends CustomPainter {
  _ProductHeaderTabBarPainter({
    required this.progress,
    required this.backgroundColor,
  });

  final double progress;
  final Color backgroundColor;
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final double gradientSize = size.width * 0.1;

    if (progress > 0.0) {
      _paint.shader = ui.Gradient.linear(
        Offset.zero,
        Offset(gradientSize, 0.0),
        [
          AppColors.primaryLight.withOpacity(
            progress.progressAndClamp(0.0, 0.3, 1.0),
          ),
          backgroundColor,
        ],
      );

      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          gradientSize,
          size.height,
        ),
        _paint,
      );
    }

    if (progress < 1.0) {
      _paint.shader = ui.Gradient.linear(
        Offset(size.width - gradientSize, 0.0),
        Offset(size.width, 0.0),
        [
          backgroundColor,
          AppColors.primaryLight.withOpacity(
            1 - progress.progressAndClamp(0.7, 1.0, 1.0),
          ),
        ],
      );

      canvas.drawRect(
        Rect.fromLTWH(
          size.width - gradientSize,
          0,
          size.width,
          size.height,
        ),
        _paint,
      );
    }

    _paint
      ..shader = null
      ..color = AppColors.primary;
    canvas.drawLine(
      Offset(0, size.height - 1.0),
      Offset(size.width, size.height - 1.0),
      _paint,
    );
  }

  @override
  bool shouldRepaint(_ProductHeaderTabBarPainter oldDelegate) =>
      oldDelegate.progress != progress;

  @override
  bool shouldRebuildSemantics(_ProductHeaderTabBarPainter oldDelegate) => true;
}
