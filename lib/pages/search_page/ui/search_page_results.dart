import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/data/product_compatibility.dart';
import 'package:smoothapp_poc/pages/food_preferences/food_preferences.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/pages/search_page/search_state_manager.dart';
import 'package:smoothapp_poc/pages/search_page/ui/search_page_loading.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/widgets/list.dart';
import 'package:smoothapp_poc/utils/widgets/network_image.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar/search_bar.dart';
import 'package:smoothapp_poc/utils/widgets/useful_widgets.dart';

class SearchBodyResults extends StatefulWidget {
  const SearchBodyResults({super.key});

  @override
  State<SearchBodyResults> createState() => _SearchBodyResultsState();
}

class _SearchBodyResultsState extends State<SearchBodyResults>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<SearchStateManager>(
      builder: (
        BuildContext context,
        SearchStateManager state,
        Widget? child,
      ) {
        return switch (state.value) {
          SearchInitialState() ||
          SearchLoadingSearchState() =>
            SearchPageLoading(
              search: state.value.search!,
            ),
          SearchErrorState() => SearchPageLoading(
              search: state.value.search!,
            ),
          SearchResultsState(products: final List<Product> products) =>
            _SearchBodyWithResults(
              products: products,
            ),
          SearchNoResultState() => _SearchBodyNoResult(
              search: state.value.search!,
            ),
        };
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SearchBodyWithResults extends StatefulWidget {
  const _SearchBodyWithResults({required this.products});

  final List<Product> products;

  @override
  State<_SearchBodyWithResults> createState() => _SearchBodyWithResultsState();
}

class _SearchBodyWithResultsState extends State<_SearchBodyWithResults> {
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (BuildContext context, int position) {
        final Product product = widget.products[position];
        final ProductCompatibility score = ProductCompatibility(
            100 * (1 - position.progress(0, widget.products.length)));

        return InkWell(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => ProductPage(
                  product: product,
                  compatibility: foodPreferencesDefined ? score : null,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 26.0,
              vertical: 17.0,
            ),
            child: Column(
              children: <Widget>[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.26,
                        height: double.infinity,
                        child: IntrinsicWidth(
                          child: Column(
                            children: [
                              if (foodPreferencesDefined)
                                SizedBox(
                                  height: 36.0,
                                  child: CompatibilityScore(level: score),
                                ),
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: foodPreferencesDefined
                                      ? Radius.zero
                                      : const Radius.circular(10.0),
                                  bottom: const Radius.circular(10.0),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  color: AppColors.greyLight2,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 110.0,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: Hero(
                                        tag: product.imageFrontUrl ?? '',
                                        child: NetworkAppImage(
                                          url: product.imageFrontUrl ?? '',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.26,
                                          topRadius: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(minHeight: 36.0),
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  product.productName ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              product.brands?.isNotEmpty == true
                                  ? product.brands!
                                  : 'Marque non spécifiée',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16.5,
                              ),
                            ),
                            Text(
                              product.quantity ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16.5,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/nutriscore-a.svg',
                                  height: 39.0,
                                ),
                                const SizedBox(width: 18.0),
                                SvgPicture.asset(
                                  'assets/images/ecoscore-a.svg',
                                  height: 34.0,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (foodPreferencesDefined) ...[
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
                ]
              ],
            ),
          ),
        );
      },
      itemCount: widget.products.length,
      separatorBuilder: (_, __) => const ListItemDivider(),
    );
  }
}

class CompatibilityScore extends StatelessWidget {
  const CompatibilityScore({
    required this.level,
    this.size = 18.0,
    super.key,
  });

  final ProductCompatibility level;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: level.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        foodPreferencesDefined ? '${level.level?.toInt() ?? '-'} %' : '-',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SearchBodyNoResult extends StatelessWidget {
  const _SearchBodyNoResult({required this.search});

  final String search;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/search.svg',
              width: 87.0,
            ),
            const SizedBox(height: 60.0),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                      text: 'Aucun produit ne correspond à votre recherche "'),
                  TextSpan(
                      text: search,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                    text:
                        '".\nOpen Food Facts est une base de données communautaire, n\'hésitez pas à y contribuer !',
                  ),
                ],
                style: DefaultTextStyle.of(context).style.copyWith(
                      height: 1.6,
                    ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchFooterResults extends StatelessWidget
    implements SearchBarFooterWidget {
  const SearchFooterResults({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<SearchStateManager>().value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: switch (context.watch<SearchStateManager>().value) {
        SearchResultsState(products: final List<Product> products) => Row(
            children: [
              const icons.Info(
                size: 24.0,
                color: AppColors.blackSecondary,
              ),
              const SizedBox(width: 18.0),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: products.length.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' produits trouvés (en France)\n'),
                      const TextSpan(
                        text: 'Résultats mis en cache depuis : 2 semaines',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    ],
                    style: DefaultTextStyle.of(context).style.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                ),
              ),
            ],
          ),
        _ => EMPTY_WIDGET
      },
    );
  }

  @override
  double get height => 50.0;

  @override
  Color get color => AppColors.primaryVeryLight;
}
