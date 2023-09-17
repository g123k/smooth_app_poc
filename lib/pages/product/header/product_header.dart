import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/header/product_appbar.dart';
import 'package:smoothapp_poc/pages/product/header/product_compatibility_header.dart';
import 'package:smoothapp_poc/pages/product/header/product_header_body.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/utils/provider_utils.dart';
import 'package:smoothapp_poc/utils/widgets/modal_sheet.dart';

export 'package:smoothapp_poc/pages/product/header/product_appbar.dart';
export 'package:smoothapp_poc/pages/product/header/product_header_body.dart';

class ProductHeader extends StatefulWidget {
  const ProductHeader({
    super.key,
    required this.onElementTapped,
    required this.onTabChanged,
    this.onCardTapped,
  });

  final VoidCallback? onCardTapped;
  final Function(ElementTappedType, double scrollExpectedPosition)
      onElementTapped;
  final Function(int position, double scrollExpectedPosition) onTabChanged;

  @override
  State<ProductHeader> createState() => _ProductHeaderState();
}

enum ElementTappedType {
  nutriscore,
  ecoscore,
}

class _ProductHeaderState extends State<ProductHeader> {
  final ProductHeaderAppBarComputation _appBarComputation =
      ProductHeaderAppBarComputation();
  final ProductHeaderTopPaddingComputation _topPaddingComputation =
      ProductHeaderTopPaddingComputation();

  DraggableScrollableLockAtTopController? _sheetController;
  ProductHeaderType? _headerType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _headerType = ProductHeaderConfiguration.of(context).type;

    try {
      _sheetController = context.read<DraggableScrollableLockAtTopController>()
        ..replaceListener(_onScrollModalSheet);
      _onScrollModalSheet();
    } catch (_) {
      _topPaddingComputation.forceStatusBar(context);
      _appBarComputation.forceVisibility();
    }
  }

  void _onScrollModalSheet() {
    if (!mounted) {
      _sheetController!.removeListener(_onScrollModalSheet);
      _sheetController = null;
      return;
    }

    _appBarComputation.onSheetScrolled(
      context,
      _sheetController!,
      _headerType!,
    );
    _topPaddingComputation.onSheetScrolled(
      context,
      _sheetController!,
      _headerType!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProductHeaderConfiguration config =
        ProductHeaderConfiguration.of(context);

    return MultiProvider(
      providers: [
        ListenableProvider<ProductHeaderAppBarComputation>.value(
          value: _appBarComputation,
        ),
        ListenableProvider<ProductHeaderTopPaddingComputation>.value(
          value: _topPaddingComputation,
        ),
      ],
      child: Builder(builder: (BuildContext context) {
        return SliverPersistentHeader(
          pinned: true,
          delegate: _ProductHeaderDelegate(
            headerMaxHeight: config.maxHeight,
            headerMinHeight: config.minHeight,
            topPadding:
                ProductHeaderTopPaddingComputation.watch(context).topPadding,
            toolbarHeight:
                ProductHeaderAppBarComputation.watch(context).headerHeight,
            onCardTapped: widget.onCardTapped,
            onElementTapped: widget.onElementTapped,
            onTabChanged: widget.onTabChanged,
          ),
        );
      }),
    );
  }
}

class _ProductHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ProductHeaderDelegate({
    required this.onElementTapped,
    required this.onTabChanged,
    required this.headerMinHeight,
    required this.headerMaxHeight,
    required this.topPadding,
    required this.toolbarHeight,
    this.onCardTapped,
  });

  final VoidCallback? onCardTapped;
  final Function(ElementTappedType, double scrollExpectedPosition)
      onElementTapped;
  final Function(int, double) onTabChanged;
  final double topPadding;
  final double headerMinHeight;
  final double headerMaxHeight;
  final double toolbarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(
      children: [
        const Positioned.fill(
          bottom: null,
          child: ProductCompatibilityHeaderAndStatusBar(),
        ),
        Positioned.fill(
          top: topPadding,
          bottom: null,
          child: Offstage(
            offstage: toolbarHeight <= 0.0,
            child: const ProductHeaderAppBar(),
          ),
        ),
        Positioned.fill(
          top: topPadding + toolbarHeight,
          child: GestureDetector(
            onTap: onCardTapped,
            child: ProductHeaderBody(
              onElementTapped: (ElementTappedType type) => onElementTapped.call(
                type,
                maxExtent - minExtent,
              ),
              onTabChanged: (int index) =>
                  onTabChanged(index, maxExtent - minExtent),
              shrinkContent: math.max(-shrinkOffset, -(maxExtent - minExtent)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_ProductHeaderDelegate oldDelegate) {
    return oldDelegate.toolbarHeight != toolbarHeight ||
        oldDelegate.topPadding != topPadding;
  }

  @override
  double get maxExtent => headerMaxHeight + toolbarHeight + topPadding;

  @override
  double get minExtent => headerMinHeight + toolbarHeight + topPadding;
}

abstract class ProductHeaderComputation extends ChangeNotifier {
  void onSheetScrolled(
    BuildContext context,
    DraggableScrollableLockAtTopController controller,
    ProductHeaderType productHeaderType,
  ) {}
}

/// Use to compute the size of the header offline
class ProductHeaderWrapperForSize extends StatefulWidget {
  const ProductHeaderWrapperForSize(this.product, {super.key});

  final Product product;

  @override
  State<ProductHeaderWrapperForSize> createState() =>
      _ProductHeaderWrapperForSizeState();
}

class _ProductHeaderWrapperForSizeState
    extends State<ProductHeaderWrapperForSize>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: ProductHeaderBody.tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider<Product>.value(
      value: widget.product,
      child: ListenableProvider(
        create: (_) => _tabController,
        child: const ProductHeaderBody(),
      ),
    );
  }
}
