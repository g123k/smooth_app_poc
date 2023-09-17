import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/product/header/product_header.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/pages/product/product_page_fab.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;

class ProductPhotosTab extends StatefulWidget {
  const ProductPhotosTab({super.key});

  @override
  State<ProductPhotosTab> createState() => _ProductPhotosTabState();
}

class _ProductPhotosTabState extends State<ProductPhotosTab> {
  @override
  void initState() {
    super.initState();

    ProductPage.of(context).showFAB(
      ProductPageFAB(
        label: 'Ajouter une photo',
        icon: const icons.Add(),
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
        height: (constraints.maxWidth / 856) * 1616,
        child: Image.asset(
          'assets/images/product_photos.webp',
          // 856 x 1616
          width: constraints.maxWidth,
          height: (constraints.maxWidth / 856) * 1616,
          alignment: AlignmentDirectional.topCenter,
        ),
      );
    });
  }
}
