import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/search_page/search_page.dart';
import 'package:smoothapp_poc/search_page/search_page_utils.dart';

class SearchBodyWithSearch extends StatelessWidget {
  const SearchBodyWithSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<TextEditingController, String>(
      selector: (BuildContext context, TextEditingController controller) {
        return controller.text;
      },
      shouldRebuild: (String previous, String next) {
        return next.isNotEmpty;
      },
      builder: (BuildContext context, String value, Widget? child) {
        return _SearchPageSuggestions(search: value);
      },
    );
  }
}

class _SearchPageSuggestions extends StatefulWidget {
  const _SearchPageSuggestions({required this.search});

  final String search;

  @override
  State<_SearchPageSuggestions> createState() => _SearchPageSuggestionsState();
}

class _SearchPageSuggestionsState extends State<_SearchPageSuggestions> {
  @override
  Widget build(BuildContext context) {
    final Iterable<String> history = _getHistory();
    final int childCount = 2 + history.length;

    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == 0) {
            return SearchQueryItem.search(
              value: widget.search,
              onTap: _onSearch,
            );
          } else if (history.isNotEmpty && index < childCount - 1) {
            return SearchQueryItem.history(
              value: history.elementAt(index - 1),
              search: widget.search,
              onTap: _onSearch,
            );
          } else {
            return SearchQueryItem.advancedSearch(
              value: widget.search,
              onTap: () {
                // TODO Open website to the search page
              },
            );
          }
        },
        childCount: childCount,
      ),
      itemExtent: 60,
    );
  }

  void _onSearch() {
    // TODO
    addToHistory(widget.search);
  }

  Iterable<String> _getHistory() {
    final String search = widget.search.toLowerCase();
    return FAKE_HISTORY_DATA.where((String element) {
      return element.trim().toLowerCase().contains(search);
    });
  }
}
