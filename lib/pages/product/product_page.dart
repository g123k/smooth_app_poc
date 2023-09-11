import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/contribute/product_contribute_tab.dart';
import 'package:smoothapp_poc/pages/product/environment/product_environment_tab.dart';
import 'package:smoothapp_poc/pages/product/forme/product_for_me_tab.dart';
import 'package:smoothapp_poc/pages/product/header/product_header.dart';
import 'package:smoothapp_poc/pages/product/health/product_health_tab.dart';
import 'package:smoothapp_poc/pages/product/info/product_info_tab.dart';
import 'package:smoothapp_poc/pages/product/photos/product_photos_tab.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';
import 'package:smoothapp_poc/utils/widgets/offline_size_widget.dart';
import 'package:smoothapp_poc/utils/widgets/useful_widgets.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    required this.product,
    this.scrollController,
    super.key,
  })  : topSliverHeight = null,
        forModalSheet = false;

  const ProductPage.fromModalSheet({
    required this.product,
    this.scrollController,
    this.topSliverHeight,
    super.key,
  }) : forModalSheet = true;

  final bool forModalSheet;
  final double? topSliverHeight;
  final ScrollController? scrollController;

  final Product product;

  @override
  State<ProductPage> createState() => _ProductPageState();

  static Widget buildHeader(Product product) =>
      ProductHeaderWrapperForSize(product);
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  late ScrollController _scrollController;
  double? _headerHeight;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ProductHeaderBody.tabs.length,
      vsync: this,
    );
    _pageController = PageController(
      keepPage: false,
    );

    _scrollController = widget.scrollController ?? ScrollController();

    _headerHeight = widget.topSliverHeight;

    if (_headerHeight == null) {
      onNextFrame(() {
        ComputeOfflineSize(
            context: context,
            widget: ProductPage.buildHeader(widget.product),
            onSizeAvailable: (Size size) {
              setState(() {
                _headerHeight = size.height;
              });
            });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forModalSheet) {
      return _buildChild(context);
    } else {
      return Scaffold(
        body: SafeArea(
          child: _buildChild(context),
        ),
      );
    }
  }

  Widget _buildChild(BuildContext context) {
    if (_headerHeight == null) {
      return EMPTY_WIDGET;
    }

    return MultiProvider(
      providers: [
        Provider<Product>.value(value: widget.product),
        Provider<ProductHeaderConfiguration>.value(
          value: ProductHeaderConfiguration(
            maxHeight: _headerHeight!,
            type: widget.forModalSheet
                ? ProductHeaderType.modalSheet
                : ProductHeaderType.fullPage,
          ),
        ),
        ListenableProvider<TabController>.value(value: _tabController),
        ListenableProvider.value(value: _scrollController)
      ],
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // The shrinkable header
          ProductHeader(
            onElementTapped: (
              ElementTappedType type,
              double scrollExpectedPosition,
            ) async {
              switch (type) {
                case ElementTappedType.nutriscore:
                  _tabController.animateTo(1);
                case ElementTappedType.ecoscore:
                  _tabController.animateTo(2);
              }

              await _onTabChanged(scrollExpectedPosition);
            },
            onTabChanged: (
              int position,
              double scrollExpectedPosition,
            ) async {
              await _onTabChanged(scrollExpectedPosition);
            },
          ),
          // The body
          SliverToBoxAdapter(
            child: Consumer<TabController>(builder: (_, __, ___) {
              return switch (_tabController.index) {
                0 => const ProductForMeTab(),
                1 => const ProductHealthTab(),
                2 => const ProductEnvironmentTab(),
                3 => const ProductPhotosTab(),
                4 => const ProductContributeTab(),
                _ => const ProductInfoTab(),
              };
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _onTabChanged(double scrollExpectedPosition) async {
    if (_isSheetVisible) {
      _scrollController.animateTo(
        scrollExpectedPosition,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
      );
    } else {
      _openSheet(context);
      _scrollController.jumpTo(scrollExpectedPosition);
    }
  }

  bool get _isSheetVisible {
    try {
      final DraggableScrollableController controller =
          context.read<DraggableScrollableController>();

      return controller.size >= 1.0;
    } catch (_) {
      return false;
    }
  }

  /// Returns if the sheet was opened
  Future<void> _openSheet(BuildContext context) async {
    try {
      final DraggableScrollableController controller =
          context.read<DraggableScrollableController>();

      if (controller.size < 1.0) {
        return controller.animateTo(
          1,
          curve: Curves.easeInExpo,
          duration: const Duration(milliseconds: 200),
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ProductHeaderConfiguration {
  ProductHeaderConfiguration({
    required this.maxHeight,
    required this.type,
  });

  final double maxHeight;
  final ProductHeaderType type;

  double get minThreshold => maxHeight - minHeight;

  /// We can hardcode here the default size of the [TabBar], because it's a
  /// private constant
  double get minHeight => 48.0;

  static ProductHeaderConfiguration of(BuildContext context) {
    return context.read<ProductHeaderConfiguration>();
  }
}

enum ProductHeaderType {
  modalSheet,
  fullPage,
}
