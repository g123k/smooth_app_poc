import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/data/product_compatibility.dart';
import 'package:smoothapp_poc/pages/product/header/product_header.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/widgets/modal_sheet.dart';
import 'package:smoothapp_poc/utils/widgets/useful_widgets.dart';

/// When the product is minimized as a bottom sheet, it will show the
/// compatibility score.
/// Once expanded, it will be on in the status bar.
class ProductCompatibilityHeaderAndStatusBar extends StatelessWidget {
  const ProductCompatibilityHeaderAndStatusBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ProductHeaderTopPaddingComputation computation =
        ProductHeaderTopPaddingComputation.watch(context);

    if (computation.topPadding == 0.0) {
      return EMPTY_WIDGET;
    }

    final ProductCompatibility compatibility =
        context.watch<ProductCompatibility>();

    return GestureDetector(
      onTap: () =>
          context.read<DraggableScrollableLockAtTopController>().animateTo(
                1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInExpo,
              ),
      child: ColoredBox(
        color: compatibility.color,
        child: SizedBox(
          height: computation.topPadding,
          child: Center(
            child: Offstage(
              offstage: computation.contentOpacity == 0.0,
              child: Opacity(
                opacity: computation.contentOpacity,
                child: Text(
                  '${compatibility.level?.toInt()}% compatible avec vos attentes',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductHeaderTopPaddingComputation extends ProductHeaderComputation {
  //ignore_for_file: constant_identifier_names
  static const double MIN_SIZE_COMPATIBLE = 45.0;
  static const double MIN_SIZE_UNSET = 0.0;
  double topPadding = MIN_SIZE_COMPATIBLE;
  double contentOpacity = 1.0;
  bool statusBarMode = false;

  void forceStatusBar(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double screenTopPadding = mediaQueryData.viewPadding.top;

    topPadding =
        screenTopPadding > 0 ? screenTopPadding : computeMinSize(context);
    contentOpacity = 0.0;
    statusBarMode = true;
  }

  @override
  void onSheetScrolled(
    BuildContext context,
    DraggableScrollableLockAtTopController controller,
    ProductHeaderType productHeaderType,
  ) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double screenTopPadding = mediaQueryData.viewPadding.top;

    final double screenHeight = controller.pixels / controller.size;
    final double startPoint = screenHeight - screenTopPadding;
    final double minSize = computeMinSize(context);
    final double padding, opacity;

    opacity = controller.pixels
        .progress(
            startPoint - kBottomNavigationBarHeight - (kToolbarHeight * 0.2),
            (startPoint - kBottomNavigationBarHeight - (kToolbarHeight)))
        .clamp(0.0, 1.0);

    if (controller.pixels < startPoint) {
      padding = minSize;
    } else {
      final double progress =
          controller.pixels.progress(startPoint, controller.sizeToPixels(1.0));

      padding = minSize - (minSize - screenTopPadding) * progress;
    }

    if (topPadding != padding || opacity != contentOpacity) {
      topPadding = padding;
      contentOpacity = opacity;
      notifyListeners();
    }

    bool hasChanged = false;
    if (controller.pixels > startPoint && !statusBarMode) {
      statusBarMode = true;
      hasChanged = true;
    } else if (controller.pixels < startPoint && statusBarMode) {
      statusBarMode = false;
      hasChanged = true;
    }

    if (Platform.isAndroid && hasChanged && statusBarMode) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    }
  }

  static ProductHeaderTopPaddingComputation read(BuildContext context) {
    return context.read<ProductHeaderTopPaddingComputation>();
  }

  static ProductHeaderTopPaddingComputation watch(BuildContext context) {
    return context.watch<ProductHeaderTopPaddingComputation>();
  }

  static double computeMinSize(BuildContext context) {
    return (context.read<ProductCompatibility?>()?.type ??
                ProductCompatibilityType.unset) ==
            ProductCompatibilityType.unset
        ? MIN_SIZE_UNSET
        : MIN_SIZE_COMPATIBLE;
  }
}
