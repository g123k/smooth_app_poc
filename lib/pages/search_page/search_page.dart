import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/search_page/search_state_manager.dart';
import 'package:smoothapp_poc/pages/search_page/search_suggestions_state_manager.dart';
import 'package:smoothapp_poc/pages/search_page/ui/search_page_empty.dart';
import 'package:smoothapp_poc/pages/search_page/ui/search_page_results.dart';
import 'package:smoothapp_poc/utils/provider_utils.dart';
import 'package:smoothapp_poc/utils/widgets/circled_icon.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar.dart';

class SearchPage extends StatefulWidget {
  SearchPage({
    super.key,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();

  static Future<SearchPageResult?> open(BuildContext context) {
    return Navigator.push<SearchPageResult?>(
      context,
      PageRouteBuilder<SearchPageResult>(
        pageBuilder: (context, animation1, animation2) => SearchPage(),
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: Provider.value(
              value: animation.value < 1.0
                  ? _TransitionState.animating
                  : _TransitionState.idle,
              child:
                  IgnorePointer(ignoring: animation.value < 1.0, child: child),
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchStateManager()),
        ChangeNotifierProvider(create: (_) => SearchSuggestionsStateManager()),
      ],
      child: PrimaryScrollController(
        controller: _scrollController,
        child: SearchBarController(
          editingController: _searchBarController,
          child: Builder(builder: (context) {
            return ValueListener<SearchStateManager, SearchState>(
              onValueChanged: (SearchState searchState) {
                // When we click on a suggestion, prefill the search bar +
                // hide the keyboard
                final String? search = searchState.search;
                if (_searchBarController.text != search && search != null) {
                  _searchBarController.text = search;
                  _searchBarController.selection = TextSelection.fromPosition(
                    TextPosition(offset: search.length),
                  );

                  SearchBarController.of(context).hideKeyboard();
                }
              },
              child: Scaffold(
                extendBodyBehindAppBar: true,
                body: CustomScrollView(
                  controller: _scrollController,
                  slivers: const [
                    _SearchAppBar(),
                    _SearchPageBody(),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SearchAppBar extends StatelessWidget {
  const _SearchAppBar();

  @override
  Widget build(BuildContext context) {
    return Selector2<SearchStateManager, TextEditingController,
        SearchBarFooterWidget?>(
      selector: (
        _,
        SearchStateManager searchStateManager,
        TextEditingController controller,
      ) {
        if (searchStateManager.hasResults &&
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
  _SearchBodyType _bodyType = _SearchBodyType.suggestions;

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
          _TransitionState state = context.read<_TransitionState>();
          if (state == _TransitionState.idle) {
            if (_bodyType == _SearchBodyType.search) {
              // Ignore the event when the search is visible
              return;
            } else if (_bodyType == _SearchBodyType.suggestions &&
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
    String? search = context.read<SearchStateManager>().value.search;

    if (search == null) {
      _onSuggestionsChanged();
    } else if (_bodyType != _SearchBodyType.search) {
      /// When we reopen the search, if it was previously here
      /// AND with the same state, we restore the scroll position
      if (_previousSearchScrollPosition != null &&
          context.read<SearchStateManager>().value.hashCode ==
              _previousSearchScrollState) {
        PrimaryScrollController.of(context)
            .jumpTo(_previousSearchScrollPosition!);
      }
      setState(() => _bodyType = _SearchBodyType.search);
    }
  }

  void _onSuggestionsChanged() {
    if (_bodyType != _SearchBodyType.suggestions) {
      /// When we switch between suggestions and search, ensure to save
      /// the search scroll position.
      _previousSearchScrollState =
          context.read<SearchStateManager>().value.hashCode;
      _previousSearchScrollPosition =
          PrimaryScrollController.of(context).offset;

      setState(() => _bodyType = _SearchBodyType.suggestions);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_bodyType) {
      case _SearchBodyType.suggestions:
        return SearchBodySuggestions(
          onExitSearch: () {
            _lastKeyboardVisibleEvent = false;

            // When we click on the empty space below the suggestions…
            if (SearchStateManager.of(context).hasASearch) {
              // Go back to the search results
              SearchStateManager.of(context).forceReEmitEvent();
            } else {
              // Close the screen
              Navigator.of(context).pop();
            }
          },
        );
      case _SearchBodyType.search:
        return const SearchBodyResults();
    }
  }

  @override
  void dispose() {
    _keyboardSubscription?.cancel();
    super.dispose();
  }
}

enum _SearchBodyType {
  suggestions,
  search,
}
