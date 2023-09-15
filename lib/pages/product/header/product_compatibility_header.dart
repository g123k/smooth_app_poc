import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/header/product_header.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';

class ProductCompatibilityHeader extends StatelessWidget {
  const ProductCompatibilityHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ProductHeaderTopPaddingComputation computation =
        ProductHeaderTopPaddingComputation.watch(context);
    return ColoredBox(
      color:
          /*Theme.of(context).bottomSheetTheme.backgroundColor ?? AppColors.white*/
          AppColors.compatibilityHigh,
      child: SizedBox(
        height: computation.topPadding,
        child: Center(
          child: Opacity(
            opacity: computation.contentOpacity,
            child: Text(
              'Ce produit est 100% compatible',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductHeaderTopPaddingComputation extends ProductHeaderComputation {
  //ignore: constant_identifier_names
  static const double MIN_SIZE = 40.0;
  double topPadding = MIN_SIZE;
  double contentOpacity = 1.0;

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
    final double padding, opacity;

    opacity = controller.pixels
        .progress(startPoint, startPoint * 0.85)
        .clamp(0.0, 1.0);

    if (controller.pixels < startPoint) {
      padding = MIN_SIZE;
    } else {
      final double progress =
          controller.pixels.progress(startPoint, controller.sizeToPixels(1.0));

      padding = MIN_SIZE - (MIN_SIZE - screenTopPadding) * progress;
    }

    if (topPadding != padding || opacity != contentOpacity) {
      topPadding = padding;
      contentOpacity = opacity;
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
