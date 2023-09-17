import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/product/header/product_header_body.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/pages/product/product_page_fab.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;

class ProductForMeTab extends StatefulWidget {
  const ProductForMeTab({super.key});

  @override
  State<ProductForMeTab> createState() => _ProductForMeTabState();
}

class _ProductForMeTabState extends State<ProductForMeTab> {
  @override
  void initState() {
    super.initState();

    ProductPage.of(context).showFAB(
      ProductPageFAB(
        label: 'Personnaliser',
        icon: const icons.Edit(),
        onTap: () {
          // TODO
        },
      ),
      ProductHeaderTabs.forMe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: (constraints.maxWidth / 428) * 808,
        child: Image.asset(
          'assets/images/product_forme.webp',
          // 428 x 808
          width: constraints.maxWidth,
          height: (constraints.maxWidth / 428) * 808,
          alignment: AlignmentDirectional.topCenter,
        ),
      );
    });
  }
}
