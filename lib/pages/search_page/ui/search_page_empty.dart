import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smoothapp_poc/pages/search_page/search_state_manager.dart';
import 'package:smoothapp_poc/pages/search_page/search_suggestions_state_manager.dart';
import 'package:smoothapp_poc/pages/search_page/ui/search_page_utils.dart';

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
          count = suggestions!.length;
        } else {
          // Search = Show the first element as the search query +
          // add the external link
          count = suggestions!.length + 2;
        }

        return MultiSliver(children: [
          SliverFixedExtentList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                // When search is not null, we have two more items
                if (!_isInitialState(search)) {
                  if (index == 0) {
                    return SearchQueryItem.search(
                      value: search!,
                      onTap: () {
                        SearchStateManager.of(context).search(search!);
                      },
                    );
                  } else if (index == count - 1) {
                    return SearchQueryItem.advancedSearch(
                      value: search!,
                      onTap: () {
                        // TODO Open website to the search page
                      },
                    );
                  } else {
                    index -= 1;
                  }
                }

                final SearchSuggestion suggestion =
                    suggestions!.elementAt(index);
                return switch (suggestion.type) {
                  SearchSuggestionType.history => SearchQueryItem.history(
                      value: suggestion.term,
                      search: search!,
                      onTap: () {
                        SearchStateManager.of(context).search(suggestion.term);
                      },
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
            itemExtent: 60,
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

  bool _isInitialState(String? search) => search?.isEmpty ?? true;
}
