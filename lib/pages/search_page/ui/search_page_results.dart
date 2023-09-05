import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/search_page/search_state_manager.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/utils/widgets/app_widget.dart';

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
  bool _showHelpBanner = true;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (BuildContext context, int position) {
        final Product product = widget.products[position];
        final bool hasBanner = _showHelpBanner && position == 0;

        return Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                // TODO Open product page
              },
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 26.0,
                  end: 26.0,
                  top: 17.0,
                  bottom: hasBanner ? 13.0 : 17.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.26,
                        maxHeight: MediaQuery.of(context).size.width * 0.26,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: ColoredBox(
                                  color: AppColors.greyLight2,
                                  child: Image.network(
                                    product.imageFrontUrl ?? '',
                                    width: MediaQuery.of(context).size.width *
                                        0.26,
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
                            Positioned.directional(
                              bottom: 5.0,
                              end: 5.0,
                              textDirection: Directionality.of(context),
                              child: const CompatibilityScore(
                                level: CompatibilityScoreLevel.high,
                              ),
                            )
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
                          Text(
                            product.productName ?? '',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
            if (hasBanner)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 26.0,
                  end: 26.0,
                  bottom: 12.0,
                ),
                child: InfoWidget(
                  text:
                      'La pastille de couleur sur la photo indique le degré de compatibilité avec vos préférences alimentaires (sur une échelle de vert à rouge)',
                  onClose: () {
                    setState(() => _showHelpBanner = false);
                  },
                  dismissible: true,
                  actionText: 'Modifier mes préférences',
                  actionCallback: () {
                    // TODO Open the food preferences
                  },
                ),
              ),
          ],
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

  final CompatibilityScoreLevel level;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: switch (level) {
              CompatibilityScoreLevel.high => AppColors.compatibilityHigh,
              CompatibilityScoreLevel.medium => AppColors.compatibilityMedium,
              CompatibilityScoreLevel.low => AppColors.compatibilityLow,
            },
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0.0, 2.0),
                blurRadius: 4.0,
              )
            ]),
      ),
    );
  }
}

enum CompatibilityScoreLevel {
  high,
  medium,
  low,
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
