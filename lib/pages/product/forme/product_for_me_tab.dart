import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/data/product_compatibility.dart';
import 'package:smoothapp_poc/pages/food_preferences/food_preferences.dart';
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
    // Force the tab to reload
    context.watch<ProductCompatibility>();

    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTapDown: (TapDownDetails details) async {
          if (foodPreferencesDefined && details.localPosition.dy < 50) {
            if (await Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                  builder: (context) => const FoodPreferencesPage(),
                )) ==
                true) {
              ProductPage.of(context).forceReload();
            }
          }
        },
        child: Column(
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: (constraints.maxWidth / 428) * 363,
              child: Image.asset(
                'assets/images/${foodPreferencesDefined ? 'product_forme' : 'product_forme_empty'}.webp',
                // 428 x 808
                width: constraints.maxWidth,
                height: (constraints.maxWidth / 428) * 363,
                alignment: AlignmentDirectional.topCenter,
                fit: BoxFit.fitWidth,
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (await Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(
                          builder: (context) => const FoodPreferencesPage(),
                        )) ==
                        true &&
                    mounted) {
                  ProductPage.of(context).forceReload();
                }
              },
              child: Image.asset(
                'assets/images/product_forme_empty_button.webp',
                // 428 x 808
              ),
            ),
          ],
        ),
      );
    });
  }
}
