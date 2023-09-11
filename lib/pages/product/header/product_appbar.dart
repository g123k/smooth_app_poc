import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/header/product_header.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/provider_utils.dart';

class ProductHeaderAppBar extends StatefulWidget {
  const ProductHeaderAppBar({super.key});

  @override
  State<ProductHeaderAppBar> createState() => _ProductHeaderAppBarState();
}

class _ProductHeaderAppBarState extends State<ProductHeaderAppBar> {
  ScrollController? _contentController;
  double _titleOpacity = 0.0;

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

    if (min < 0) {
      min = -min;
      max = -max + min;
    }

    final double opacity =
        _contentController!.position.pixels.progress(min, max).clamp(0, 1);

    if (opacity != _titleOpacity) {
      setState(() => _titleOpacity = opacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();

    return MediaQuery.removeViewPadding(
      context: context,
      removeTop: true,
      child: AppBar(
        leading: Tooltip(
          message: MaterialLocalizations.of(context).closeButtonTooltip,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (ProductHeaderConfiguration.of(context).type ==
                  ProductHeaderType.modalSheet) {
                context.read<DraggableScrollableController>().reset();
                ProductHeaderAppBarComputation.read(context).minimize();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: IconTheme(
              data: const IconThemeData(size: 14.0),
              child: switch (ProductHeaderConfiguration.of(context).type) {
                ProductHeaderType.modalSheet => const icons.Chevron.down(),
                ProductHeaderType.fullPage => const icons.Chevron.left(),
              },
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Offstage(
          offstage: _titleOpacity == 0,
          child: Opacity(
            opacity: _titleOpacity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                Text(
                  product.brands ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    fontSize: 16.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        toolbarHeight:
            ProductHeaderAppBarComputation.watch(context).headerHeight,
        elevation: 0,
        scrolledUnderElevation: 0.0,
      ),
    );
  }
}

class ProductHeaderAppBarComputation extends ProductHeaderComputation {
  double headerHeight = 0.0;

  @override
  void onSheetScrolled(
    BuildContext context,
    DraggableScrollableController controller,
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
