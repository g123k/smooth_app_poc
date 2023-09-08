import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:smoothapp_poc/pages/search_page/search_state_manager.dart';
import 'package:smoothapp_poc/pages/search_page/search_suggestions_state_manager.dart';
import 'package:smoothapp_poc/pages/search_page/search_ui_manager.dart';
import 'package:smoothapp_poc/pages/search_page/ui/search_page_empty.dart';
import 'package:smoothapp_poc/pages/search_page/ui/search_page_results.dart';
import 'package:smoothapp_poc/utils/provider_utils.dart';
import 'package:smoothapp_poc/utils/widgets/circled_icon.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();

  static Future<SearchPageResult?> open(BuildContext context) {
    return Navigator.push<SearchPageResult?>(
      context,
      PageRouteBuilder<SearchPageResult>(
        pageBuilder: (context, animation1, animation2) => const SearchPage(),
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: Provider.value(
              value: animation.value < 1.0
                  ? _TransitionState.animating
                  : _TransitionState.idle,
              child: IgnorePointer(
                ignoring: animation.value < 1.0,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

// The state is only for controllers
class _SearchPageState extends State<SearchPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchBarController = TextEditingController();
  final BehaviorSubject<bool> _searchBarKeyboardController = BehaviorSubject();

  @override
  void initState() {
    super.initState();
    _searchBarKeyboardController.add(true);
  }

  @override
  Widget build(BuildContext context) {
    return SearchBarController(
      editingController: _searchBarController,
      keyboardStreamController: _searchBarKeyboardController,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SearchStateManager()),
          ChangeNotifierProvider(
              create: (_) => SearchSuggestionsStateManager()),
          ChangeNotifierProvider(
            create: (BuildContext context) => SearchUIManager(
              context,
            ),
          ),
        ],
        child: PrimaryScrollController(
          controller: _scrollController,
          child: Builder(builder: (context) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              body: CustomScrollView(
                controller: _scrollController,
                slivers: const [
                  _SearchAppBar(),
                  _SearchPageBody(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchBarController.dispose();
    _searchBarKeyboardController.close();
    super.dispose();
  }
}

class _SearchAppBar extends StatelessWidget {
  const _SearchAppBar();

  @override
  Widget build(BuildContext context) {
    return Selector3<SearchUIManager, SearchStateManager, TextEditingController,
        SearchBarFooterWidget?>(
      selector: (
        _,
        SearchUIManager searchUIManager,
        SearchStateManager searchStateManager,
        TextEditingController controller,
      ) {
        if (searchUIManager.isShowingResults &&
            searchStateManager.hasResults &&
            controller.text ==
                (searchStateManager.value as SearchResultsState).search) {
          return const SearchFooterResults();
        } else {
          return null;
        }
      },
      builder: (BuildContext context, SearchBarFooterWidget? footer, _) {
        return FixedSearchAppBar(
          onCameraTapped: () {
            Navigator.of(context).pop(SearchPageResult.openCamera);
          },
          actionWidget: const CloseCircledIcon(),
          onSearchChanged: (String query) {
            SearchStateManager.of(context).cancelSearch();
            SearchSuggestionsStateManager.of(context).onSearchModified(query);
          },
          onSearchEntered: (String query) {
            SearchStateManager.of(context).search(query);
            SearchBarController.of(context).hideKeyboard();
          },
          onFocusGained: () {},
          onFocusLost: () {},
          footer: footer,
        );
      },
    );
  }
}

enum _TransitionState {
  idle,
  animating,
}

enum SearchPageResult {
  openCamera,
}

class _SearchPageBody extends StatefulWidget {
  const _SearchPageBody();

  @override
  State<_SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<_SearchPageBody> {
  StreamSubscription<bool>? _keyboardSubscription;
  bool? _lastKeyboardVisibleEvent;

  // To save the last search position, we need to have two variables:
  int? _previousSearchScrollState;
  double? _previousSearchScrollPosition;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid || Platform.isIOS) {
      final KeyboardVisibilityController keyboardController =
          KeyboardVisibilityController();
      _keyboardSubscription =
          keyboardController.onChange.listen((bool visible) {
        if (!visible && _lastKeyboardVisibleEvent == true) {
          // Prevent a double pop when during the fade transition
          final _TransitionState state = context.read<_TransitionState>();
          final SearchUIType type = SearchUIManager.read(context).value;
          if (state == _TransitionState.idle) {
            if (type == SearchUIType.results) {
              // Ignore the event when the search is visible
              return;
            } else if (type == SearchUIType.suggestions &&
                SearchStateManager.of(context).hasASearch) {
              return;
            }

            Navigator.of(context).pop();
          }
        }

        _lastKeyboardVisibleEvent = visible;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<SearchStateManager>().replaceListener(_onSearchChanged);
    context
        .read<SearchSuggestionsStateManager>()
        .replaceListener(_onSuggestionsChanged);
  }

  void _onSearchChanged() {
    if (!SearchUIManager.read(context).isShowingResults) {
      /// When we reopen the search, if it was previously here
      /// AND with the same state, we restore the scroll position
      if (_previousSearchScrollPosition != null &&
          context.read<SearchStateManager>().value.hashCode ==
              _previousSearchScrollState) {
        PrimaryScrollController.of(context)
            .jumpTo(_previousSearchScrollPosition!);
      }

      SearchUIManager.read(context).showSearchResults();
    }
  }

  void _onSuggestionsChanged() {
    if (!SearchUIManager.read(context).isShowingSuggestions) {
      /// When we switch between suggestions and search, ensure to save
      /// the search scroll position.
      _previousSearchScrollState =
          context.read<SearchStateManager>().value.hashCode;
      _previousSearchScrollPosition =
          PrimaryScrollController.of(context).offset;

      SearchUIManager.read(context).showSuggestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (SearchUIManager.watch(context).value) {
      case SearchUIType.suggestions:
        return SearchBodySuggestions(
          onExitSearch: () {
            _lastKeyboardVisibleEvent = false;

            // When we click on the empty space below the suggestions…
            if (SearchStateManager.of(context).hasASearch) {
              // Restore the previous search
              final SearchBarController searchBarController =
                  SearchBarController.find(context);
              searchBarController.controller.text =
                  SearchStateManager.of(context).value.search ?? '';

              searchBarController.hideKeyboard();

              // Go back to the search results
              SearchUIManager.read(context).showSearchResults();
            } else {
              // Close the screen
              Navigator.of(context).pop();
            }
          },
        );
      case SearchUIType.results:
        return const SearchBodyResults();
    }
  }

  @override
  void dispose() {
    _keyboardSubscription?.cancel();
    super.dispose();
  }
}
