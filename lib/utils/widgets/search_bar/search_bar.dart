import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';
import 'package:smoothapp_poc/resources/app_animations.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar/search_bar_top.dart';
import 'package:smoothapp_poc/utils/widgets/useful_widgets.dart';

//ignore_for_file: constant_identifier_names
class ExpandableSearchAppBar extends StatelessWidget {
  static const double HEIGHT =
      AppBarLogo.MAX_HEIGHT + _SearchBar.SEARCH_BAR_HEIGHT;
  static const EdgeInsetsDirectional CONTENT_PADDING =
      EdgeInsetsDirectional.symmetric(
    horizontal: HomePage.HORIZONTAL_PADDING - 4.0,
  );
  static const EdgeInsetsDirectional MIN_CONTENT_PADDING =
      EdgeInsetsDirectional.symmetric(
    horizontal: 10.0,
  );
  static const EdgeInsetsDirectional LOGO_CONTENT_PADDING =
      EdgeInsetsDirectional.only(
    start: 4.0,
    end: 10.0,
  );

  const ExpandableSearchAppBar({
    Key? key,
    required this.onFieldTapped,
    this.footer,
    this.actionIcon,
    this.actionSemantics,
    this.onActionButtonClicked,
  }) : super(key: key);

  final VoidCallback onFieldTapped;
  final SearchBarFooterWidget? footer;
  final icons.AppIcon? actionIcon;
  final String? actionSemantics;
  final VoidCallback? onActionButtonClicked;

  @override
  Widget build(BuildContext context) {
    return SearchAppBarData(
      onFieldTapped: onFieldTapped,
      actionIcon: actionIcon,
      actionSemantics: actionSemantics,
      onActionButtonClicked: onActionButtonClicked,
      fixed: false,
      child: SliverPersistentHeader(
        delegate: _SliverSearchAppBar(
          topPadding: MediaQuery.paddingOf(context).top,
          fixed: false,
          footer: footer,
        ),
        pinned: true,
      ),
    );
  }
}

class FixedSearchAppBar extends StatelessWidget {
  static const double HEIGHT =
      AppBarLogo.MAX_HEIGHT + _SearchBar.SEARCH_BAR_HEIGHT;
  static const EdgeInsetsDirectional CONTENT_PADDING =
      EdgeInsetsDirectional.symmetric(
    horizontal: HomePage.HORIZONTAL_PADDING - 4.0,
  );

  const FixedSearchAppBar({
    required this.onSearchEntered,
    required this.onSearchChanged,
    required this.onFocusGained,
    required this.onFocusLost,
    this.backButton,
    this.actionIcon,
    this.actionSemantics,
    this.onActionButtonClicked,
    this.footer,
    this.searchBarType,
    Key? key,
  }) : super(key: key);

  final Function(String)? onSearchEntered;
  final Function(String)? onSearchChanged;
  final VoidCallback onFocusGained;
  final VoidCallback onFocusLost;
  final bool? backButton;
  final icons.AppIcon? actionIcon;
  final String? actionSemantics;
  final VoidCallback? onActionButtonClicked;
  final SearchBarFooterWidget? footer;
  final SearchBarType? searchBarType;

  @override
  Widget build(BuildContext context) {
    return SearchAppBarData(
      onSearchEntered: onSearchEntered,
      onSearchChanged: onSearchChanged,
      onFocusGained: onFocusGained,
      onFocusLost: onFocusLost,
      actionIcon: actionIcon,
      actionSemantics: actionSemantics,
      onActionButtonClicked: onActionButtonClicked,
      searchBarType: searchBarType,
      backButton: backButton ?? false,
      fixed: true,
      child: SliverPersistentHeader(
        delegate: _SliverSearchAppBar(
          topPadding: MediaQuery.paddingOf(context).top,
          fixed: true,
          footer: footer,
        ),
        pinned: true,
      ),
    );
  }
}

