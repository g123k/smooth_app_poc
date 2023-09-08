import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';
import 'package:smoothapp_poc/pages/search_page/search_state_manager.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/widgets/app_widget.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar.dart';
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
            _SearchBodyLoadingResults(
              search: state.value.search,
            ),
          SearchErrorState() => _SearchBodyLoadingResults(
              search: state.value.search,
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
  // TODO
  bool _showHelpBanner = true;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (BuildContext context, int position) {
        final Product product = widget.products[position];

        return InkWell(
          onTap: () {
            // TODO Open product page
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 26.0,
              vertical: 17.0,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.26,
                    height: double.infinity,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 36.0,
                          child: CompatibilityScore(
                            level: 100,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 110.0,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(10.0),
                              ),
                              child: ColoredBox(
                                color: AppColors.greyLight2,
                                child: Image.network(
                                  product.imageFrontUrl ?? '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.26,
                                  errorBuilder: (_, __, ___) =>
                                      const ImagePlaceholder(),
                                  loadingBuilder: (
                                    BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress,
                                  ) =>
                                      loadingProgress == null ||
                                              loadingProgress
                                                      .cumulativeBytesLoaded ==
                                                  loadingProgress
                                                      .expectedTotalBytes
                                          ? child
                                          : const ImagePlaceholder(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                          constraints: const BoxConstraints(minHeight: 36.0),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              product.productName ?? '',
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          product.brands ?? '',
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
                        )
                      ],
                    ),
                  ),
                ],
              ),
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

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: switch (level) {
          >= 0 && < 33 => AppColors.compatibilityHigh,
          >= 33 && < 6 => AppColors.compatibilityMedium,
          _ => AppColors.compatibilityLow,
        },
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '$level %',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SearchBodyLoadingResults extends StatelessWidget {
  const _SearchBodyLoadingResults({required this.search});

  final String? search;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/eye.svg',
              width: 87.0,
            ),
            if (search != null) ...[
              const SizedBox(height: 60.0),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    const TextSpan(text: 'Votre recherche de "'),
                    TextSpan(
                        text: search!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(
                      text:
                          '"est en cours.\nMerci de patienter quelques instants…',
                    ),
                  ],
                  style: DefaultTextStyle.of(context).style.copyWith(
                        height: 1.6,
                      ),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
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
  double get height => 50.0 + (HomePage.BORDER_RADIUS / 2);

  @override
  Color get color => AppColors.orangeVeryLight;
}
