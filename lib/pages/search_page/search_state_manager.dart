import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';

class SearchStateManager extends ValueNotifier<SearchState> {
  SearchStateManager() : super(const SearchInitialState());

  // TODO
  final List<String> _fakeHistory = [];
  static const List<String> _fakeSuggestions = [
    'Nutella',
    'Christaline',
    'Pâtes à la bolognaise',
  ];

  Future<void> search(String search) async {
    value = SearchLoadingSearchState(search);
    _addToHistory(search);

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
        value = const SearchNoResultState();
      } else {
        value = SearchResultsState(results.products!);
      }
    } catch (_) {
      value = SearchErrorState(search);
    }
  }

  void _addToHistory(String search) {
    if (!_fakeHistory.contains(search.trim())) {
      _fakeHistory.add(search.trim());
    }
  }

  static SearchStateManager of(BuildContext context) {
    return context.read<SearchStateManager>();
  }
}

sealed class SearchState {
  const SearchState._();
}

class SearchInitialState extends SearchState {
  const SearchInitialState() : super._();
}

class SearchLoadingSearchState extends SearchState {
  final String search;

  const SearchLoadingSearchState(this.search) : super._();
}

class SearchErrorState extends SearchState {
  final String search;
  final Exception? exception;

  const SearchErrorState(this.search, [this.exception]) : super._();
}

class SearchResultsState extends SearchState {
  final List<Product> products;

  const SearchResultsState(this.products) : super._();
}

class SearchNoResultState extends SearchState {
  const SearchNoResultState() : super._();
}