class SearchAppBarData extends InheritedWidget {
  const SearchAppBarData({
    super.key,
    required this.fixed,
    this.onFieldTapped,
    this.onSearchEntered,
    this.onSearchChanged,
    this.onFocusGained,
    this.onFocusLost,
    this.backButton = false,
    this.actionIcon,
    this.actionSemantics,
    this.onActionButtonClicked,
    this.searchBarType,
    required Widget child,
  }) : super(child: child);

  final VoidCallback? onFieldTapped;
  final Function(String)? onSearchEntered;
  final Function(String)? onSearchChanged;
  final VoidCallback? onFocusGained;
  final VoidCallback? onFocusLost;
  final bool backButton;

  final VoidCallback? onActionButtonClicked;
  final icons.AppIcon? actionIcon;
  final String? actionSemantics;

  final SearchBarType? searchBarType;
  final bool fixed;

  static SearchAppBarData of(BuildContext context) {
    final SearchAppBarData? result =
        context.dependOnInheritedWidgetOfExactType<SearchAppBarData>();
    assert(result != null, 'No _SearchAppBarData found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SearchAppBarData old) {
    return old.searchBarType != searchBarType ||
        old.actionIcon != actionIcon ||
        old.backButton != backButton;
  }
}

class _SliverSearchAppBar extends SliverPersistentHeaderDelegate {
  const _SliverSearchAppBar({
    required this.topPadding,
    required this.fixed,
    this.footer,
  });

  final double topPadding;
  final bool fixed;
  final SearchBarFooterWidget? footer;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    if (fixed) {
      return _build(
        context: context,
        progress: 1.0,
        autofocus: true,
        shrinkOffset: shrinkOffset,
      );
    }

    return Selector<ScrollController, (double, double)>(
      selector: (BuildContext context, ScrollController controller) {
        final double position = controller.offset;
        final HomePageState homePageState = HomePage.of(context);
        final double cameraHeight = homePageState.cameraHeight;
        final double cameraPeak = homePageState.cameraPeak;

        if (position >= cameraHeight) {
          return (1.0, shrinkOffset);
        } else if (position < cameraPeak) {
          return (0.0, shrinkOffset);
        } else {
          return (
            (position - cameraPeak) / (cameraHeight - cameraPeak),
            shrinkOffset
          );
        }
      },
      shouldRebuild: ((double, double) previous, (double, double) next) {
        return previous.$1 != next.$1 ||
            footer != null && previous.$2 != next.$2;
      },
      builder: (BuildContext context, (double, double) progress, _) {
        return _build(
          context: context,
          progress: progress.$1,
          autofocus: false,
          shrinkOffset: progress.$2,
        );
      },
    );
  }

  Widget _build({
    required BuildContext context,
    required double progress,
    required bool autofocus,
    required double shrinkOffset,
  }) {
    final double max = maxExtent - minExtent;

    return _SearchAppBar(
      progress: progress,
      topPadding: topPadding,
      minExtent: minExtent,
      autofocus: autofocus,
      footer: shrinkOffset < max ? footer : null,
      footerOffset: footer == null || shrinkOffset >= max
          ? null
          : shrinkOffset.clamp(0.0, max),
      footerMaxOffset: footer != null ? max : null,
    );
  }

  @override
  double get maxExtent =>
      minExtent +
      (footer == null ? 0 : (footer!.height + HomePage.BORDER_RADIUS));

  @override
  double get minExtent => ExpandableSearchAppBar.HEIGHT + (topPadding * 1.5);

  @override
  bool shouldRebuild(_SliverSearchAppBar oldDelegate) =>
      oldDelegate.footer != footer;
}

class _SearchAppBar extends StatelessWidget {
  const _SearchAppBar({
    required this.progress,
    required this.autofocus,
    required this.minExtent,
    required this.topPadding,
    this.footer,
    this.footerOffset,
    this.footerMaxOffset,
  });

