import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/search_page/search_state_manager.dart';
import 'package:smoothapp_poc/pages/search_page/search_suggestions_state_manager.dart';
import 'package:smoothapp_poc/utils/provider_utils.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar.dart';

class SearchUIManager extends DistinctValueNotifier<SearchUIType> {
  SearchUIManager(BuildContext context)
      : _searchBarController = SearchBarController.find(context),
        _searchStateManager = SearchStateManager.of(context),
        _searchSuggestionsManager = SearchSuggestionsStateManager.of(context),
        super(SearchUIType.suggestions) {
    _searchStateManager.addListener(_onSearchStateChange);
    _searchSuggestionsManager.addListener(_onSearchSuggestionsStateChange);
  }

  final SearchStateManager _searchStateManager;
  final SearchSuggestionsStateManager _searchSuggestionsManager;
  final SearchBarController _searchBarController;

  void _onSearchStateChange() {
    // When we click on a suggestion, prefill the search bar +
    // hide the keyboard
    final String? search = _searchStateManager.value.search;
    if (_searchBarController.controller.text != search && search != null) {
      _searchBarController.controller.text = search;
      _searchBarController.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: search.length),
      );

      _searchBarController.hideKeyboard();

      value = SearchUIType.suggestions;
    } else {
      value = SearchUIType.results;
    }
  }

  void _onSearchSuggestionsStateChange() {
    value = SearchUIType.suggestions;
  }

  void showSearchResults() {
    value = SearchUIType.results;
  }

  void showSuggestions() {
    value = SearchUIType.suggestions;
  }

  bool get isShowingResults => value == SearchUIType.results;

  bool get isShowingSuggestions => value == SearchUIType.suggestions;

  @override
  void dispose() {
    super.dispose();
    _searchStateManager.removeListener(_onSearchStateChange);
    _searchSuggestionsManager.removeListener(_onSearchStateChange);
  }

  static SearchUIManager read(BuildContext context) {
    return context.read<SearchUIManager>();
  }

  static SearchUIManager watch(BuildContext context) {
    return context.watch<SearchUIManager>();
  }
}

enum SearchUIType {
  suggestions,
  results;
}
