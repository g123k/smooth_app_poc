import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/header/product_header.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';

class ProductTopPadding extends StatelessWidget {
  const ProductTopPadding({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color:
          Theme.of(context).bottomSheetTheme.backgroundColor ?? AppColors.white,
      child: SizedBox(
        height: ProductHeaderTopPaddingComputation.watch(context).topPadding,
      ),
    );
  }
}

class ProductHeaderTopPaddingComputation extends ProductHeaderComputation {
  double topPadding = 0.0;

  @override
  void onSheetScrolled(
    BuildContext context,
    DraggableScrollableController controller,
    ProductHeaderType productHeaderType,
  ) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double screenTopPadding = mediaQueryData.viewPadding.top;

    final double screenHeight = controller.pixels / controller.size;
    final double startPoint = screenHeight - screenTopPadding;
    final double padding;

    if (controller.pixels < startPoint) {
      padding = 0.0;
    } else {
      padding = math.min(
        controller.pixels - startPoint,
        screenTopPadding,
      );
    }

    if (topPadding != padding) {
      topPadding = padding;
      notifyListeners();
    }
  }

  static ProductHeaderTopPaddingComputation read(BuildContext context) {
    return context.read<ProductHeaderTopPaddingComputation>();
  }

  static ProductHeaderTopPaddingComputation watch(BuildContext context) {
    return context.watch<ProductHeaderTopPaddingComputation>();
  }
}