  final SearchBarFooterWidget? footer;
  final double topPadding;
  final double? footerOffset;
  final double? footerMaxOffset;
  final double minExtent;
  final bool autofocus;

  final double progress;

  @override
  Widget build(BuildContext context) {
    final bool footerInvisible =
        footer == null ? true : footerOffset! >= footerMaxOffset!;

    return Stack(
      children: [
        Positioned.fill(
          top: minExtent -
              topPadding -
              (HomePage.BORDER_RADIUS / 2) -
              (footerOffset ?? 0.0),
          bottom: 0.0,
          child: Offstage(
            offstage: footerInvisible,
            child: SafeArea(
              bottom: false,
              child: _SearchBarFooterWidgetWrapper(
                child: footer,
              ),
            ),
          ),
        ),
        Positioned.fill(
          top: 0.0,
          bottom: footer != null && footerOffset! < footerMaxOffset!
              ? footer!.height - footerOffset! + HomePage.BORDER_RADIUS
              : 0.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(HomePage.BORDER_RADIUS),
                ),
                boxShadow: footerInvisible
                    ? [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0x44FFFFFF)
                              : const Color(0x44000000),
                          blurRadius: progress * 10.0,
                        ),
                      ]
                    : null),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: MediaQuery.viewPaddingOf(context).top /
                      progress.progress2(2, 1),
                ),
                Expanded(child: SearchBarTop(progress: progress)),
                SizedBox(
                  height: (1 - progress) *
                      (MediaQuery.viewPaddingOf(context).top / 6),
                ),
                _SearchBar(
                  progress: progress,
                  autofocus: autofocus,
                ),
                SizedBox(
                  height: (1 - progress.clamp(0.0, 0.7)) *
                      (MediaQuery.viewPaddingOf(context).top / 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.progress,
    required this.autofocus,
  });

  static const SEARCH_BAR_HEIGHT = 55.0;
  final double progress;
  final bool autofocus;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final FocusNode _searchFocusNode = FocusNode();

  /// A Focus Node only used to hide the keyboard when we go up.
  final FocusNode _buttonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(() {
      if (!mounted) {
        return;
      }

      if (_searchFocusNode.hasFocus) {
        SearchBarController.maybeOf(context)?.showKeyboard();
      } else {
        SearchBarController.maybeOf(context)?.hideKeyboard();
      }

      final SearchAppBarData appBarData = SearchAppBarData.of(context);
      if (appBarData.onFocusGained != null || appBarData.onFocusLost != null) {
        if (_searchFocusNode.hasFocus) {
          appBarData.onFocusGained?.call();
        } else {
          appBarData.onFocusLost?.call();
        }
      }
    });
  }

  TextEditingController _searchController = TextEditingController();
  StreamSubscription<bool>? _keyboardEvents;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      SearchBarController controller = SearchBarController.of(context);
      _searchController = controller.controller;
      _keyboardEvents?.cancel();
      _keyboardEvents =
          controller.listenToKeyboardChanges(_updateKeyboardVisibility);
    } catch (_) {}
  }

  void _updateKeyboardVisibility(bool visible) {
    if (visible && !_searchFocusNode.hasFocus) {
      _searchFocusNode.requestFocus();
    } else if (!visible && !_buttonFocusNode.hasFocus) {
      _buttonFocusNode.requestFocus();
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final SearchAppBarData appBarData = SearchAppBarData.of(context);
    final bool manageOnTap = appBarData.onFieldTapped != null;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: ExpandableSearchAppBar.CONTENT_PADDING.start,
      ),
      child: SizedBox(
        height: _SearchBar.SEARCH_BAR_HEIGHT,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.white,
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 20.0,
                    end: 10.0,
                    bottom: 3.0,
                  ),
                  child: TextFormField(
                    controller: _searchController,
                    autofocus: widget.autofocus
                        ? SearchBarController.of(context).isKeyboardVisible
                        : false,
                    onTap: manageOnTap
                        ? () => appBarData.onFieldTapped?.call()
                        : null,
                    focusNode: _searchFocusNode,
                    readOnly: manageOnTap ? true : false,
                    onChanged: (String value) {
                      appBarData.onSearchChanged?.call(
                        value.trim(),
                      );
                    },
                    onFieldSubmitted: (String value) {
                      appBarData.onSearchEntered?.call(
                        value.trim(),
                      );
                    },
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un produit ou un code-barres',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              AspectRatio(
                aspectRatio: 1.0,
                child: Material(
                  type: MaterialType.transparency,
                  child: Tooltip(
                    message: 'Lancer la recherche',
                    enableFeedback: true,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        if (manageOnTap) {
                          appBarData.onFieldTapped?.call();
                        } else if (_searchController.text.trim().isNotEmpty) {
                          appBarData.onSearchEntered?.call(
                            _searchController.text.trim(),
                          );
                        }
                      },
                      child: Ink(
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SearchAnimation(
                            type: _getSearchAnimation(appBarData.searchBarType),
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  SearchAnimationType _getSearchAnimation(SearchBarType? searchBarType) {
    return switch (searchBarType) {
      SearchBarType.edit => SearchAnimationType.edit,
      SearchBarType.loading => SearchAnimationType.cancel,
      SearchBarType.search => SearchAnimationType.search,
      _ => SearchAnimationType.search,
    };
  }

  @override
  void dispose() {
    _keyboardEvents?.cancel();
    _searchFocusNode.dispose();
    _buttonFocusNode.dispose();
    super.dispose();
  }
}

class SearchBarController extends InheritedWidget {
  SearchBarController({
    super.key,
    required TextEditingController editingController,
    required BehaviorSubject<bool> keyboardStreamController,
    required Widget child,
  })  : controller = editingController,
        _keyboardController = keyboardStreamController,
        super(
          child: ListenableProvider(
            create: (_) => editingController,
            child: child,
          ),
        ) {
    _keyboardController.add(true);
  }

  final TextEditingController controller;
  final BehaviorSubject<bool> _keyboardController;

  StreamSubscription<bool> listenToKeyboardChanges(
    void Function(bool) onEvent,
  ) {
    return _keyboardController.stream.listen(onEvent);
  }

  void showKeyboard() {
    if (_keyboardController.value == false) {
      _keyboardController.add(true);
    }
  }

  void hideKeyboard() {
    if (_keyboardController.value == true) {
      _keyboardController.add(false);
    }
  }

  bool get isKeyboardVisible => _keyboardController.value;

  static SearchBarController of(BuildContext context) {
    final SearchBarController? result =
        context.dependOnInheritedWidgetOfExactType<SearchBarController>();
    assert(result != null, 'No SearchBarController found in context');
    return result!;
  }

  static SearchBarController find(BuildContext context) {
    final SearchBarController? result =
        context.findAncestorWidgetOfExactType<SearchBarController>();
    assert(result != null, 'No SearchBarController found in context');
    return result!;
  }

  static SearchBarController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SearchBarController>();
  }

  @override
  bool updateShouldNotify(SearchBarController oldWidget) {
    return oldWidget.controller != controller;
  }
}

enum SearchBarType {
  search,
  loading,
  edit,
}

class _SearchBarFooterWidgetWrapper extends StatelessWidget {
  const _SearchBarFooterWidgetWrapper({
    required this.child,
  });

  final SearchBarFooterWidget? child;

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return EMPTY_WIDGET;
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(HomePage.BORDER_RADIUS),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: child!.color,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(HomePage.BORDER_RADIUS),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: HomePage.BORDER_RADIUS * 0.5),
          child: SizedBox.expand(child: child!.build(context)),
        ),
      ),
    );
  }
}

abstract class SearchBarFooterWidget {
  Color get color;

  double get height;

  Widget build(BuildContext context);
}
