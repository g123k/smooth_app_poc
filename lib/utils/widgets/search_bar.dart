import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';

//ignore_for_file: constant_identifier_names
class ExpandableSearchAppBar extends StatelessWidget {
  static const double HEIGHT = _Logo.MAX_HEIGHT + _SearchBar.SEARCH_BAR_HEIGHT;
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
    start: HomePage.HORIZONTAL_PADDING - 4.0,
    end: 10.0,
  );

  const ExpandableSearchAppBar({
    Key? key,
    required this.onFieldTapped,
    required this.onCameraTapped,
  }) : super(key: key);

  final VoidCallback onFieldTapped;
  final VoidCallback onCameraTapped;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverSearchAppBar(
        topPadding: MediaQuery.paddingOf(context).top,
        fixed: false,
        onFieldTapped: onFieldTapped,
        onCameraTapped: onCameraTapped,
      ),
      pinned: true,
    );
  }
}

class FixedSearchAppBar extends StatelessWidget {
  static const double HEIGHT = _Logo.MAX_HEIGHT + _SearchBar.SEARCH_BAR_HEIGHT;
  static const EdgeInsetsDirectional CONTENT_PADDING =
      EdgeInsetsDirectional.symmetric(
    horizontal: HomePage.HORIZONTAL_PADDING - 4.0,
  );

  const FixedSearchAppBar({
    required this.onCameraTapped,
    required this.onSearchEntered,
    required this.onSearchChanged,
    required this.onFocusGained,
    required this.onFocusLost,
    this.actionWidget,
    this.footer,
    Key? key,
  }) : super(key: key);

  final VoidCallback onCameraTapped;
  final Function(String)? onSearchEntered;
  final Function(String)? onSearchChanged;
  final VoidCallback onFocusGained;
  final VoidCallback onFocusLost;
  final Widget? actionWidget;
  final SearchBarFooterWidget? footer;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverSearchAppBar(
        topPadding: MediaQuery.paddingOf(context).top,
        fixed: true,
        onCameraTapped: onCameraTapped,
        onSearchEntered: onSearchEntered,
        onSearchChanged: onSearchChanged,
        onFocusGained: onFocusGained,
        onFocusLost: onFocusLost,
        actionWidget: actionWidget,
        footer: footer,
      ),
      pinned: true,
    );
  }
}

class _SliverSearchAppBar extends SliverPersistentHeaderDelegate {
  const _SliverSearchAppBar({
    required this.topPadding,
    required this.fixed,
    required this.onCameraTapped,
    this.onSearchEntered,
    this.onSearchChanged,
    this.onFieldTapped,
    this.onFocusGained,
    this.onFocusLost,
    this.actionWidget,
    this.footer,
  });

  final double topPadding;
  final bool fixed;

