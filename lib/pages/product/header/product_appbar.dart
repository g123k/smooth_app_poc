import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/data/product_compatibility.dart';
import 'package:smoothapp_poc/pages/food_preferences/food_preferences.dart';
import 'package:smoothapp_poc/pages/product/header/product_header.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/provider_utils.dart';
import 'package:smoothapp_poc/utils/widgets/modal_sheet.dart';

class ProductHeaderAppBar extends StatefulWidget {
  const ProductHeaderAppBar({super.key});

  @override
  State<ProductHeaderAppBar> createState() => _ProductHeaderAppBarState();
}

class _ProductHeaderAppBarState extends State<ProductHeaderAppBar> {
  ScrollController? _contentController;
  double _titleOpacity = 0.0;
  double _infoProgress = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      _contentController = context.read<ScrollController>()
        ..replaceListener(_onScrollContent);
    } catch (_) {}
  }

  void _onScrollContent() {
    if (!mounted) {
      _contentController!.removeListener(_onScrollContent);
      _contentController = null;
      return;
    }

    final double topPadding = MediaQuery.viewPaddingOf(context).top;
    double min = topPadding - (kToolbarHeight / 2);
    double max = topPadding - (kToolbarHeight / 8);

    if (min < 0 || max < 0) {
      double minValue = math.max(min, max);
      min = minValue + (kToolbarHeight / 3);
      max = minValue + kToolbarHeight;
    }

    final double infoPercent = 1 -
        _contentController!.positions.first.pixels
            .progressAndClamp(0, min + ((max - min) * 0.8), 1.0);

    if (infoPercent != _infoProgress) {
      setState(() {
        _infoProgress = infoPercent;
      });
    }

    final double opacity = _contentController!.positions.first.pixels
        .progress(min < max ? min : max, max > min ? max : min)
        .clamp(0.0, 1.0);

    if (opacity != _titleOpacity) {
      setState(() => _titleOpacity = opacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();
    final ProductCompatibility compatibility =
        context.watch<ProductCompatibility>();

    return DefaultTextStyle.merge(
      style: const TextStyle(
        color: AppColors.white,
        fontFamily: 'OpenSans',
      ),
      child: Container(
        height: kToolbarHeight,
        color: compatibility.color,
        child: Row(
          children: [
            SizedBox(
              width: 56.0,
              child: Material(
                type: MaterialType.transparency,
                child: Tooltip(
                  message: MaterialLocalizations.of(context).closeButtonTooltip,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      if (ProductHeaderConfiguration.of(context).type ==
                          ProductHeaderType.modalSheet) {
                        context
                            .read<DraggableScrollableLockAtTopController>()
                            .reset();
                        ProductHeaderAppBarComputation.read(context).minimize();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: SizedBox.expand(
                      child: IconTheme(
                        data: const IconThemeData(
                          size: 14.0,
                          color: AppColors.white,
                        ),
                        child: switch (
                            ProductHeaderConfiguration.of(context).type) {
                          ProductHeaderType.modalSheet =>
                            const icons.Chevron.down(),
                          ProductHeaderType.fullPage =>
                            const icons.Chevron.left(),
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Offstage(
                offstage: _titleOpacity == 0,
                child: Opacity(
                  opacity: _titleOpacity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        product.brands ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 10.0,
                end: ProductHeaderDetails.PADDING.end,
              ),
              child: _ProductCompatibilityScore(
                progress: _infoProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCompatibilityScore extends StatelessWidget {
  //ignore: constant_identifier_names
  static const MAX_WIDTH = 40.0;

  const _ProductCompatibilityScore({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ProductCompatibility compatibility =
        context.watch<ProductCompatibility>();

    final double progress = compatibility.level != null ? this.progress : 1.0;

    return SizedBox(
      width: compatibility.level != null
          ? ProductHeaderScores.computeWidth(context) + (MAX_WIDTH * progress)
          : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(18.0)),
          border: Border.all(color: AppColors.white),
        ),
        child: InkWell(
          onTap: () {
            ProductPage.of(context).ensureTabVisible(
              ProductHeaderTabs.forMe,
            );
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(18.0),
            ),
            child: _getScoreWidget(context, compatibility),
          ),
        ),
      ),
    );
  }

  Widget _getScoreWidget(
    BuildContext context,
    ProductCompatibility compatibility,
  ) {
    if (compatibility.type != ProductCompatibilityType.unset) {
      return IntrinsicHeight(
        child: Row(
          children: [
            Opacity(
              opacity: progress,
              child: Container(
                width: MAX_WIDTH * progress,
                height: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsetsDirectional.only(start: 2.5),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadiusDirectional.horizontal(
                    start: Radius.circular(18.0),
                  ),
                ),
                child: Transform.translate(
                  offset: Offset((1 - progress) * 10, 0.0),
                  child: SizedBox(
                    child: icons.Info(
                      color: compatibility.color,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 6.0,
                  bottom: 8.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${compatibility.level?.toInt()}%',
                      style: const TextStyle(
                        fontSize: 12.0,
                        height: 0.9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Compatible',
                      style: TextStyle(
                        fontSize: 9.0,
                        height: 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () async {
            if (await Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                  builder: (context) => const FoodPreferencesPage(),
                )) ==
                true) {
              ProductPage.of(context).forceReload();
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
            child: Text(
              'Personnaliser\nl\'application',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                height: 0.9,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      );
    }
  }
}

class ProductHeaderAppBarComputation extends ProductHeaderComputation {
  double headerHeight = 0.0;

  @override
  void onSheetScrolled(
    BuildContext context,
    DraggableScrollableLockAtTopController controller,
    ProductHeaderType productHeaderType,
  ) {
    final double heightPercent;
    if (productHeaderType == ProductHeaderType.fullPage) {
      heightPercent = 1.0;
    } else {
      final MediaQueryData mediaQueryData = MediaQuery.of(context);
      final double max = controller.sizeToPixels(1) -
          mediaQueryData.viewPadding.top -
          kBottomNavigationBarHeight;
      final double min = max - kToolbarHeight;

      if (controller.pixels < min) {
        heightPercent = 0.0;
      } else {
        heightPercent = controller.pixels
            .progress(
              min,
              max,
            )
            .clamp(0.0, 1.0);
      }
    }

    if ((heightPercent * kToolbarHeight) != headerHeight) {
      headerHeight = (heightPercent * kToolbarHeight);
      notifyListeners();
    }
  }

  void minimize() {
    headerHeight = 0.0;
    notifyListeners();
  }

  void forceVisibility() {
    if (headerHeight != kToolbarHeight) {
      headerHeight = kToolbarHeight;
    }
    notifyListeners();
  }

  static ProductHeaderAppBarComputation read(BuildContext context) {
    return context.read<ProductHeaderAppBarComputation>();
  }

  static ProductHeaderAppBarComputation watch(BuildContext context) {
    return context.watch<ProductHeaderAppBarComputation>();
  }
}
