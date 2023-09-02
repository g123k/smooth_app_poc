import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smoothapp_poc/search_page/search_page.dart';
import 'package:smoothapp_poc/search_page/search_page_utils.dart';

// TODO: Load search history
class SearchBodyEmpty extends StatelessWidget {
  const SearchBodyEmpty({
    required this.search,
    required this.onExitSearch,
    super.key,
  });

  final String search;
  final VoidCallback onExitSearch;

  @override
  Widget build(BuildContext context) {
    final bool suggestions = FAKE_HISTORY_DATA.isEmpty;
    List<String> data = suggestions ? FAKE_SUGGESTIONS_DATA : FAKE_HISTORY_DATA;

    return MultiSliver(children: [
      SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (suggestions) {
              return SearchQueryItem.suggestions(
                value: data[index],
                onTap: () {
                  // TODO Launch search
                  addToHistory(data[index]);
                },
              );
            } else {
              return SearchQueryItem.history(
                value: data[index],
                search: search,
                onTap: () {
                  // TODO Launch search
                  addToHistory(data[index]);
                },
              );
            }
          },
          childCount: data.length,
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
  }
}
