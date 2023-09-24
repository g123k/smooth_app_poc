import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smoothapp_poc/pages/search_page/search_page.dart';
import 'package:smoothapp_poc/pages/search_page/search_state_manager.dart';
import 'package:smoothapp_poc/pages/search_page/search_suggestions_state_manager.dart';
import 'package:smoothapp_poc/pages/search_page/ui/search_page_utils.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar/search_bar.dart';

class SearchBodySuggestions extends StatelessWidget {
  const SearchBodySuggestions({
    required this.onExitSearch,
    super.key,
  });

  final VoidCallback onExitSearch;

  @override
  Widget build(BuildContext context) {
    return Selector<SearchSuggestionsStateManager,
        (String?, Iterable<SearchSuggestion>?)?>(
      selector: (BuildContext context, SearchSuggestionsStateManager value) {
        return switch (value.value) {
          SearchSuggestionsWithResultsState(
            search: final String? search,
            suggestions: final Iterable<SearchSuggestion> suggestions,
          ) =>
            (search, suggestions),
          _ => null,
        };
      },
      builder: (
        BuildContext context,
        (String?, Iterable<SearchSuggestion>?)? values,
        Widget? child,
      ) {
        final String? search = values?.$1;
        final Iterable<SearchSuggestion>? suggestions = values?.$2;
        final int count;

        if (values == null) {
          count = 0;
        } else if (_isInitialState(search)) {
          // No search = only suggestions
          count = suggestions!.length + 1;
        } else {
          // Search =
          // First element as the search query +
          // External link to advanced search +
          // Shortcut to scan a barcode
          count = suggestions!.length + 3;
        }

        return MultiSliver(children: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                // When search is not null, we have two more items
                if (!_isInitialState(search)) {
                  if (index == 0) {
                    return SearchQueryItem.search(
                      value: search!,
                      onTap: () {
                        SearchStateManager.of(context).search(search);
                        SearchBarController.of(context).hideKeyboard();
                      },
                    );
                  } else if (index == count - 1) {
                    return _scannerEntry(search, context);
                  } else if (index == count - 2) {
                    return SearchQueryItem.advancedSearch(
                      value: search!,
                      onTap: () {
                        launch(
                          'https://world.openfoodfacts.org/cgi/search.pl?action=display&search_terms=$search',
                        );
                      },
                    );
                  }
                } else if (index == 0) {
                  return _scannerEntry(search, context);
                }

                final SearchSuggestion suggestion =
                    suggestions!.elementAt(index - 1);
                return switch (suggestion.type) {
                  SearchSuggestionType.history => SearchQueryItem.history(
                      value: suggestion.term,
                      search: search,
                      onTap: () {
                        SearchStateManager.of(context).search(suggestion.term);
                      },
                    ),
                  SearchSuggestionType.banner => SearchQueryBanner(
                      search: suggestion.term,
                    ),
                  SearchSuggestionType.suggestion =>
                    SearchQueryItem.suggestions(
                      value: suggestion.term,
                      onTap: () {
                        SearchStateManager.of(context).search(suggestion.term);
                      },
                    ),
                };
              },
              childCount: count,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: GestureDetector(
              onTap: () {
                onExitSearch.call();
              },
              onPanStart: (_) {
                onExitSearch.call();
              },
            ),
          )
        ]);
      },
    );
  }

  SearchQueryItem _scannerEntry(String? search, BuildContext context) {
    return SearchQueryItem.scanner(
      value: search ?? '',
      onTap: () {
        Navigator.of(context).pop(SearchPageResult.openCamera);
      },
    );
  }

  bool _isInitialState(String? search) => search?.isEmpty ?? true;
}
