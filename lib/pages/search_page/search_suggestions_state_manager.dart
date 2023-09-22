import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/search_page/data/search_page_data_source.dart';

class SearchSuggestionsStateManager
    extends ValueNotifier<SearchSuggestionsState> {
  SearchSuggestionsStateManager()
      : super(const SearchSuggestionsInitialState._()) {
    onSearchModified(null);
  }

  Future<void> onSearchModified(String? search, {bool force = false}) async {
    Iterable<SearchSuggestion> suggestions;
    if (search?.isEmpty ?? true) {
      if (fakeSearchHistory.isEmpty) {
        suggestions = fakeSearchSuggestions.map(
          (e) => SearchSuggestion._(e, SearchSuggestionType.suggestion),
        );
      } else {
        suggestions = fakeSearchHistory.map(
          (e) => SearchSuggestion._(e, SearchSuggestionType.history),
        );
      }
    } else {
      suggestions = fakeSearchHistory.where((element) {
        return element.toLowerCase().contains(search!.toLowerCase());
      }).map(
        (e) => SearchSuggestion._(e, SearchSuggestionType.history),
      );
    }

    // TODO: Improve this
    if (search?.toLowerCase().startsWith('casso') == true) {
      suggestions = suggestions.toList()
        ..insert(
          0,
          const SearchSuggestion._(
            'Cassoulet',
            SearchSuggestionType.suggestion,
          ),
        );
    } else if (search?.toLowerCase().startsWith('crist') == true) {
      suggestions = suggestions.toList()
        ..insert(
          0,
          const SearchSuggestion._(
            'Cristaline',
            SearchSuggestionType.banner,
          ),
        );
    }

    value = SearchSuggestionsWithResultsState._(
      search: search,
      suggestions: suggestions,
    );
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
  banner,
}

class SearchSuggestion {
  final String term;
  final SearchSuggestionType type;

  const SearchSuggestion._(this.term, this.type);
}
