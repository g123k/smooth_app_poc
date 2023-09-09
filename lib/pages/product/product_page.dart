import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smoothapp_poc/pages/product/contribute/product_contribute_tab.dart';
import 'package:smoothapp_poc/pages/product/environment/product_environment_tab.dart';
import 'package:smoothapp_poc/pages/product/forme/product_for_me_tab.dart';
import 'package:smoothapp_poc/pages/product/health/product_health_tab.dart';
import 'package:smoothapp_poc/pages/product/info/product_info_tab.dart';
import 'package:smoothapp_poc/pages/product/photos/product_photos_tab.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/widgets/list.dart';

part 'product_header.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    required this.product,
    this.topSliver,
    this.scrollController,
    super.key,
  }) : forModalSheet = false;

  const ProductPage.fromModalSheet({
    required this.product,
    this.topSliver,
    this.scrollController,
    super.key,
  }) : forModalSheet = true;

  final bool forModalSheet;
  final Product product;
  final Widget? topSliver;
  final ScrollController? scrollController;

  @override
  State<ProductPage> createState() => _ProductPageState();

  static Widget buildHeader(Product product) =>
      _ProductHeaderWrapperForSize(product);
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _ProductHeader.tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forModalSheet) {
      return _buildChild(context);
    } else {
      return Scaffold(
        body: SafeArea(child: _buildChild(context)),
      );
    }
  }

  Widget _buildChild(BuildContext context) {
    return Provider<Product>.value(
      value: widget.product,
      child: ListenableProvider<TabController>(
        create: (_) => _tabController,
        child: CustomScrollView(
          controller: widget.scrollController ?? ScrollController(),
          slivers: [
            if (widget.topSliver != null) widget.topSliver!,
            SliverPinnedHeader(
              child: _ProductHeader(
                onElementTapped: () {
                  _openSheetIfNecessary(context);
                },
              ),
            ),
            Consumer<TabController>(builder: (_, __, ___) {
              return switch (_tabController.index) {
                0 => const ProductForMeTab(),
                1 => const ProductHealthTab(),
                2 => const ProductEnvironmentTab(),
                3 => const ProductPhotosTab(),
                4 => const ProductContributeTab(),
                _ => const ProductInfoTab(),
              };
            })
          ],
        ),
      ),
    );
  }

  void _openSheetIfNecessary(BuildContext context) {
    try {
      final DraggableScrollableController controller =
          context.read<DraggableScrollableController>();

      if (controller.size < 1.0) {
        controller.animateTo(
          1,
          curve: Curves.easeInExpo,
          duration: const Duration(milliseconds: 200),
        );
      }
    } catch (_) {}
  }
}