  final VoidCallback onCameraTapped;
  final Function(String)? onSearchEntered;
  final Function(String)? onSearchChanged;
  final VoidCallback? onFieldTapped;
  final VoidCallback? onFocusGained;
  final VoidCallback? onFocusLost;
  final Widget? actionWidget;
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
            (footer != null && previous.$2 != next.$2);
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
      onFieldTapped: onFieldTapped,
      onCameraTapped: onCameraTapped,
      onFocusGained: onFocusGained,
      onFocusLost: onFocusLost,
      actionWidget: actionWidget,
      onSearchChanged: onSearchChanged,
      onSearchEntered: onSearchEntered,
      footer: shrinkOffset < max ? footer : null,
      footerOffset: footer == null || shrinkOffset >= max
          ? null
          : shrinkOffset.clamp(0.0, max),
      footerMaxOffset: footer != null ? max : null,
    );
  }

  double computeLogoProgress(double shrinkOffset) {
    return ((shrinkOffset / minExtent) / 0.13).clamp(0.0, 1.0);
  }

  @override
  double get maxExtent =>
      minExtent +
      (footer == null ? 0 : (footer!.height + (HomePage.BORDER_RADIUS / 2)));

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
    required this.onCameraTapped,
    required this.onFieldTapped,
    required this.onFocusGained,
    required this.onFocusLost,
    this.actionWidget,
    this.footer,
    this.footerOffset,
    this.footerMaxOffset,
    this.onSearchChanged,
    this.onSearchEntered,
  });

  final VoidCallback onCameraTapped;
  final Function(String)? onSearchEntered;
  final Function(String)? onSearchChanged;
  final VoidCallback? onFieldTapped;
  final VoidCallback? onFocusGained;
  final VoidCallback? onFocusLost;
  final Widget? actionWidget;
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
        if (footer != null)
          Positioned.fill(
            top: minExtent -
                topPadding -
                (HomePage.BORDER_RADIUS / 2) -
                footerOffset!,
            bottom: 0.0,
            child: Offstage(
              offstage: footerInvisible,
              child: SafeArea(
                bottom: false,
                child: _SearchBarFooterWidgetWrapper(
                  child: footer!,
                  progress: footerOffset!,
                ),
              ),
            ),
          ),
        Positioned.fill(
          top: 0.0,
          bottom: footer != null && footerOffset! < footerMaxOffset!
              ? footer!.height - footerOffset! + (HomePage.BORDER_RADIUS / 2)
              : 0.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: AppColors.orangeLight,
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
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Logo(
                    progress: progress,
                    actionWidget: actionWidget,
                  ),
                  _SearchBar(
                    progress: progress,
                    autofocus: autofocus,
                    onFieldTapped: onFieldTapped,
                    onCameraTapped: onCameraTapped,
                    onSearchEntered: onSearchEntered,
                    onSearchChanged: onSearchChanged,
                    onFocusGained: onFocusGained,
                    onFocusLost: onFocusLost,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({
    required this.progress,
    this.actionWidget,
  });

  static const double FULL_WIDTH = 345.0;
  static const double MIN_HEIGHT = 35.0;
  static const double MAX_HEIGHT = 60.0;

  final double progress;
  final Widget? actionWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.0,
      padding: ExpandableSearchAppBar.LOGO_CONTENT_PADDING,
      child: LayoutBuilder(builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        double width = constraints.maxWidth;
        double imageWidth = FULL_WIDTH;

        if (imageWidth > width * 0.7) {
          imageWidth = width * 0.7;
        }

        return Container(
          width: imageWidth,
          height: math.max(MAX_HEIGHT * (1 - progress), MIN_HEIGHT),
          margin: EdgeInsetsDirectional.only(
            start: math.max((1 - progress) * ((width - imageWidth) / 4), 10.0),
            bottom: 5.0,
          ),
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: imageWidth,
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 346.0,
                    height: 61.0,
                    alignment: AlignmentDirectional.centerStart,
                  ),
                ),
              ),
              if (actionWidget != null)
                LayoutBuilder(builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.only(
                      // TODO This fix is not perfect
                      top: Platform.isIOS ? 0.5 : 3.0,
                    ),
                    child: IconTheme(
                      data: const IconThemeData(size: 17.0),
                      child: actionWidget!,
                    ),
                  );
                }),
            ],
          ),
        );
      }),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.progress,
    required this.autofocus,
    required this.onCameraTapped,
    required this.onSearchEntered,
    required this.onSearchChanged,
    required this.onFieldTapped,
    required this.onFocusGained,
    required this.onFocusLost,
  });

  static const SEARCH_BAR_HEIGHT = 55.0;
  final double progress;
  final bool autofocus;
  final VoidCallback onCameraTapped;
  final Function(String)? onSearchEntered;
  final Function(String)? onSearchChanged;
  final VoidCallback? onFieldTapped;
  final VoidCallback? onFocusGained;
  final VoidCallback? onFocusLost;

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
      if (widget.onFocusGained != null || widget.onFocusLost != null) {
        if (_searchFocusNode.hasFocus) {
          widget.onFocusGained?.call();
        } else {
          widget.onFocusLost?.call();
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
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: (1 - widget.progress).progress2(
          ExpandableSearchAppBar.MIN_CONTENT_PADDING.start,
          ExpandableSearchAppBar.CONTENT_PADDING.start,
        ),
      ),
      child: SizedBox(
        height: _SearchBar.SEARCH_BAR_HEIGHT,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _searchController,
                autofocus: widget.autofocus
                    ? SearchBarController.of(context).isKeyboardVisible
                    : false,
                textAlignVertical: TextAlignVertical.center,
                onTap: _manageOnTap ? () => widget.onFieldTapped?.call() : null,
                focusNode: _searchFocusNode,
                readOnly: _manageOnTap ? true : false,
                onChanged: (String value) {
                  widget.onSearchChanged?.call(
                    value.trim(),
                  );
                },
                onFieldSubmitted: (String value) {
                  widget.onSearchEntered?.call(
                    value.trim(),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit ou un code-barres',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Color(0xFFFF8714)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Color(0xFFFF8714)),
                  ),
                ),
              ),
            ),
            SizedBox.square(
              dimension: (55.0 + 8.0) * widget.progress,
              child: Focus(
                focusNode: _buttonFocusNode,
                canRequestFocus: false,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: IconButton(
                    tooltip: _hasText ? 'Effacer' : 'Scanner un code-barres',
                    onPressed: () {
                      if (_hasText) {
                        _searchController.clear();
                        _searchFocusNode.requestFocus();
                        widget.onSearchChanged?.call('');
                      } else {
                        widget.onCameraTapped.call();
                      }
                    },
                    icon: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        if (_hasText) {
                          return icons.ClearText(
                            size: math.min(28.0, constraints.minSide),
                          );
                        } else {
                          return icons.Barcode(
                            size: math.min(30.0, constraints.minSide),
                          );
                        }
                      },
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      side: MaterialStateProperty.all(
                        const BorderSide(color: Color(0xFFFF8714)),
                      ),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      shape: MaterialStateProperty.all(
                        const CircleBorder(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _manageOnTap => widget.onFieldTapped != null;

  bool get _hasText => _searchController.text.trim().isNotEmpty;

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
    _keyboardController.add(true);
  }

  void hideKeyboard() {
    _keyboardController.add(false);
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

class _SearchBarFooterWidgetWrapper extends StatelessWidget {
  const _SearchBarFooterWidgetWrapper({
    required this.child,
    required this.progress,
  });

  final SearchBarFooterWidget child;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(HomePage.BORDER_RADIUS),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: child.color,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(HomePage.BORDER_RADIUS),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: HomePage.BORDER_RADIUS * 0.5),
          child: SizedBox.expand(child: child.build(context)),
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
