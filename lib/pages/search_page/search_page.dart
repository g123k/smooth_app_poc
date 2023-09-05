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

class SearchPage extends StatelessWidget {
  SearchPage({
    super.key,
  });

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => _controller),
        ChangeNotifierProvider(create: (_) => SearchStateManager()),
        ChangeNotifierProvider(create: (_) => SearchSuggestionsStateManager()),
      ],
      child: ValueListener<SearchStateManager, SearchState>(
        onValueChanged: (SearchState searchState) {
          final String? search = searchState.search;
          if (_controller.text != search && search != null) {
            _controller.text = search;
          }
        },
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                FixedSearchAppBar(
                  onCameraTapped: () {
                    Navigator.of(context).pop(SearchPageResult.openCamera);
                  },
                  actionWidget: const CloseCircledIcon(),
                  onSearchChanged: (String query) {
                    SearchStateManager.of(context).cancelSearch();
                    SearchSuggestionsStateManager.of(context)
                        .onSearchModified(query);
                  },
                  onSearchEntered: (String query) {
                    SearchStateManager.of(context).search(query);
                  },
                  onFocusGained: () {},
                  onFocusLost: () {},
                ),
                const _SearchPageBody(),
              ],
            ),
          );
        }),
      ),
    );
  }

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
      setState(() => _bodyType = _SearchBodyType.search);
    }
  }

  void _onSuggestionsChanged() {
    if (_bodyType != _SearchBodyType.suggestions) {
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
            Navigator.of(context).pop();
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
