import 'package:flutter/material.dart';
import 'package:smoothapp_poc/list/horizontal_list.dart';

class ProductHistoryList extends StatelessWidget {
  const ProductHistoryList({super.key});

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
              'Derniers produits scannés',
              style: TextStyle(
                fontSize: 19.0,
                decoration: TextDecoration.underline,
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
              itemCount: 5,
              itemWidth: 244.0,
              itemHeight: 130.0,
              itemBuilder: (BuildContext context, int position) {
                return _HistoryItem(
                  position: position,
                  onTap: () {},
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
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.position,
    required this.onTap,
    super.key,
  });

  final int position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: ProductHistoryList._RADIUS,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: ProductHistoryList._RADIUS,
        child: Stack(
          children: [
            Positioned.fill(
              child: Ink.image(
                image: const NetworkImage(
                  'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_fr.594.full.jpg',
                ),
                fit: BoxFit.cover,
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
            const Positioned(
              bottom: 10.0,
              left: 10.0,
              right: 10.0,
              child: Text(
                'Nutella (400g)\nFerrero',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
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
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: ProductHistoryList._RADIUS,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(15),
                child: const Icon(Icons.list),
              ),
              Text(
                'Voir l\'historique complet',
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
    );
  }
}
