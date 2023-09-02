import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/homepage/appbar/search_bar.dart';
import 'package:smoothapp_poc/search_page/search_page_empty.dart';
import 'package:smoothapp_poc/search_page/search_page_query.dart';
import 'package:smoothapp_poc/utils/widgets/circled_icon.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableProvider.value(
        value: TextEditingController(),
        child: CustomScrollView(
          slivers: [
            FixedSearchAppBar(
              onCameraTapped: () {
                Navigator.of(context).pop(SearchPageResult.openCamera);
              },
              actionWidget: const CloseCircledIcon(),
              onSearchEntered: (String query) {},
              onFocusGained: () {},
              onFocusLost: () {},
            ),
            const _SearchPageBody(),
          ],
        ),
      ),
    );
  }

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
  Widget build(BuildContext context) {
    return Selector<TextEditingController, String>(
      selector: (BuildContext context, TextEditingController controller) {
        return controller.text;
      },
      shouldRebuild: (String previous, String next) {
        final int previousLength = previous.length;
        final int nextLength = next.length;

        return previousLength == 0 && nextLength > 0 ||
            previousLength > 0 && nextLength == 0;
      },
      builder: (BuildContext context, String value, Widget? child) {
        if (value.isEmpty) {
          return SearchBodyEmpty(
            search: value,
            onExitSearch: () {
              _lastKeyboardVisibleEvent = false;
              print('pop');
              Navigator.of(context).pop();
            },
          );
        } else {
          return const SearchBodyWithSearch();
        }
      },
    );
  }

  @override
  void dispose() {
    _keyboardSubscription?.cancel();
    super.dispose();
  }
}

// TODO
final List<String> FAKE_HISTORY_DATA = [];
const List<String> FAKE_SUGGESTIONS_DATA = [
  'Nutella',
  'Christaline',
  'Pâtes à la bolognaise',
];

addToHistory(String search) {
  if (!FAKE_HISTORY_DATA.contains(search.trim())) {
    FAKE_HISTORY_DATA.add(search.trim());
  }
}
