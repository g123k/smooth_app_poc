import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/search_page/data/search_page_data_source.dart';

class SearchSuggestionsStateManager
    extends ValueNotifier<SearchSuggestionsState> {
  SearchSuggestionsStateManager()
      : super(const SearchSuggestionsInitialState._()) {
    onSearchModified(null);
  }

  Future<void> onSearchModified(String? search) async {
    if (search?.isEmpty ?? true) {
      if (fakeSearchHistory.isEmpty) {
        value = SearchSuggestionsWithResultsState._(
          search: search,
          suggestions: fakeSearchSuggestions.map(
            (e) => SearchSuggestion._(e, SearchSuggestionType.suggestion),
          ),
        );
      } else {
        value = SearchSuggestionsWithResultsState._(
          search: search,
          suggestions: fakeSearchHistory.map(
            (e) => SearchSuggestion._(e, SearchSuggestionType.history),
          ),
        );
      }
    } else {
      value = SearchSuggestionsWithResultsState._(
        search: search,
        suggestions: fakeSearchHistory.where((element) {
          return element.toLowerCase().contains(search!.toLowerCase());
        }).map(
          (e) => SearchSuggestion._(e, SearchSuggestionType.history),
        ),
      );
    }
  }

  static SearchSuggestionsStateManager of(BuildContext context) {
    return context.read<SearchSuggestionsStateManager>();
  }
}

sealed class SearchSuggestionsState {
  final String? search;

  const SearchSuggestionsState._(this.search);
}

class SearchSuggestionsInitialState extends SearchSuggestionsState {
  const SearchSuggestionsInitialState._() : super._(null);
}

class SearchSuggestionsWithResultsState extends SearchSuggestionsState {
  final Iterable<SearchSuggestion> suggestions;

  const SearchSuggestionsWithResultsState._({
    required String? search,
    required this.suggestions,
  }) : super._(search);
}

enum SearchSuggestionType {
  history,
  suggestion,
}

class SearchSuggestion {
  final String term;
  final SearchSuggestionType type;

  const SearchSuggestion._(this.term, this.type);
}
