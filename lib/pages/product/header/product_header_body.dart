import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/product/header/product_header.dart';
import 'package:smoothapp_poc/pages/product/header/product_tabs.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/widgets/list.dart';
import 'package:smoothapp_poc/utils/widgets/material.dart';

class ProductHeaderBody extends StatelessWidget {
  const ProductHeaderBody({
    super.key,
    this.onElementTapped,
    this.onTabChanged,
    this.shrinkContent,
  });

  final Function(ElementTappedType)? onElementTapped;
  final Function(int)? onTabChanged;
  final double? shrinkContent;

  static const List<ProductHeaderTabs> tabs = [
    ProductHeaderTabs.forMe,
    ProductHeaderTabs.health,
    ProductHeaderTabs.environment,
    ProductHeaderTabs.photos,
    ProductHeaderTabs.contribute,
    ProductHeaderTabs.info,
  ];

  @override
  Widget build(BuildContext context) {
    final Widget headerDetails = ProductHeaderDetails(
      onNutriScoreClicked: () {
        onElementTapped?.call(ElementTappedType.nutriscore);
      },
      onEcoScoreClicked: () {
        onElementTapped?.call(ElementTappedType.ecoscore);
      },
    );

    if (shrinkContent == null) {
      // Only used when we pre-compute the size
      return Material(
        type: MaterialType.canvas,
        child: Align(
          child: ClipRect(
            child: Column(
              children: [
                headerDetails,
                ProductHeaderTabBar(
                  onTabChanged: onTabChanged,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      final ThemeData theme = Theme.of(context);
      return DynamicMaterial(
        type: MaterialType.canvas,
        elevationThreshold: ProductHeaderConfiguration.of(context).minThreshold,
        color: theme.scaffoldBackgroundColor,
        child: Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.apply(fontFamily: 'OpenSans'),
          ),
          child: Align(
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned.fill(
                    top: shrinkContent!,
                    bottom: null,
                    child: Opacity(
                      opacity: 1 -
                          (shrinkContent!.progress(
                            0,
                            -ProductHeaderConfiguration.of(context)
                                .minThreshold,
                          )).clamp(0.0, 1.0),
                      child: headerDetails,
                    ),
                  ),
                  Positioned.fill(
                    top: null,
                    child: ProductHeaderTabBar(
                      onTabChanged: onTabChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class ProductHeaderDetails extends StatelessWidget {
  const ProductHeaderDetails({
    this.onNutriScoreClicked,
    this.onEcoScoreClicked,
    super.key,
  });

  //ignore_for_file: constant_identifier_names
  static const int INFO_WIDTH = 82;
  static const int SCORES_WIDTH = 18;
  static const EdgeInsetsDirectional PADDING = EdgeInsetsDirectional.only(
    top: 18.0,
    start: 20.0,
    end: 20.0,
    bottom: 20.0,
  );

  final VoidCallback? onNutriScoreClicked;
  final VoidCallback? onEcoScoreClicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: PADDING,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: INFO_WIDTH,
                    child: Semantics(
                      sortKey: const OrdinalSortKey(1.0),
                      child: const _ProductHeaderInfo(),
                    ),
                  ),
                  Expanded(
                    flex: SCORES_WIDTH,
                    child: Semantics(
                      sortKey: const OrdinalSortKey(2.0),
                      child: ProductHeaderScores(
                        onNutriScoreClicked: onNutriScoreClicked,
                        onEcoScoreClicked: onEcoScoreClicked,
                      ),
                    ),
                  ),
                ],
              ),
              Semantics(
                sortKey: const OrdinalSortKey(3.0),
                explicitChildNodes: true,
                child: const _ProductHeaderPersonalScores(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductHeaderInfo extends StatelessWidget {
  const _ProductHeaderInfo();

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: '3274080005003_name',
          child: Text(
            product.productName ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        Text(
          product.brands ?? '',
          style: const TextStyle(fontSize: 16.5),
        ),
        Text(
          product.quantity ?? '',
          style: const TextStyle(fontSize: 16.5),
        ),
      ],
    );
  }
}

class ProductHeaderScores extends StatelessWidget {
  const ProductHeaderScores({
    super.key,
    required this.onNutriScoreClicked,
    required this.onEcoScoreClicked,
  });

  final VoidCallback? onNutriScoreClicked;
  final VoidCallback? onEcoScoreClicked;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: onNutriScoreClicked,
              child: SvgPicture.asset(
                'assets/images/nutriscore-a.svg',
                alignment: AlignmentDirectional.topCenter,
                width: math.min(80.0, constraints.maxWidth),
              ),
            ),
            const SizedBox(height: 10.0),
            InkWell(
              onTap: onEcoScoreClicked,
              child: SvgPicture.asset(
                'assets/images/ecoscore-a.svg',
                alignment: AlignmentDirectional.topCenter,
                width: math.min(80.0, constraints.maxWidth),
              ),
            ),
          ],
        );
      },
    );
  }

  static double computeWidth(BuildContext context) => math.min(
      80.0,
      (MediaQuery.sizeOf(context).width -
              ProductHeaderDetails.PADDING.horizontal) *
          (ProductHeaderDetails.SCORES_WIDTH / 100));
}

class _ProductHeaderPersonalScores extends StatelessWidget {
  const _ProductHeaderPersonalScores();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListItem.text(
          'Pas de moutarde',
          padding: const EdgeInsets.only(top: 10.0),
          leading: const ListItemLeadingScore.high(),
        ),
        ListItem.text(
          'Aliment ultra-transformé (NOVA 4)',
          padding: const EdgeInsets.only(top: 10.0),
          leading: const ListItemLeadingScore.low(),
        ),
      ],
    );
  }
}

enum ProductHeaderTabs {
  forMe,
  health,
  environment,
  photos,
  contribute,
  info,
}
