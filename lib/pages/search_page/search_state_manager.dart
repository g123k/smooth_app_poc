import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/search_page/data/search_page_data_source.dart';

class SearchStateManager extends ValueNotifier<SearchState> {
  SearchStateManager() : super(const SearchInitialState());

  CancelableOperation? _cancelableSearch;

  Future<void> search(String search) async {
    _cancelableSearch = CancelableOperation.fromFuture(
      _search(search),
    );
  }

  Future<void> _search(String search) async {
    value = SearchLoadingSearchState(search);
    addToHistory(search);

    try {
      final ProductSearchQueryConfiguration queryConfig =
          ProductSearchQueryConfiguration(
        fields: [ProductField.ALL],
        parametersList: [
          SearchTerms(terms: [search])
        ],
        version: ProductQueryVersion.v3,
      );
      final SearchResult results = await OpenFoodAPIClient.searchProducts(
        null,
        queryConfig,
      );

      if (results.products?.isEmpty ?? true) {
        value = SearchNoResultState(search);
      } else {
        value = SearchResultsState(
          search,
          results.products!,
          results.count ?? results.products!.length,
          queryConfig,
        );
      }
    } catch (_) {
      value = SearchErrorState(search);
    }

    _cancelableSearch = null;
  }

  bool get hasASearch => value is! SearchInitialState;

  bool get isLoading => value is SearchLoadingSearchState;

  bool get hasResults => value is SearchResultsState;

  void cancelSearch() {
    _cancelableSearch?.cancel();
    _cancelableSearch = null;
  }

  void forceReEmitEvent() {
    notifyListeners();
  }

  @override
  set value(SearchState newValue) {
    if (hasListeners &&
        (_cancelableSearch == null || _cancelableSearch?.isCanceled == false)) {
      super.value = newValue;
    }
  }

  @override
  void dispose() {
    cancelSearch();
    super.dispose();
  }

  static SearchStateManager of(BuildContext context) {
    return context.read<SearchStateManager>();
  }

  static SearchStateManager watch(BuildContext context) {
    return context.watch<SearchStateManager>();
  }
}

sealed class SearchState {
  final String? search;

  const SearchState._(this.search);
}

class SearchInitialState extends SearchState {
  const SearchInitialState() : super._(null);
}

class SearchLoadingSearchState extends SearchState {
  const SearchLoadingSearchState(String super.search) : super._();
}

class SearchErrorState extends SearchState {
  final Exception? exception;

  const SearchErrorState(String super.search, [this.exception]) : super._();
}

class SearchResultsState extends SearchState {
  final List<Product> products;
  final ProductSearchQueryConfiguration configuration;
  final int total;

  const SearchResultsState(
    String super.search,
    this.products,
    this.total,
    this.configuration,
  ) : super._();
}

class SearchNoResultState extends SearchState {
  const SearchNoResultState(String super.search) : super._();
}
