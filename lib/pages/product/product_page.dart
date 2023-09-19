import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/contribute/product_contribute_tab.dart';
import 'package:smoothapp_poc/pages/product/environment/product_environment_tab.dart';
import 'package:smoothapp_poc/pages/product/footer/product_footer.dart';
import 'package:smoothapp_poc/pages/product/forme/product_for_me_tab.dart';
import 'package:smoothapp_poc/pages/product/header/product_header.dart';
import 'package:smoothapp_poc/pages/product/header/product_tabs.dart';
import 'package:smoothapp_poc/pages/product/health/product_health_tab.dart';
import 'package:smoothapp_poc/pages/product/info/product_info_tab.dart';
import 'package:smoothapp_poc/pages/product/photos/product_photos_tab.dart';
import 'package:smoothapp_poc/pages/product/product_page_fab.dart';
import 'package:smoothapp_poc/utils/physics.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';
import 'package:smoothapp_poc/utils/widgets/modal_sheet.dart';
import 'package:smoothapp_poc/utils/widgets/offline_size_widget.dart';
import 'package:smoothapp_poc/utils/widgets/page_view.dart';
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
  State<ProductPage> createState() => ProductPageState();

  static Widget buildHeader(Product product) =>
      ProductHeaderWrapperForSize(product);

  static ProductPageState of(BuildContext context) {
    return context.read<ProductPageState>();
  }
}

class ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin, ProductPageFABContainer {
  late final TabController _tabController;
  late final PageController _horizontalScrollController;
  late final ScrollController _verticalScrollController;
  late final ProductHeaderConfiguration _productHeaderConfiguration;
  double? _headerHeight;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ProductHeaderBody.tabs.length,
      vsync: this,
    );

    _horizontalScrollController = PageController(
      keepPage: true,
    )..addListener(_onPageHorizontallyScrolled);

    _verticalScrollController =
        widget.scrollController ?? TrackingScrollController();

    _headerHeight = widget.topSliverHeight;

    if (_headerHeight == null) {
      onNextFrame(() {
        ComputeOfflineSize(
            context: context,
            widget: ProductPage.buildHeader(widget.product),
            onSizeAvailable: (Size size) {
              _headerHeight = size.height;
              _initHeaderConfig();
              setState(() {});
            });
      });
    } else {
      _initHeaderConfig();
    }
  }

  void _initHeaderConfig() {
    _productHeaderConfiguration = ProductHeaderConfiguration(
      maxHeight: _headerHeight!,
      type: widget.forModalSheet
          ? ProductHeaderType.modalSheet
          : ProductHeaderType.fullPage,
    );
  }

  void _onPageHorizontallyScrolled() {
    if (_tabController.indexIsChanging) {
      return;
    }

    final double offset = _horizontalScrollController.page! -
        _horizontalScrollController.page!.floor();

    if (_horizontalScrollController.page! >= _tabController.index + 1 ||
        _horizontalScrollController.page! <= _tabController.index - 1) {
      _tabController.index = _horizontalScrollController.page!.toInt();
      onPageChanged(ProductHeaderTabs.values[_tabController.index]);
    } else if (_horizontalScrollController.page! == _tabController.index - 1) {
      _tabController.index -= 1;
    } else if (_horizontalScrollController.page! >= _tabController.index) {
      _tabController.offset = offset;
    } else {
      _tabController.offset = -(1 - offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forModalSheet) {
      return Stack(
        children: [
          Positioned.fill(child: _buildChild(context)),
          const Positioned.fill(
            top: null,
            child: ProductFooter(),
          )
        ],
      );
    } else {
      return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: SafeArea(
            top: false,
            bottom: false,
            child: _buildChild(context),
          ),
        ),
        bottomNavigationBar: const ProductFooter(),
      );
    }
  }

  Widget _buildChild(BuildContext context) {
    if (_headerHeight == null) {
      return EMPTY_WIDGET;
    }

    return MultiProvider(
      providers: [
        Provider<ProductPageState>.value(value: this),
        Provider<Product>.value(value: widget.product),
        Provider<ProductHeaderConfiguration>.value(
          value: _productHeaderConfiguration,
        ),
        ListenableProvider<TabController>.value(
          value: _tabController,
        ),
        ListenableProvider<PageController>.value(
          value: _horizontalScrollController,
        ),
        ListenableProvider<ScrollController>.value(
          value: _verticalScrollController,
        )
      ],
      child: Builder(builder: (BuildContext context) {
        return VerticalClampScroll(
          steps: [
            0.0,
            ProductHeaderConfiguration.of(context).minThreshold,
          ],
          blockBetweenSteps: !widget.forModalSheet,
          child: CustomScrollView(
            controller: _verticalScrollController,
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
                onCardTapped: () {
                  if (!_isSheetVisible) {
                    _openSheet(context);
                  }
                },
              ),
              SliverLayoutBuilder(
                builder: (BuildContext context, SliverConstraints constraints) {
                  final MediaQueryData mediaQuery = MediaQuery.of(context);
                  final double min = mediaQuery.size.height +
                      mediaQuery.viewPadding.top -
                      kToolbarHeight -
                      48;

                  return SliverToBoxAdapter(
                    child: PageViewSizeAware(
                      minHeight: min,
                      controller: _horizontalScrollController,
                      itemCount: 6,
                      itemBuilder: (BuildContext context, int position) {
                        return SafeArea(
                          top: false,
                          child: switch (position) {
                            0 => const ProductForMeTab(),
                            1 => const ProductHealthTab(),
                            2 => const ProductEnvironmentTab(),
                            3 => const ProductPhotosTab(),
                            4 => const ProductContributeTab(),
                            _ => const ProductInfoTab(),
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              // The body
            ],
          ),
        );
      }),
    );
  }

  Future<void> _onTabChanged(double scrollExpectedPosition) async {
    if (!_isSheetVisible) {
      _openSheet(context);
    } else if (_verticalScrollController.offset > scrollExpectedPosition) {
      _verticalScrollController.animateTo(
        scrollExpectedPosition,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
      );
    }

    _horizontalScrollController.animateToPage(
      _tabController.index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  bool get _isSheetVisible {
    try {
      final DraggableScrollableLockAtTopController controller =
          context.read<DraggableScrollableLockAtTopController>();

      return controller.size >= 1.0;
    } catch (_) {
      return false;
    }
  }

  /// Returns if the sheet was opened
  Future<void> _openSheet(BuildContext context) async {
    try {
      final DraggableScrollableLockAtTopController controller =
          context.read<DraggableScrollableLockAtTopController>();

      if (controller.size < 1.0) {
        return controller.animateTo(
          1,
          curve: Curves.easeInExpo,
          duration: const Duration(milliseconds: 300),
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _horizontalScrollController.dispose();

    super.dispose();
  }

  Future<void> ensureTabVisible(ProductHeaderTabs tab) async {
    int page = ProductHeaderTabs.values.indexOf(tab);

    if (_verticalScrollController.offset > _headerHeight!) {
      await _verticalScrollController.animateTo(
        _headerHeight!,
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
      );
    }

    if (!mounted) {
      return;
    }

    if (_horizontalScrollController.page != page) {
      _horizontalScrollController.animateTo(
        page.toDouble(),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
      );
    } else {
      _horizontalScrollController.animateTo(
        (MediaQuery.sizeOf(context).width * 0.1),
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
      );
    }
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
  double get minHeight => ProductHeaderTabBar.TAB_BAR_HEIGHT - 1.0;

  static ProductHeaderConfiguration of(BuildContext context) {
    return context.read<ProductHeaderConfiguration>();
  }
}

enum ProductHeaderType {
  modalSheet,
  fullPage,
}
