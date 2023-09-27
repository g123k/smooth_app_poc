import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smoothapp_poc/pages/homepage/list/horizontal_list.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart';

//ignore_for_file: constant_identifier_names
class MostScannedProducts extends StatelessWidget {
  const MostScannedProducts({super.key});

  static const BorderRadius _RADIUS = BorderRadius.all(Radius.circular(20.0));

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              top: 20.0,
              bottom: 10.0,
              left: 24.0,
              right: 24.0,
            ),
            child: Text(
              'Les produits les plus scannés en France',
              style: TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
                cardTheme: CardTheme(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              clipBehavior: Clip.antiAlias,
            )),
            child: HorizontalList(
              itemCount: _history.length,
              itemWidth: 200.0,
              itemHeight: 130.0,
              itemBuilder: (BuildContext context, int position) {
                final _HistoryItemData product = _history[position];
                return _HistoryItem(
                  product: product,
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => ProductPage(
                          product: Product(
                            productName: product.name,
                            brands: product.brand,
                            imageFrontUrl: product.picture,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              lastItemBuilder: (BuildContext context) {
                return _LastHistoryItem(
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const List<_HistoryItemData> _history = [
    _HistoryItemData(
      name: 'Eau de source',
      brand: 'Cristaline',
      picture:
          'https://images.openfoodfacts.org/images/products/327/408/000/5003/front_fr.950.400.jpg',
    ),
    _HistoryItemData(
      name: 'Nutella (400g)',
      brand: 'Ferrero',
      picture:
          'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_fr.594.200.jpg',
    ),
    _HistoryItemData(
      name: 'Price Chocolat Biscuits',
      brand: 'Lu',
      picture:
          'https://images.openfoodfacts.org/images/products/762/221/044/9283/front_fr.564.200.jpg',
    ),
    _HistoryItemData(
      name: 'Canette 33 cl',
      brand: 'Coca-Cola',
      picture:
          'https://images.openfoodfacts.org/images/products/544/900/021/4911/front_fr.200.200.jpg',
    ),
    _HistoryItemData(
      name: 'Nutella (1kg)',
      brand: 'Ferrero',
      picture:
          'https://images.openfoodfacts.org/images/products/301/762/042/5035/front_fr.481.200.jpg',
    ),
    _HistoryItemData(
      name: 'Canette 33 cl',
      brand: 'Coca Cola Zero',
      picture:
          'https://images.openfoodfacts.org/images/products/544/900/021/4799/front_fr.212.200.jpg',
    ),
    _HistoryItemData(
      name: 'Biscuit Sésame',
      brand: 'Gerblé',
      picture:
          'https://images.openfoodfacts.org/images/products/317/568/001/1480/front_fr.139.200.jpg',
    ),
  ];
}

class _HistoryItemData {
  final String name;
  final String brand;
  final String picture;

  const _HistoryItemData({
    required this.name,
    required this.brand,
    required this.picture,
  });
}

class _HistoryItem extends StatefulWidget {
  const _HistoryItem({
    required this.product,
    required this.onTap,
  });

  final _HistoryItemData product;
  final VoidCallback onTap;

  @override
  State<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem> {
  late final ImageProvider _provider;
  Color? _imageColor;

  @override
  void initState() {
    super.initState();
    _provider = NetworkImage(widget.product.picture);
    _detectColor();
  }

  void _detectColor() async {
    _imageColor = await ColorScheme.fromImageProvider(provider: _provider)
        .then((value) => value.primaryContainer);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _imageColor,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: MostScannedProducts._RADIUS,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: MostScannedProducts._RADIUS,
        child: Stack(
          children: [
            Positioned.fill(
              child: Ink.image(
                image: _provider,
                fit: BoxFit.contain,
              ),
            ),
            Positioned.fill(
              child: SizedBox.expand(
                child: Ink(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.95),
                          ],
                          stops: const [
                            0.5,
                            0.6,
                            1.0
                          ]),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10.0,
              left: 10.0,
              right: 10.0,
              child: Text(
                '${widget.product.name}\n${widget.product.brand}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastHistoryItem extends StatelessWidget {
  const _LastHistoryItem({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: MostScannedProducts._RADIUS,
      child: Ink(
        decoration: const BoxDecoration(
          color: AppColors.primaryVeryLight,
          borderRadius: MostScannedProducts._RADIUS,
        ),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 1.0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: CircledArrow(
                      size: 40.0,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Voir la suite du classement…',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
