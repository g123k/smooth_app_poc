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
    value = SearchLoadingSearchState(search);
  }

  Future<void> _search(String search) async {
    addToHistory(search);

    try {
      final SearchResult results = await OpenFoodAPIClient.searchProducts(
        null,
        ProductSearchQueryConfiguration(
          fields: [ProductField.ALL],
          parametersList: [],
          version: ProductQueryVersion.v3,
        ),
      );

      if (results.products?.isEmpty ?? true) {
        value = SearchNoResultState(search);
      } else {
        value = SearchResultsState(search, results.products!);
      }
    } catch (_) {
      value = SearchErrorState(search);
    }

    _cancelableSearch = null;
  }

  void cancelSearch() {
    _cancelableSearch?.cancel();
    _cancelableSearch = null;
  }

  @override
  set value(SearchState newValue) {
    if (_cancelableSearch != null || _cancelableSearch?.isCompleted == false) {
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
}

sealed class SearchState {
  final String? search;

  const SearchState._(this.search);
}

class SearchInitialState extends SearchState {
  const SearchInitialState() : super._(null);
}

class SearchLoadingSearchState extends SearchState {
  const SearchLoadingSearchState(String search) : super._(search);
}

class SearchErrorState extends SearchState {
  final Exception? exception;

  const SearchErrorState(String search, [this.exception]) : super._(search);
}

class SearchResultsState extends SearchState {
  final List<Product> products;

  const SearchResultsState(String search, this.products) : super._(search);
}

class SearchNoResultState extends SearchState {
  const SearchNoResultState(String search) : super._(search);
}
