import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';
import 'package:smoothapp_poc/pages/shopping_list/shopping_list.dart';
import 'package:smoothapp_poc/utils/system_ui.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';
import 'package:smoothapp_poc/utils/widgets/modal_sheet.dart';

class NavApp extends StatefulWidget {
  const NavApp({super.key});

  @override
  State<NavApp> createState() => NavAppState();

  static NavAppState of(BuildContext context) {
    return context.read<NavAppState>();
  }

  static NavAppState? maybeOf(BuildContext context) {
    return context.read<NavAppState?>();
  }
}

class NavAppState extends State<NavApp> with TickerProviderStateMixin {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  late AnimationController _bottomSheetAndNavBarController;
  late AnimationController _bottomSheetAnimationController;
  late Animation<Offset> _bottomSheetAnimation;
  late SheetVisibilityNotifier _sheetVisibility;
  int _selectedTab = 1;

  Animation<double>? _bottomSheetAndNavBarAnimation;

  DraggableScrollableLockAtTopSheet? _sheet;
  double _navBarHeight = kBottomNavigationBarHeight;
  double _navBarTranslation = kBottomNavigationBarHeight;

  @override
  void initState() {
    super.initState();
    _bottomSheetAndNavBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _bottomSheetAnimationController = BottomSheet.createAnimationController(
      this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          setState(() => _sheet = null);
        }
      });

    _bottomSheetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 150.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _bottomSheetAnimationController,
        curve: Curves.easeInCubic,
      )..addListener(() => setState(() {})),
    );

    _sheetVisibility = SheetVisibilityNotifier(_SheetVisibility.gone);

    onNextFrame(() {
      _navBarHeight = _navBarTranslation = kBottomNavigationBarHeight +
          MediaQuery.of(context).viewPadding.bottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: this),
        ChangeNotifierProvider<DraggableScrollableLockAtTopController?>.value(
          value: _sheet?.controller,
        ),
        ChangeNotifierProvider<SheetVisibilityNotifier>.value(
          value: _sheetVisibility,
        ),
        ChangeNotifierProvider<OnTabChangedNotifier>(
          create: (_) => OnTabChangedNotifier(HomeTabs.values[_selectedTab]),
        ),
      ],
      child: Builder(builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned.fill(
              bottom: _navBarHeight,
              child: Offstage(
                offstage: _sheetVisibility.isFullyVisible,
                child: Navigator(
                  key: _navigatorKey,
                  pages: [
                    MaterialPage<void>(
                      child: _getSubPage(),
                    ),
                  ],
                  onPopPage: (route, result) {
                    return route.didPop(result);
                  },
                ),
              ),
            ),
            if (_sheet != null)
              Positioned.fill(
                bottom: _navBarTranslation,
                child: Transform.translate(
                  offset: _bottomSheetAnimation.value,
                  child: Opacity(
                    opacity: _bottomSheetAnimationController.value,
                    child: _sheet!,
                  ),
                ),
              ),
            Positioned.fill(
              top: null,
              child: Transform.translate(
                offset: Offset(0.0, _navBarHeight - _navBarTranslation),
                child: MediaQuery.removePadding(
                  removeTop: true,
                  removeBottom: true,
                  context: context,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2.0,
                          offset: const Offset(-2.0, -2.0),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      bottom: true,
                      child: NavigationBar(
                        height: kBottomNavigationBarHeight +
                            MediaQuery.viewPaddingOf(context).bottom,
                        onDestinationSelected: (int page) {
                          if (page == _selectedTab) {
                            if (_navigatorKey.currentState?.canPop() == true) {
                              _navigatorKey.currentState!.maybePop();
                              return;
                            }
                          } else {
                            hideSheet();
                            setState(() => _selectedTab = page);
                          }

                          OnTabChangedNotifier.of(context)
                              .updateWith(HomeTabs.values[page]);
                        },
                        selectedIndex: _selectedTab,
                        labelBehavior:
                            NavigationDestinationLabelBehavior.alwaysShow,
                        destinations: HomeTabs.values
                            .map(
                              (HomeTabs tab) => NavigationDestination(
                                icon: tab.icon,
                                label: tab.label,
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _getSubPage() {
    return switch (_selectedTab) {
      0 => const ShoppingListPage(),
      _ => const HomePage(),
    };
  }

  Future<void> showSheet(DraggableScrollableLockAtTopSheet sheet) async {
    assert(sheet.controller != null, 'A controller is mandatory');
    if (_sheet != null) {
      await hideSheet();
    }

    _sheetVisibility.value = _SheetVisibility.partiallyVisible;
    sheet.controller!.addListener(_onSheetScrolled);
    _sheet = sheet;
    _bottomSheetAnimationController.forward();
    HapticFeedback.heavyImpact();
  }

  Future<void> hideSheet() async {
    if ((_sheet?.controller?.size ?? 0.0) >= 0.99) {
      await _sheet!.controller!.reset();
    }

    _sheet?.controller?.removeListener(_onSheetScrolled);
    _sheet?.controller?.dispose();
    _sheetVisibility.value = _SheetVisibility.gone;
    await _bottomSheetAnimationController.reverse();
  }

  bool get hasSheet => _sheet != null;

  double get navBarHeight => _navBarHeight;

  bool get isSheetFullyVisible =>
      _sheetVisibility.value == _SheetVisibility.fullyVisible;

  void _onSheetScrolled() {
    if (_sheet!.controller!.isExpanded) {
      if (_navBarTranslation == _navBarHeight) {
        _animateBottomBar(0.0);
      }
      if (_sheetVisibility.value != _SheetVisibility.fullyVisible) {
        _sheetVisibility.value = _SheetVisibility.fullyVisible;
      }
    } else if (_sheet!.controller!.size < 1.0) {
      if (_navBarTranslation == 0.0) {
        SystemChrome.setSystemUIOverlayStyle(SystemUIStyle.light);
        _animateBottomBar(_navBarHeight);
      }

      if (_sheetVisibility.value != _SheetVisibility.partiallyVisible) {
        _sheetVisibility.value = _SheetVisibility.partiallyVisible;
      }
    }
  }

  void _animateBottomBar(double end) {
    _bottomSheetAndNavBarController.stop();

    _bottomSheetAndNavBarAnimation =
        Tween<double>(begin: _navBarTranslation, end: end)
            .animate(_bottomSheetAndNavBarController)
          ..addListener(
            () => setState(
              () {
                _navBarTranslation = _bottomSheetAndNavBarAnimation!.value;
              },
            ),
          );
    _bottomSheetAndNavBarController.reset();
    _bottomSheetAndNavBarController.forward();
  }

  @override
  void dispose() {
    _sheet?.controller?.removeListener(_onSheetScrolled);
    _bottomSheetAnimationController.dispose();
    _bottomSheetAndNavBarController.dispose();
    super.dispose();
  }
}

class SheetVisibilityNotifier extends ValueNotifier<_SheetVisibility> {
  // ignore: library_private_types_in_public_api
  SheetVisibilityNotifier(super.value);

  bool get isFullyVisible => value == _SheetVisibility.fullyVisible;

  bool get isPartiallyVisible => value == _SheetVisibility.partiallyVisible;

  bool get isGone => value == _SheetVisibility.gone;

  static SheetVisibilityNotifier of(BuildContext context) {
    return context.watch<SheetVisibilityNotifier>();
  }
}

enum _SheetVisibility {
  fullyVisible,
  partiallyVisible,
  gone,
}

class OnTabChangedNotifier extends ValueNotifier<HomeTabs> {
  // ignore: library_private_types_in_public_api
  OnTabChangedNotifier(super.value);

  static OnTabChangedNotifier of(BuildContext context) {
    return context.read<OnTabChangedNotifier>();
  }

  void updateWith(HomeTabs value) {
    this.value = value;

    if (hasListeners) {
      notifyListeners();
    }
  }
}

enum HomeTabs {
  profile(Icon(Icons.account_circle), 'Mon profil'),
  scanner(Icon(Icons.camera_alt), 'Scan'),
  lists(Icon(Icons.list), 'Mes listes');

  const HomeTabs(this.icon, this.label);

  final Icon icon;
  final String label;
}
